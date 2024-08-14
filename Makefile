FLUTTER_BIN?=flutter
PRESET_VERSION=$(shell cat VERSION)

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
	@echo $(VERSION) > VERSION
	sed -i '' "s/## TBD/## $(VERSION) ($(shell date '+%Y-%m-%d'))/" CHANGELOG.md
	sed -i '' "s/^version: .*/version: $(VERSION)/" packages/bugsnag_flutter_performance/pubspec.yaml
	
publish_dry:
	cd staging/bugsnag_flutter_performance && $(FLUTTER_BIN) pub publish --dry-run


stage:
	mkdir -p staging/bugsnag_flutter_performance
	cd packages/bugsnag_flutter_performance && cp -a . ../../staging/bugsnag_flutter_performance
	rm -f staging/bugsnag_flutter_performance/pubspec.lock
	cp -r example staging/bugsnag_flutter_performance/example
	cp README.md staging/bugsnag_flutter_performance/.
	cp LICENSE staging/bugsnag_flutter_performance/.
	cp CHANGELOG.md staging/bugsnag_flutter_performance/.
	sed -i '' -e '1,2d' staging/bugsnag_flutter_performance/CHANGELOG.md

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
	
prerelease: bump stage publish_dry ## Generates a PR for the $VERSION release
ifeq ($(VERSION),)
	@$(error VERSION is not defined. Run with `make VERSION=number prerelease`)
endif
	rm -rf staging
	@git checkout -b release-v$(VERSION)
	@git add packages/bugsnag_flutter_performance/pubspec.yaml CHANGELOG.md VERSION
	@git diff --exit-code || (echo "you have unstaged changes - Makefile may need updating to `git add` some more files"; exit 1)
	@git commit -m "Release v$(VERSION)"
	@git push origin release-v$(VERSION)
	@open "https://github.com/bugsnag/bugsnag-flutter-performance/compare/main...release-v$(VERSION)?expand=1&title=Release%20v$(VERSION)&body="$$(awk 'start && /^## /{exit;};/^## /{start=1;next};start' CHANGELOG.md | hexdump -v -e '/1 "%02x"' | sed 's/\(..\)/%\1/g')

release: stage publish_dry ## Releases the current main branch as $VERSION
	@git fetch origin
ifneq ($(shell git rev-parse --abbrev-ref HEAD),main) # Check the current branch name
	@git checkout main
	@git rebase origin/main
endif
ifneq ($(shell git diff origin/main..main),)
	$(error you have unpushed commits on the main branch)
endif
	@git tag v$(PRESET_VERSION)
	@git push origin v$(PRESET_VERSION)
	@git checkout next
	@git rebase origin/next
	@git merge main
	@git push origin next
	# Prep GitHub release
	# We could technically do a `hub release` here but a verification step
	# before it goes live always seems like a good thing
	@open 'https://github.com/bugsnag/bugsnag-flutter-performance/releases/new?title=v$(PRESET_VERSION)&tag=v$(PRESET_VERSION)&body='$$(awk 'start && /^## /{exit;};/^## /{start=1;next};start' CHANGELOG.md | hexdump -v -e '/1 "%02x"' | sed 's/\(..\)/%\1/g')
	cd staging/bugsnag_flutter_performance && $(FLUTTER_BIN) pub publish
	rm -rf staging
