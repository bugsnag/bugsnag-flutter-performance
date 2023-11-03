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

bump:
ifeq ($(VERSION),)
	@$(error VERSION is not defined. Run with `make VERSION=number bump`)
endif
	sed -i '' "s/## TBD/## $(VERSION) ($(shell date '+%Y-%m-%d'))/" CHANGELOG.md
	sed -i '' "s/^version: .*/version: $(VERSION)/" packages/bugsnag_flutter_performance/pubspec.yaml

prerelease: bump
ifeq ($(VERSION),)
	@$(error VERSION is not defined. Run with `make VERSION=number prerelease`)
endif
	@git checkout -b release-v$(VERSION)
	@git add CHANGELOG.md packages/bugsnag_flutter_performance/pubspec.yaml
	@git diff --exit-code || (echo "you have unstaged changes - Makefile may need updating to `git add` some more files"; exit 1)
	@git commit -m "Release v$(VERSION)"
	@git push origin release-v$(VERSION)
	@open "https://github.com/bugsnag/bugsnag-flutter-performance/compare/main...release-v$(VERSION)?expand=1&title=Release%20v$(VERSION)&body="$$(awk 'start && /^## /{exit;};/^## /{start=1;next};start' CHANGELOG.md | hexdump -v -e '/1 "%02x"' | sed 's/\(..\)/%\1/g')
	
release: ## Releases the current main branch as $VERSION
	@git fetch origin
ifneq ($(shell git rev-parse --abbrev-ref HEAD),main) # Check the current branch name
	@git checkout main
	@git rebase origin/main
endif
ifneq ($(shell git diff origin/main..main),)
	$(error you have unpushed commits on the main branch)
endif
	@git tag v$(PRESET_VERSION)
	# Swift Package Manager prefers tags to be unprefixed package versions
	@git tag $(PRESET_VERSION)
	@git push origin v$(PRESET_VERSION) $(PRESET_VERSION)
	@git checkout next
	@git rebase origin/next
	@git merge main
	@git push origin next
	# Prep GitHub release
	# We could technically do a `hub release` here but a verification step
	# before it goes live always seems like a good thing
	@open 'https://github.com/bugsnag/bugsnag-flutter-performance/releases/new?title=v$(PRESET_VERSION)&tag=v$(PRESET_VERSION)&body='$$(awk 'start && /^## /{exit;};/^## /{start=1;next};start' CHANGELOG.md | hexdump -v -e '/1 "%02x"' | sed 's/\(..\)/%\1/g')
	@git clean -df
	cd packages/bugsnag_flutter_performance && flutter pub publish

aar:
	cd packages/bugsnag_flutter_performance && $(FLUTTER_BIN) build aar --suppress-analytics

examples/bugsnag_performance_example:
	cd $@ && $(FLUTTER_BIN) pub get
	cd $@ && $(FLUTTER_BIN) build apk --suppress-analytics
	cd $@ && $(FLUTTER_BIN) build ios --no-codesign --suppress-analytics --no-tree-shake-icons

test:
	cd packages/bugsnag_flutter_performance && $(FLUTTER_BIN) test -r expanded --suppress-analytics

format:
	dart format packages/bugsnag_flutter_performance example features/fixtures/app

lint:
	cd packages/bugsnag_flutter_performance && $(FLUTTER_BIN) analyze --suppress-analytics
