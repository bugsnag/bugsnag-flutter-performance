FLUTTER_BIN?=flutter

all: format build lint test

.PHONY: clean build bump aar example/bugsnag_performance_example test format lint e2e_android_local e2e_ios_local

clean:
	cd package/bugsnag_flutter_performance && $(FLUTTER_BIN) clean --suppress-analytics
	cd example/bugsnag_performance_example && $(FLUTTER_BIN) clean --suppress-analytics && \
			rm -rf .idea bugsnag_flutter_performance_example.iml \
			       ios/{Pods,.symlinks,Podfile.lock} \
				   ios/{Runner.xcworkspace,Runner.xcodeproj,Runner.xcodeproj/project.xcworkspace}/xcuserdata \
				   android/{.idea,.gradle,gradlew,gradlew.bat,local.properties,bugsnag_flutter_performance_example_android.iml}
	rm -rf staging

build: aar example/bugsnag_performance_example

bump:
ifeq ($(VERSION),)
	@$(error VERSION is not defined. Run with `make VERSION=number bump`)
endif
	sed -i '' "s/## TBD/## $(VERSION) ($(shell date '+%Y-%m-%d'))/" CHANGELOG.md
	sed -i '' "s/^version: .*/version: $(VERSION)/" packages/bugsnag_flutter_performance/pubspec.yaml

BSG_BRIDGE_VERSION:=$(shell grep 'version: ' packages/bugsnag-flutter-common/packages/bugsnag_bridge/pubspec.yaml | grep -o '[0-9].*')
staging: staging
	mkdir -p staging/bugsnag_flutter_performance
	cd packages/bugsnag_flutter_performance && cp -a . ../../staging/bugsnag_flutter_performance
	rm -f staging/bugsnag_flutter_performance/pubspec.lock
	cp -r example staging/bugsnag_flutter_performance/example
	cp README.md staging/bugsnag_flutter_performance/.
	cp LICENSE staging/bugsnag_flutter_performance/.
	cp CHANGELOG.md staging/bugsnag_flutter_performance/.
	sed -i '' -e '1,2d' staging/bugsnag_flutter_performance/CHANGELOG.md
	sed -i '' "s/^  bugsnag_bridge:.*/  bugsnag_bridge: ^$(BSG_BRIDGE_VERSION)/" staging/bugsnag_flutter_performance/pubspec.yaml
	sed -i '' "s/path:.*/ /;s/publish_to: none/ /" staging/bugsnag_flutter_performance/pubspec.yaml

aar:
	cd packages/bugsnag_flutter_performance && $(FLUTTER_BIN) build aar --suppress-analytics

example/bugsnag_performance_example:
	cd $@ && $(FLUTTER_BIN) pub get
	cd $@ && $(FLUTTER_BIN) build apk --suppress-analytics
	cd $@ && $(FLUTTER_BIN) build ios --no-codesign --suppress-analytics --no-tree-shake-icons

test:
	cd packages/bugsnag_flutter_performance && $(FLUTTER_BIN) test -r expanded --suppress-analytics

format:
	dart format packages/bugsnag_flutter_performance example features/fixture_resources/lib

lint:
	cd packages/bugsnag_flutter_performance && $(FLUTTER_BIN) analyze --suppress-analytics
