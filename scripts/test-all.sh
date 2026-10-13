#!/bin/bash
# Runs the unit tests once per language: builds each suite from its test-<lang>.jungle, runs it in the
# Connect IQ simulator and prints one PASSED or FAILED line per language. Exits 0 only when every suite
# passes.
#
# Usage:  DEVELOPER_KEY=/path/to/developer_key.der scripts/test-all.sh [lang ...]
#         With no language given, every test-<lang>.jungle in the project runs.
#
# Environment:
#   DEVELOPER_KEY  key that signs the test builds (required; any developer key works for tests)
#   CIQ_SDK        Connect IQ SDK folder (default: the SDK chosen in the SDK Manager, else the one that
#                  holds the monkeyc on the PATH)
#   TEST_OUT       folder for the builds and their logs (default: bin/test)
#   TEST_TIMEOUT   seconds a run may take before it counts as hung (default: 180)
#
# Needs a running simulator (connectiq &), Java 17 or later on the PATH, and perl (part of macOS).
#
# Each suite is that language's strings put over the base ones, plus that language's pins (see
# test-spa.jungle). A build warning fails the suite: a string a translation leaves out shows up as one
# ("String id ... undefined for language ..."). A run talks to the simulator through MonkeyDoDeux, which
# this script starts in its own process group: a run that hangs is stopped at the timeout together with
# everything it started, so it leaves no client connected to the simulator, and is tried once more. A
# run's result counts only when its output names its own suite ("suite=<lang>", logged by the pins).
set -u
cd "$(dirname "$0")/.." || exit 2

DEVICE=instinct2
OUT="${TEST_OUT:-bin/test}"
TIMEOUT="${TEST_TIMEOUT:-180}"
SDK_CONFIG="$HOME/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg"

if [ -z "${DEVELOPER_KEY:-}" ] || [ ! -f "$DEVELOPER_KEY" ]; then
    echo "Set DEVELOPER_KEY to a developer key file (.der)." >&2
    exit 2
fi

SDK="${CIQ_SDK:-}"
if [ -z "$SDK" ] && [ -f "$SDK_CONFIG" ]; then
    SDK="$(head -n 1 "$SDK_CONFIG")"
fi
if [ -z "$SDK" ] && command -v monkeyc > /dev/null; then
    SDK="$(dirname "$(dirname "$(command -v monkeyc)")")"
fi
SDK="${SDK%/}"
if [ ! -x "$SDK/bin/monkeyc" ]; then
    echo "Connect IQ SDK not found: set CIQ_SDK to its folder." >&2
    exit 2
fi

if [ $# -gt 0 ]; then
    LANGUAGES=("$@")
else
    LANGUAGES=()
    for jungle in test-*.jungle; do
        [ -f "$jungle" ] || continue
        lang="${jungle#test-}"
        LANGUAGES+=("${lang%.jungle}")
    done
fi
if [ ${#LANGUAGES[@]} -eq 0 ]; then
    echo "No test-<lang>.jungle found." >&2
    exit 2
fi

mkdir -p "$OUT"

# Runs a test build in the simulator, its output in a log. MonkeyDoDeux is what the SDK's monkeydo script
# starts; running it directly, in a new process group, lets the timeout stop it and every process it
# started. Exit status 124 means the run hung.
run_suite() {
    local prg="$1" log="$2"
    perl -e '
        my $timeout = shift;
        my $pid = fork();
        die "fork: $!\n" unless defined $pid;
        if ($pid == 0) {
            setpgrp(0, 0);
            exec @ARGV or die "exec: $!\n";
        }
        $SIG{ALRM} = sub { kill "TERM", -$pid; sleep 1; kill "KILL", -$pid; exit 124; };
        alarm $timeout;
        waitpid($pid, 0);
        my $status = $? >> 8;
        alarm 0;
        kill "TERM", -$pid;
        exit $status;
    ' "$TIMEOUT" java -classpath "$SDK/bin/monkeybrains.jar" com.garmin.monkeybrains.monkeydodeux.MonkeyDoDeux \
        -f "$prg" -d "$DEVICE" -s "$SDK/bin/shell" -t > "$log" 2>&1
}

# The suite's result line, "PASSED (passed=N, failed=0, errors=0)" or "FAILED (...)", when the log holds
# this suite's own output; nothing otherwise. (monkeydo -t exits 1 even when every test passes, so the exit
# status says nothing.)
suite_result() {
    local lang="$1" log="$2"
    grep -Eq "suite=$lang\$" "$log" || return 0
    grep -E '^(PASSED|FAILED) \(passed=' "$log" | tail -n 1
}

failed=0
for lang in "${LANGUAGES[@]}"; do
    jungle="test-$lang.jungle"
    prg="$OUT/RosarioTest-$lang.prg"
    build_log="$OUT/RosarioTest-$lang.build.log"
    run_log="$OUT/RosarioTest-$lang.log"
    if [ ! -f "$jungle" ]; then
        echo "$lang FAILED (no $jungle)"
        failed=1
        continue
    fi
    if ! "$SDK/bin/monkeyc" -f "$jungle" -d "$DEVICE" -o "$prg" -y "$DEVELOPER_KEY" -w -t > "$build_log" 2>&1; then
        echo "$lang FAILED (build): $build_log"
        failed=1
        continue
    fi
    warnings="$(grep -c 'WARNING' "$build_log")"
    if [ "$warnings" -gt 0 ]; then
        echo "$lang FAILED ($warnings build warnings): $build_log"
        failed=1
        continue
    fi
    result=""
    for attempt in 1 2; do
        run_suite "$prg" "$run_log"
        result="$(suite_result "$lang" "$run_log")"
        [ -n "$result" ] && break
    done
    if [ -z "$result" ]; then
        echo "$lang FAILED (no result from the simulator after 2 runs): $run_log"
        failed=1
    elif [ "${result%% *}" = "PASSED" ]; then
        echo "$lang $result"
    else
        echo "$lang $result: $run_log"
        failed=1
    fi
done
exit $failed
