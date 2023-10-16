FLUTTER_BIN?=flutter

all: format build lint test

.PHONY: clean build bump aar examples/bugsnag_performance_example test format lint e2e_android_local e2e_ios_local

clean:
	cd packages/bugsnag_flutter_performance && $(FLUTTER_BIN) clean --suppress-analytics
	cd examples/bugsnag_performance_example && $(FLUTTER_BIN) clean --suppress-analytics && \
			rm -rf .idea bugsnag_flutter_performance_example.iml \
			       ios/{Pods,.symlinks,Podfile.lock} \
				   ios/{Runner.xcworkspace,Runner.xcodeproj,Runner.xcodeproj/project.xcworkspace}/xcuserdata \
				   android/{.idea,.gradle,gradlew,gradlew.bat,local.properties,bugsnag_flutter_performance_example_android.iml}
	rm -rf staging

build: aar examples/bugsnag_performance_example

aar:
	cd packages/bugsnag_flutter_performance && $(FLUTTER_BIN) build aar --suppress-analytics

examples/bugsnag_performance_example:
	cd $@ && $(FLUTTER_BIN) pub get
	cd $@ && $(FLUTTER_BIN) build apk --suppress-analytics
	cd $@ && $(FLUTTER_BIN) build ios --no-codesign --suppress-analytics --no-tree-shake-icons

test:
	cd packages/bugsnag_flutter_performance && $(FLUTTER_BIN) test -r expanded --suppress-analytics

format:
	$(FLUTTER_BIN) format packages/bugsnag_flutter_performance example features/fixtures/app

lint:
	cd packages/bugsnag_flutter_performance && $(FLUTTER_BIN) analyze --suppress-analytics
