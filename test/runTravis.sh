#!/usr/bin/env bash
set -e

NODE="node"
PART="$TEST_PART"
CABAL="cabal"
GHCJSBOOT="ghcjs-boot"
TESTRUNNER="./dist/build/test/test"

travis_boot() {
    case "$PART" in
        CORE-GHC|CORE-CONC|CORE-INTEGER|CORE-PKG|CORE-FAY)
            ghcjs_boot -j2 --build-stage1-unbooted --no-prof
            cabal_install random QuickCheck stm syb
        ;;
        PROFILING)
            ghcjs_boot -j2 --build-stage1-unbooted
        ;;
        GHCJS)
            ghcjs_boot -j1 --no-prof
        ;;
        *)
            echo $"Unknown test part: $PART"
            exit 1
    esac
}

travis_test() {
    case "$PART" in
        CORE-GHC)
            run_tests --no-profiling -t ghc
        ;;
        CORE-CONC)
            run_tests --no-profiling -t conc
        ;;
        CORE-INTEGER)
            run_tests --no-profiling -t integer
        ;;
        CORE-PKG)
            run_tests --no-profiling -t pkg
        ;;
        CORE-FAY)
            run_tests --no-profiling -t fay
        ;;
        PROFILING)
            run_tests -t profiling
        ;;
        GHCJS)
            run_tests --no-profiling -t ffi
        ;;
        *)
            echo $"Unknown test part: $PART"
            exit 1
    esac
}

ghcjs_boot() {
	case "$TRAVIS_BRANCH" in
		master)
			export BRANCH=master
		;;
		# Default to master
		*)
			export BRANCH=master
		;;
	esac
    "$GHCJSBOOT" --dev --ghcjs-boot-dev-branch "$BRANCH" --shims-dev-branch "$BRANCH" --no-haddock --with-node "$NODE" "$@"
}

cabal_install() {
    "$CABAL" install -j2 --ghcjs "$@"
}

run_tests() {
    "$TESTRUNNER" --travis --with-node="$NODE" "$@" -j2
}

case "$1" in
    boot)
      travis_boot
      ;;
    "test")
      travis_test
      ;;
    *)
      echo $"Usage: $0 {boot|test}"
      exit 1
esac
