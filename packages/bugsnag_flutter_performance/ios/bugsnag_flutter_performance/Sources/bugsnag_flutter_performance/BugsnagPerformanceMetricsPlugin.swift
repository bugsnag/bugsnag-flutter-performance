import Flutter
import UIKit
import Foundation

/**
 * Plugin for collecting CPU and Memory performance metrics on iOS
 */
public class BugsnagPerformanceMetricsPlugin: NSObject, FlutterPlugin {
    private let cpuSampler = CpuSampler()
    private let memorySampler = MemorySampler()
    
    /// The mach port of the main thread, captured during plugin registration (which runs on main).
    fileprivate static var mainMachThread: mach_port_t = 0
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        mainMachThread = mach_thread_self()
        let channel = FlutterMethodChannel(
            name: "bugsnag_performance_metrics",
            binaryMessenger: registrar.messenger()
        )
        let instance = BugsnagPerformanceMetricsPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initCpuSampler":
            if let args = call.arguments as? [String: Any],
               let period = args["period"] as? Int {
                cpuSampler.start(periodMs: TimeInterval(period) / 1000.0)
            }
            result(nil)
            
        case "initMemorySampler":
            if let args = call.arguments as? [String: Any],
               let period = args["period"] as? Int {
                memorySampler.start(periodMs: TimeInterval(period) / 1000.0)
            }
            
            // Return physical memory info
            let physicalMemory = ProcessInfo.processInfo.physicalMemory
            result(["physicalMemory": String(physicalMemory)])
            
        case "stopCpuSampler":
            cpuSampler.stop()
            result(nil)
            
        case "stopMemorySampler":
            memorySampler.stop()
            result(nil)
            
        case "getCpuSlice":
            if let args = call.arguments as? [String: Any],
               let fromNanosStr = args["fromNanos"] as? String,
               let toNanosStr = args["toNanos"] as? String,
               let fromNanos = Int64(fromNanosStr),
               let toNanos = Int64(toNanosStr) {
                let samples = cpuSampler.getSlice(fromNanos: fromNanos, toNanos: toNanos)
                result(["samples": samples])
            } else {
                result(["samples": []])
            }
            
        case "getMemorySlice":
            if let args = call.arguments as? [String: Any],
               let fromNanosStr = args["fromNanos"] as? String,
               let toNanosStr = args["toNanos"] as? String,
               let fromNanos = Int64(fromNanosStr),
               let toNanos = Int64(toNanosStr) {
                let samples = memorySampler.getSlice(fromNanos: fromNanos, toNanos: toNanos)
                result(["samples": samples])
            } else {
                result(["samples": []])
            }
            
        case "getRefreshRate":
            let refreshRate = UIScreen.main.maximumFramesPerSecond
            result(Double(refreshRate))
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

/**
 * Samples CPU usage at regular intervals using task_info and thread_info
 */
class CpuSampler {
    private var timer: Timer?
    private var samples: [CpuSample] = []
    private let maxSamples = 600
    private let samplesLock = NSLock()
    
    struct CpuSample {
        let total: Double
        let mainThread: Double
        let overhead: Double
        let timestamp: Int64
    }
    
    func start(periodMs: TimeInterval) {
        stop()
        timer = Timer.scheduledTimer(withTimeInterval: periodMs, repeats: true) { [weak self] _ in
            self?.sample()
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    private func sample() {
        let timestamp = Int64(Date().timeIntervalSince1970 * 1_000_000_000)
        
        let cpuUsage = getCpuUsage()
        
        let sample = CpuSample(
            total: cpuUsage.total,
            mainThread: cpuUsage.mainThread,
            overhead: cpuUsage.overhead,
            timestamp: timestamp
        )
        
        samplesLock.lock()
        samples.append(sample)
        if samples.count > maxSamples {
            samples.removeFirst()
        }
        samplesLock.unlock()
    }
    
    func getSlice(fromNanos: Int64, toNanos: Int64) -> [[String: Any]] {
        samplesLock.lock()
        defer { samplesLock.unlock() }
        
        return samples
            .filter { $0.timestamp >= fromNanos && $0.timestamp <= toNanos }
            .map { [
                "total": $0.total,
                "mainThread": $0.mainThread,
                "overhead": $0.overhead,
                "timestamp": String($0.timestamp)
            ]}
    }
    
    private func getCpuUsage() -> (total: Double, mainThread: Double, overhead: Double) {
        var threadsList: thread_act_array_t?
        var threadsCount = mach_msg_type_number_t(0)
        let threadsResult = task_threads(mach_task_self_, &threadsList, &threadsCount)
        
        guard threadsResult == KERN_SUCCESS, let threads = threadsList else {
            return (0, 0, 0)
        }
        
        var totalCpu: Double = 0
        var mainThreadCpu: Double = 0
        var overheadCpu: Double = 0
        let samplerThread = pthread_mach_thread_np(pthread_self())
        
        for i in 0..<Int(threadsCount) {
            var threadInfo = thread_basic_info()
            var threadInfoCount = mach_msg_type_number_t(THREAD_INFO_MAX)
            
            let infoResult = withUnsafeMutablePointer(to: &threadInfo) {
                $0.withMemoryRebound(to: integer_t.self, capacity: Int(threadInfoCount)) {
                    thread_info(threads[i], thread_flavor_t(THREAD_BASIC_INFO), $0, &threadInfoCount)
                }
            }
            
            if infoResult == KERN_SUCCESS {
                let cpuUsage = Double(threadInfo.cpu_usage) / Double(TH_USAGE_SCALE) * 100.0
                totalCpu += cpuUsage
                
                if threads[i] == BugsnagPerformanceMetricsPlugin.mainMachThread {
                    mainThreadCpu = cpuUsage
                }
                if threads[i] == samplerThread {
                    overheadCpu = cpuUsage
                }
            }
        }
        
        // Deallocate threads list
        vm_deallocate(mach_task_self_, vm_address_t(bitPattern: threads), vm_size_t(Int(threadsCount) * MemoryLayout<thread_t>.stride))
        
        return (totalCpu, mainThreadCpu, overheadCpu)
    }
}

/**
 * Samples memory usage at regular intervals using task_info
 */
class MemorySampler {
    private var timer: Timer?
    private var samples: [MemorySample] = []
    private let maxSamples = 600
    private let samplesLock = NSLock()
    
    struct MemorySample {
        let deviceUsed: Int64
        let timestamp: Int64
    }
    
    func start(periodMs: TimeInterval) {
        stop()
        timer = Timer.scheduledTimer(withTimeInterval: periodMs, repeats: true) { [weak self] _ in
            self?.sample()
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    private func sample() {
        let timestamp = Int64(Date().timeIntervalSince1970 * 1_000_000_000)
        let memoryUsage = getMemoryUsage()
        
        let sample = MemorySample(
            deviceUsed: memoryUsage,
            timestamp: timestamp
        )
        
        samplesLock.lock()
        samples.append(sample)
        if samples.count > maxSamples {
            samples.removeFirst()
        }
        samplesLock.unlock()
    }
    
    func getSlice(fromNanos: Int64, toNanos: Int64) -> [[String: Any]] {
        samplesLock.lock()
        defer { samplesLock.unlock() }
        
        return samples
            .filter { $0.timestamp >= fromNanos && $0.timestamp <= toNanos }
            .map { [
                "deviceUsed": String($0.deviceUsed),
                "timestamp": String($0.timestamp)
            ]}
    }
    
    private func getMemoryUsage() -> Int64 {
        var taskInfo = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        
        if result == KERN_SUCCESS {
            // phys_footprint is the physical memory footprint of the process
            return Int64(taskInfo.phys_footprint)
        }
        
        return 0
    }
}
