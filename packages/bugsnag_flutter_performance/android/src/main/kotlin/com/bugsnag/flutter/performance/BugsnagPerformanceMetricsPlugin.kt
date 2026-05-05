package com.bugsnag.flutter.performance

import android.app.ActivityManager
import android.content.Context
import android.os.Build
import android.os.Debug
import android.system.ErrnoException
import android.system.Os
import android.system.OsConstants
import android.view.Display
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import java.util.Timer
import java.util.TimerTask
import kotlin.concurrent.scheduleAtFixedRate

/**
 * Plugin for collecting CPU and Memory performance metrics on Android
 */
class BugsnagPerformanceMetricsPlugin : FlutterPlugin, MethodCallHandler {

    companion object {
        /**
         * Number of clock ticks per second, used to convert CPU time from ticks to milliseconds.
         */
        internal val TICKS_PER_SECOND: Long = try {
            Os.sysconf(OsConstants._SC_CLK_TCK)
        } catch (e: ErrnoException) {
            // Fallback to a reasonable default if sysconf fails.
            100L
        }
    }

    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    
    private val cpuSampler = CpuSampler()
    private val memorySampler = MemorySampler()

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "bugsnag_performance_metrics")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        
        cpuSampler.context = context
        memorySampler.context = context
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initCpuSampler" -> {
                val period = call.argument<Int>("period") ?: 1000
                cpuSampler.start(period.toLong())
                result.success(null)
            }
            "initMemorySampler" -> {
                val period = call.argument<Int>("period") ?: 1000
                memorySampler.start(period.toLong())
                
                // Return physical memory info
                val memInfo = ActivityManager.MemoryInfo()
                val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                activityManager.getMemoryInfo(memInfo)
                
                result.success(mapOf("physicalMemory" to memInfo.totalMem))
            }
            "stopCpuSampler" -> {
                cpuSampler.stop()
                result.success(null)
            }
            "stopMemorySampler" -> {
                memorySampler.stop()
                result.success(null)
            }
            "getCpuSlice" -> {
                val fromNanos = call.argument<String>("fromNanos")?.toLongOrNull() ?: 0L
                val toNanos = call.argument<String>("toNanos")?.toLongOrNull() ?: Long.MAX_VALUE
                val samples = cpuSampler.getSlice(fromNanos, toNanos)
                result.success(mapOf("samples" to samples))
            }
            "getMemorySlice" -> {
                val fromNanos = call.argument<String>("fromNanos")?.toLongOrNull() ?: 0L
                val toNanos = call.argument<String>("toNanos")?.toLongOrNull() ?: Long.MAX_VALUE
                val samples = memorySampler.getSlice(fromNanos, toNanos)
                result.success(mapOf("samples" to samples))
            }
            "getRefreshRate" -> {
                val refreshRate = getDisplayRefreshRate()
                result.success(refreshRate)
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        cpuSampler.stop()
        memorySampler.stop()
    }
    
    private fun getDisplayRefreshRate(): Double {
        return try {
            val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as android.view.WindowManager
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                context.display?.refreshRate?.toDouble() ?: 60.0
            } else {
                @Suppress("DEPRECATION")
                windowManager.defaultDisplay.refreshRate.toDouble()
            }
        } catch (e: Exception) {
            60.0
        }
    }
}

/**
 * Samples CPU usage at regular intervals.
 *
 * Reads per-thread CPU time from /proc/self/task/<tid>/stat so that main-thread
 * and sampler-thread (overhead) values are real measurements rather than
 * approximations.
 */
class CpuSampler {
    var context: Context? = null
    private var timer: Timer? = null
    private val samples = mutableListOf<CpuSample>()
    private val maxSamples = 600 // ~10 minutes at 1s intervals

    private var lastTotalCpuTime = 0L
    private var lastMainThreadCpuTime = 0L
    private var lastSamplerThreadCpuTime = 0L
    private var lastUptime = 0L

    /** Thread ID of the main (UI) thread, captured at start(). */
    private var mainTid = 0L

    /** Thread ID of the sampler thread, captured on first sample(). */
    @Volatile
    private var samplerTid = 0L

    data class CpuSample(
        val total: Double,
        val mainThread: Double,
        val overhead: Double,
        val timestamp: Long
    )

    fun start(periodMs: Long) {
        stop()

        // The main thread is always the process's own PID on Linux/Android.
        mainTid = android.os.Process.myPid().toLong()

        // Initialize baselines
        lastTotalCpuTime = getProcessCpuTime()
        lastMainThreadCpuTime = getThreadCpuTime(mainTid)
        lastUptime = getUptimeMs()

        timer = Timer().apply {
            // Use periodMs as initial delay so the first sample has a real delta.
            scheduleAtFixedRate(periodMs, periodMs) {
                sample()
            }
        }
    }

    fun stop() {
        timer?.cancel()
        timer = null
    }

    private fun sample() {
        // Capture the sampler thread id on the first invocation.
        if (samplerTid == 0L) {
            samplerTid = android.os.Process.myTid().toLong()
            lastSamplerThreadCpuTime = getThreadCpuTime(samplerTid)
        }

        val timestamp = System.currentTimeMillis() * 1_000_000 // nanos

        val currentTotalCpu = getProcessCpuTime()
        val currentMainCpu = getThreadCpuTime(mainTid)
        val currentSamplerCpu = getThreadCpuTime(samplerTid)
        val currentUptime = getUptimeMs()

        val uptimeDelta = currentUptime - lastUptime

        val totalPercent = tickDeltaToPercent(currentTotalCpu - lastTotalCpuTime, uptimeDelta)
        val mainPercent = tickDeltaToPercent(currentMainCpu - lastMainThreadCpuTime, uptimeDelta)
        val overheadPercent = tickDeltaToPercent(currentSamplerCpu - lastSamplerThreadCpuTime, uptimeDelta)

        lastTotalCpuTime = currentTotalCpu
        lastMainThreadCpuTime = currentMainCpu
        lastSamplerThreadCpuTime = currentSamplerCpu
        lastUptime = currentUptime

        val sample = CpuSample(
            total = totalPercent,
            mainThread = mainPercent,
            overhead = overheadPercent,
            timestamp = timestamp
        )

        synchronized(samples) {
            samples.add(sample)
            if (samples.size > maxSamples) {
                samples.removeAt(0)
            }
        }
    }

    fun getSlice(fromNanos: Long, toNanos: Long): List<Map<String, Any>> {
        return synchronized(samples) {
            samples
                .filter { it.timestamp in fromNanos..toNanos }
                .map { mapOf(
                    "total" to it.total,
                    "mainThread" to it.mainThread,
                    "overhead" to it.overhead,
                    "timestamp" to it.timestamp.toString()
                )}
        }
    }

    /** Converts a tick delta into a CPU usage percentage given an elapsed wall-time in ms. */
    private fun tickDeltaToPercent(deltaTicks: Long, uptimeDeltaMs: Long): Double {
        if (uptimeDeltaMs <= 0 || BugsnagPerformanceMetricsPlugin.TICKS_PER_SECOND <= 0L) return 0.0
        val deltaMs = (deltaTicks * 1000L) / BugsnagPerformanceMetricsPlugin.TICKS_PER_SECOND
        return (deltaMs.toDouble() / uptimeDeltaMs.toDouble()) * 100.0
    }

    /**
     * Reads the process-wide CPU time (utime + stime) from /proc/self/stat.
     */
    private fun getProcessCpuTime(): Long {
        return try {
            val content = File("/proc/self/stat").readText()
            parseCpuTimeFromStat(content)
        } catch (e: Exception) {
            0L
        }
    }

    /**
     * Reads per-thread CPU time (utime + stime) from /proc/self/task/<tid>/stat.
     */
    private fun getThreadCpuTime(tid: Long): Long {
        return try {
            val content = File("/proc/self/task/$tid/stat").readText()
            parseCpuTimeFromStat(content)
        } catch (e: Exception) {
            0L
        }
    }

    /**
     * Parses utime + stime from a /proc stat line.
     * Format: pid (comm) state ppid ... utime(14) stime(15) ...
     */
    private fun parseCpuTimeFromStat(content: String): Long {
        val endOfComm = content.indexOf(") ")
        if (endOfComm == -1) return 0L

        val remainder = content.substring(endOfComm + 2).trim()
        val fields = remainder.split(Regex("\\s+"))

        // Field 14 = utime, field 15 = stime. Remainder starts at field 3,
        // so utime is at index 11 and stime is at index 12.
        val utime = fields.getOrNull(11)?.toLongOrNull() ?: 0L
        val stime = fields.getOrNull(12)?.toLongOrNull() ?: 0L
        return utime + stime
    }

    private fun getUptimeMs(): Long {
        return android.os.SystemClock.uptimeMillis()
    }
}

/**
 * Samples memory usage at regular intervals
 */
class MemorySampler {
    var context: Context? = null
    private var timer: Timer? = null
    private val samples = mutableListOf<MemorySample>()
    private val maxSamples = 600

    data class MemorySample(
        val deviceUsed: Long,
        val artSize: Long?,
        val artUsed: Long?,
        val timestamp: Long
    )

    fun start(periodMs: Long) {
        stop()
        timer = Timer().apply {
            scheduleAtFixedRate(0, periodMs) {
                sample()
            }
        }
    }

    fun stop() {
        timer?.cancel()
        timer = null
    }

    private fun sample() {
        val ctx = context ?: return
        val timestamp = System.currentTimeMillis() * 1_000_000
        
        val activityManager = ctx.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val memoryInfo = ActivityManager.MemoryInfo()
        activityManager.getMemoryInfo(memoryInfo)
        
        // Get PSS (Proportional Set Size)
        val pids = intArrayOf(android.os.Process.myPid())
        val memInfoArray = activityManager.getProcessMemoryInfo(pids)
        val deviceUsed = if (memInfoArray.isNotEmpty()) {
            memInfoArray[0].totalPss.toLong() * 1024 // Convert KB to bytes
        } else {
            0L
        }
        
        // Get ART heap info (Android specific)
        val runtime = Runtime.getRuntime()
        val artUsed = runtime.totalMemory() - runtime.freeMemory()
        val artSize = runtime.maxMemory()
        
        val sample = MemorySample(
            deviceUsed = deviceUsed,
            artSize = artSize,
            artUsed = artUsed,
            timestamp = timestamp
        )
        
        synchronized(samples) {
            samples.add(sample)
            if (samples.size > maxSamples) {
                samples.removeAt(0)
            }
        }
    }

    fun getSlice(fromNanos: Long, toNanos: Long): List<Map<String, Any>> {
        return synchronized(samples) {
            samples
                .filter { it.timestamp in fromNanos..toNanos }
                .map { 
                    val map = mutableMapOf<String, Any>(
                        "deviceUsed" to it.deviceUsed.toString(),
                        "timestamp" to it.timestamp.toString()
                    )
                    it.artSize?.let { size -> map["artSize"] = size.toString() }
                    it.artUsed?.let { used -> map["artUsed"] = used.toString() }
                    map
                }
        }
    }
}
