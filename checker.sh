#!/bin/bash

##############################################################################
#                              PUSH SWAP TESTER                              #
##############################################################################
# This script tests push_swap with Valgrind for memory leaks, verifies       #
# correctness with checker, and checks operation counts against limits.      #
# Handles:                                                                   #
# - No args: silent exit with prompt returned.                               #
# - Errors (non-integers, overflow, duplicates): "Error\n" on stderr.        #
# Usage:                                                                     #
#   ./checker.sh test100                # 100 random numbers                 #
#   ./checker.sh test500                # 500 random numbers                 #
#   ./checker.sh specific               # Predefined test cases              #
#   ./checker.sh edge                   # Edge cases                         #
#   ./checker.sh duplicates             # Duplicate numbers                  #
#   ./checker.sh all                    # All tests                          #
# Options:                                                                   #
#   -q, --quiet       No verbose output                                      #
#   -v, --visualize   Use visualizer.py after successful tests               #
# Logs to test_results.log and error_logs directory.                         #
##############################################################################
#                            MADE BY NIRMAL GOPE                             #
##############################################################################

RED="\033[1;31m"
GREEN="\033[1;32m"
BLUE="\033[1;34m"
CYAN="\033[1;36m"
RESET="\033[0m"

LOG_FILE="test_results.log"

log_echo() {
    echo -e "$@"
    echo -e "$@" | sed 's/\x1B\[[0-9;]*m//g' >> "$LOG_FILE"
}

if [ -e "$LOG_FILE" ] && [ ! -w "$LOG_FILE" ]; then
    echo "${RED}❌ $LOG_FILE exists but is not writable${RESET}"
    exit 1
elif ! touch "$LOG_FILE" 2>/dev/null; then
    echo "${RED}❌ Cannot create or write to $LOG_FILE${RESET}"
    exit 1
fi
> "$LOG_FILE"

log_echo "${GREEN}Starting...${RESET}"

BANNER="
${CYAN}
============================================
|                                          |
|         ____   ___   ____   _____        |
|        / ___| / _ \ |  _ \ | ____|       |
|       | |  _ | | | || |_) ||  _|         |
|       | |_| || |_| ||  __/ | |___        |
|        \____| \___/ |_|    |_____|       |
|                                          |
|           N I R M A L   G O P E          |
============================================
${RESET}
"

LIMIT_TEST100=700
LIMIT_TEST500=5500
ITER_TEST100=1
ITER_TEST500=1

PUSH_SWAP="../push_swap"
CHECKER_LINUX="./checker_linux"  
CHECKER_NG="./checker_ng"       
VISUALIZER="./visualizer.py"

ERROR_LOG_DIR="error_logs"

VERBOSE=1
VISUALIZE=0
USE_VALGRIND=0

TESTS=(
    "2 1 3 6 5 8 4"
    "4 67 3 87 23"
    "1 2 3 4 5"
    "3 2 1"
    ""
    "2147483647 -2147483648"
    "1 1 2"
    "abc"
    "0 -1 5 2 -10"
)

FAILED_TESTS=0
TESTS_TO_RUN=()
OP_COUNTS_100=()
OP_COUNTS_500=()

usage() {
    log_echo "${BLUE}Usage: $0 [options] [tests]${RESET}"
    log_echo "${CYAN}Options:${RESET}"
    log_echo "  ${GREEN}-q, --quiet${RESET}       Disable verbose mode"
    log_echo "  ${GREEN}-v, --visualize${RESET}   Launch visualizer.py after tests"
    log_echo "  ${GREEN}-h, --help${RESET}        Show this help"
    log_echo "${CYAN}Tests:${RESET}"
    log_echo "  ${GREEN}test100${RESET}           Test with 100 random numbers"
    log_echo "  ${GREEN}test500${RESET}           Test with 500 random numbers"
    log_echo "  ${GREEN}specific${RESET}          Run predefined test cases"
    log_echo "  ${GREEN}edge${RESET}              Run edge case tests"
    log_echo "  ${GREEN}duplicates${RESET}        Run duplicate tests"
    log_echo "  ${GREEN}all${RESET}               Run all tests"
    exit 1
}

parse_options() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -q|--quiet) VERBOSE=0; shift;;
            -v|--visualize) VISUALIZE=1; shift;;
            -h|--help) usage;;
            test100|test500|specific|edge|duplicates|all) TESTS_TO_RUN+=("$1"); shift;;
            *) log_echo "${RED}Unknown option/test: $1${RESET}"; usage;;
        esac
    done
}

create_error_log_dir() {
    if [ ! -d "$ERROR_LOG_DIR" ]; then
        mkdir "$ERROR_LOG_DIR" || { log_echo "${RED}❌ Failed to create $ERROR_LOG_DIR${RESET}"; exit 1; }
    fi
    rm -f "$ERROR_LOG_DIR"/* 2>/dev/null || log_echo "${CYAN}No previous error logs to delete${RESET}"
}

handle_error_case() {
    local msg="$1"
    local stderr_output="$2"
    log_echo "${BLUE}Stderr Output:${RESET} $stderr_output"
    log_echo "${BLUE}Sorting Instructions:${RESET} (none)"
    log_echo "Number of Operations: 0"
    if [ "$stderr_output" = "Error" ]; then
        log_echo "${GREEN}✅ Passed: Correctly handled $msg with 'Error'${RESET}"
    else
        log_echo "${RED}❌ Failed: Expected 'Error' on stderr for $msg, got: '$stderr_output'${RESET}"
        ((FAILED_TESTS++))
    fi
}

run_push_swap() {
    local stdout_file=$(mktemp)
    local stderr_file=$(mktemp)
    if command -v valgrind >/dev/null 2>&1 && [ "$USE_VALGRIND" -eq 1 ]; then
        valgrind --leak-check=full --log-file=valgrind_output.txt \
                 "$PUSH_SWAP" "$@" >"$stdout_file" 2>"$stderr_file"
    else
        "$PUSH_SWAP" "$@" >"$stdout_file" 2>"$stderr_file"
    fi
    local ret=$?
    local stdout_content=$(cat "$stdout_file")
    local stderr_content=$(cat "$stderr_file")
    rm -f "$stdout_file" "$stderr_file"
    echo "$stdout_content" > stdout_output.txt
    echo "$stderr_content" > stderr_output.txt
    return "$ret"
}

has_duplicates() {
    local input="$1"
    local count=$(echo "$input" | tr ' ' '\n' | sort -n | uniq -d | wc -l)
    [ "$count" -gt 0 ]
}

run_random_test() {
    local size=$1
    local limit=$2
    local iteration=$3
    local description="$4"

    log_echo "----------------------------------------"
    log_echo "${CYAN}Test $iteration: $description${RESET}"

    local ARG
    ARG=$(python3 -c "import random; print(' '.join(map(str, random.sample(range(-1000, 1001), $size))))")
    log_echo "${BLUE}Original Numbers:${RESET} $ARG"

    local output
    output=$(run_push_swap "$ARG")
    local val_ret=$?
    local stdout_content=$(cat stdout_output.txt)
    local stderr_content=$(cat stderr_output.txt)

    if [ "$val_ret" -ne 0 ] && [ "$stderr_content" != "Error" ]; then
        log_echo "${RED}❌ push_swap crashed (exit $val_ret), expected 'Error':${RESET} $stderr_content"
        echo "Crash Output: $stderr_content" > "$ERROR_LOG_DIR/crash_random_${size}_iter${iteration}_$(date +%Y%m%d%H%M%S).txt"
        ((FAILED_TESTS++))
        [ -f valgrind_output.txt ] && mv valgrind_output.txt "$ERROR_LOG_DIR/valgrind_random_${size}_iter${iteration}_$(date +%Y%m%d%H%M%S).txt"
        rm -f stdout_output.txt stderr_output.txt
        return
    fi

    if [ "$stderr_content" = "Error" ]; then
        log_echo "${RED}❌ Unexpected error for valid input: '$stderr_content'${RESET}"
        echo "Unexpected Error: $stderr_content" > "$ERROR_LOG_DIR/error_random_${size}_iter${iteration}_$(date +%Y%m%d%H%M%S).txt"
        ((FAILED_TESTS++))
        rm -f stdout_output.txt stderr_output.txt
        [ -f valgrind_output.txt ] && rm -f valgrind_output.txt
        return
    fi

    if [ "$VERBOSE" -eq 1 ]; then
        log_echo "${BLUE}Sorting Instructions:${RESET}"
        local ops_side_by_side=$(echo "$stdout_content" | tr '\n' ' ')
        log_echo "$ops_side_by_side"
    fi

    local checker_out
    checker_out=$(echo "$stdout_content" | "$CHECKER" "$ARG" 2>/dev/null | tail -n 1)
    [ -z "$checker_out" ] && checker_out="OK"
    if [ "$checker_out" != "OK" ]; then
        log_echo "${RED}❌ Incorrect sorting: $checker_out${RESET}"
        echo "Incorrect Sorting Output: $checker_out" > "$ERROR_LOG_DIR/sorting_random_${size}_iter${iteration}_$(date +%Y%m%d%H%M%S).txt"
        ((FAILED_TESTS++))
        rm -f stdout_output.txt stderr_output.txt
        [ -f valgrind_output.txt ] && rm -f valgrind_output.txt
        return
    fi

    local op_count
    op_count=$(echo "$stdout_content" | grep -v '^$' | wc -l)
    log_echo "Number of Operations: $op_count"
    if [ "$size" -eq 100 ]; then OP_COUNTS_100+=("$op_count"); else OP_COUNTS_500+=("$op_count"); fi
    if [ "$op_count" -le "$limit" ]; then
        log_echo "${GREEN}✅ Passed: $op_count ≤ $limit${RESET}"
    else
        log_echo "${RED}❌ Failed: $op_count > $limit${RESET}"
        echo "Operation Count Exceeded: $op_count > $limit" > "$ERROR_LOG_DIR/count_random_${size}_iter${iteration}_$(date +%Y%m%d%H%M%S).txt"
        ((FAILED_TESTS++))
    fi

    if [ "$VISUALIZE" -eq 1 ]; then
        log_echo "${BLUE}Launching visualizer...${RESET}"
        python3 "$VISUALIZER" $ARG
    fi
    rm -f stdout_output.txt stderr_output.txt
    [ -f valgrind_output.txt ] && rm -f valgrind_output.txt
}

run_test100() {
    log_echo "----------------------------------------"
    log_echo "${CYAN}Running test100 ($ITER_TEST100 iteration, limit=$LIMIT_TEST100)...${RESET}"
    for i in $(seq 1 "$ITER_TEST100"); do
        run_random_test 100 "$LIMIT_TEST100" "$i" "Test100 Iteration $i"
    done
}

run_test500() {
    log_echo "----------------------------------------"
    log_echo "${CYAN}Running test500 ($ITER_TEST500 iteration, limit=$LIMIT_TEST500)...${RESET}"
    for i in $(seq 1 "$ITER_TEST500"); do
        run_random_test 500 "$LIMIT_TEST500" "$i" "Test500 Iteration $i"
    done
}

run_specific_test() {
    local test_case="$1"
    local iteration="$2"
    local description="$3"

    log_echo "----------------------------------------"
    log_echo "${CYAN}Specific Test $iteration: $description${RESET}"
    log_echo "${BLUE}Original Numbers:${RESET} $test_case"

    local output
    local val_ret
    local stdout_content
    local stderr_content

    if [ -z "$test_case" ]; then
        output=$(run_push_swap)
        val_ret=$?
        stdout_content=$(cat stdout_output.txt)
        stderr_content=$(cat stderr_output.txt)
    else
        output=$(run_push_swap "$test_case")
        val_ret=$?
        stdout_content=$(cat stdout_output.txt)
        stderr_content=$(cat stderr_output.txt)
    fi

    if [ -z "$test_case" ]; then
        if [ -z "$stdout_content" ] && [ -z "$stderr_content" ] && [ "$val_ret" -eq 0 ]; then
            log_echo "${BLUE}Stdout Output:${RESET} (none)"
            log_echo "${BLUE}Stderr Output:${RESET} (none)"
            log_echo "${BLUE}Sorting Instructions:${RESET} (none)"
            log_echo "Number of Operations: 0"
            log_echo "${GREEN}✅ Passed: Silent exit for no input${RESET}"
            rm -f stdout_output.txt stderr_output.txt valgrind_output.txt
            return
        else
            log_echo "${RED}❌ Failed: Expected silent exit for no input${RESET}"
            log_echo "${BLUE}Stdout:${RESET} $stdout_content"
            log_echo "${BLUE}Stderr:${RESET} $stderr_content"
            echo "Failed Silent Exit - Stdout: $stdout_content, Stderr: $stderr_content" > "$ERROR_LOG_DIR/error_specific_${iteration}_$(date +%Y%m%d%H%M%S).txt"
            ((FAILED_TESTS++))
            [ -f valgrind_output.txt ] && mv valgrind_output.txt "$ERROR_LOG_DIR/valgrind_specific_${iteration}_$(date +%Y%m%d%H%M%S).txt"
            rm -f stdout_output.txt stderr_output.txt
            return
        fi
    fi

    local should_error=0
    if has_duplicates "$test_case" || echo "$test_case" | grep -Eq '[^0-9 +-]|^[+-] | - | $' || \
       echo "$test_case" | grep -Eq '214748364[8-9]|-214748364[9]' && \
       [ "$test_case" != "2147483647 -2147483648" ]; then
        should_error=1
    fi

    if [ "$should_error" -eq 1 ]; then
        if [ "$stderr_content" = "Error" ] && [ "$val_ret" -ne 0 ] && [ -z "$stdout_content" ]; then
            handle_error_case "$description" "$stderr_content"
            rm -f stdout_output.txt stderr_output.txt valgrind_output.txt
            return
        else
            log_echo "${RED}❌ Failed: Expected 'Error' on stderr for $description${RESET}"
            log_echo "${BLUE}Stdout:${RESET} $stdout_content"
            log_echo "${BLUE}Stderr:${RESET} $stderr_content"
            echo "Failed Error Expectation - Stdout: $stdout_content, Stderr: $stderr_content" > "$ERROR_LOG_DIR/error_specific_${iteration}_$(date +%Y%m%d%H%M%S).txt"
            ((FAILED_TESTS++))
            [ -f valgrind_output.txt ] && mv valgrind_output.txt "$ERROR_LOG_DIR/valgrind_specific_${iteration}_$(date +%Y%m%d%H%M%S).txt"
            rm -f stdout_output.txt stderr_output.txt
            return
        fi
    fi

    if [ "$val_ret" -ne 0 ]; then
        log_echo "${RED}❌ push_swap crashed (exit $val_ret):${RESET}"
        log_echo "${BLUE}Stdout:${RESET} $stdout_content"
        log_echo "${BLUE}Stderr:${RESET} $stderr_content"
        echo "Crash Output: $stderr_content" > "$ERROR_LOG_DIR/crash_specific_${iteration}_$(date +%Y%m%d%H%M%S).txt"
        ((FAILED_TESTS++))
        [ -f valgrind_output.txt ] && mv valgrind_output.txt "$ERROR_LOG_DIR/valgrind_specific_${iteration}_$(date +%Y%m%d%H%M%S).txt"
        rm -f stdout_output.txt stderr_output.txt
        return
    fi

    if [ "$VERBOSE" -eq 1 ]; then
        log_echo "${BLUE}Sorting Instructions:${RESET}"
        log_echo "$stdout_content"
    fi

    local checker_out
    checker_out=$(echo "$stdout_content" | "$CHECKER" "$ARG" 2>/dev/null | tail -n 1)
    [ -z "$checker_out" ] && checker_out="OK"
    if [ "$checker_out" != "OK" ]; then
        log_echo "${RED}❌ Incorrect sorting: $checker_out${RESET}"
        echo "Incorrect Sorting Output: $checker_out" > "$ERROR_LOG_DIR/sorting_specific_${iteration}_$(date +%Y%m%d%H%M%S).txt"
        ((FAILED_TESTS++))
        rm -f stdout_output.txt stderr_output.txt
        [ -f valgrind_output.txt ] && rm -f valgrind_output.txt
        return
    fi

    local op_count
    op_count=$(echo "$stdout_content" | grep -v '^$' | wc -l)
    log_echo "Number of Operations: $op_count"
    log_echo "${GREEN}✅ Passed${RESET}"

    if [ "$VISUALIZE" -eq 1 ]; then
        log_echo "${BLUE}Launching visualizer...${RESET}"
        python3 "$VISUALIZER" $test_case
    fi
    rm -f stdout_output.txt stderr_output.txt
    [ -f valgrind_output.txt ] && rm -f valgrind_output.txt
}

run_specific_tests() {
    log_echo "${CYAN}Running Predefined Specific Tests...${RESET}"
    local i=1
    for test_case in "${TESTS[@]}"; do
        if [ "$test_case" = "2147483647 -2147483648" ]; then
            run_specific_test "$test_case" "$i" "Predefined Test $i (Max/Min Integers)"
        else
            run_specific_test "$test_case" "$i" "Predefined Test $i"
        fi
        ((i++))
    done
}

run_edge_tests() {
    log_echo "----------------------------------------"
    log_echo "${CYAN}Running Edge Case Tests...${RESET}"
    run_specific_test "1 2 3 4 5"         "1" "Already Sorted"
    run_specific_test "5 4 3 2 1"         "2" "Reverse Sorted"
    run_specific_test "42"                "3" "Single Number"
    run_specific_test "2 1"               "4" "Two Numbers"
    run_specific_test "2147483648"        "5" "Overflow"
    run_specific_test "-2147483649"       "6" "Underflow"
}

run_duplicate_tests() {
    log_echo "${CYAN}Running Duplicate Tests...${RESET}"
    run_specific_test "1 2 2 3"           "1" "Duplicates"
    run_specific_test "5 5 5"             "2" "All Same"
}

calculate_average() {
    local -a counts=("$@")
    local sum=0
    local count=${#counts[@]}
    [ "$count" -eq 0 ] && return
    for num in "${counts[@]}"; do
        ((sum += num))
    done
    echo $((sum / count))
}

log_echo "$BANNER"
parse_options "$@"

if [ -f "$CHECKER_LINUX" ] && [ -x "$CHECKER_LINUX" ]; then
    CHECKER="$CHECKER_LINUX"
    log_echo "${GREEN}Using checker_linux as checker program${RESET}"
elif [ -f "$CHECKER_NG" ] && [ -x "$CHECKER_NG" ]; then
    CHECKER="$CHECKER_NG"
    log_echo "${CYAN}checker_linux not available or not executable, falling back to checker_ng${RESET}"
else
    log_echo "${RED}❌ Neither checker_linux nor checker_ng found or executable in tester folder${RESET}"
    exit 1
fi

if [ ! -x "$PUSH_SWAP" ]; then
    log_echo "${RED}❌ $PUSH_SWAP not found or not executable.${RESET}"
    exit 1
fi
if [ "$VISUALIZE" -eq 1 ] && [ ! -f "$VISUALIZER" ]; then
    log_echo "${RED}❌ $VISUALIZER not found.${RESET}"
    exit 1
fi

create_error_log_dir

if command -v valgrind >/dev/null 2>&1; then
    USE_VALGRIND=1
    log_echo "${GREEN}Valgrind detected, running with memory checks.${RESET}"
else
    log_echo "${CYAN}Valgrind not found, running without memory checks.${RESET}"
fi

[ "$VERBOSE" -eq 1 ] && log_echo "${GREEN}Verbose mode ON${RESET}" || log_echo "${CYAN}Verbose mode OFF${RESET}"
[ "$VISUALIZE" -eq 1 ] && log_echo "${BLUE}Visualizer mode ON${RESET}" || log_echo "Visualizer mode OFF"

if [ ${#TESTS_TO_RUN[@]} -eq 0 ]; then
    TESTS_TO_RUN=("test100" "test500" "edge" "duplicates" "specific")
fi

for test_item in "${TESTS_TO_RUN[@]}"; do
    case "$test_item" in
        test100) run_test100;;
        test500) run_test500;;
        specific) run_specific_tests;;
        edge) run_edge_tests;;
        duplicates) run_duplicate_tests;;
        all) run_test100; run_test500; run_edge_tests; run_duplicate_tests; run_specific_tests;;
    esac
done

log_echo "----------------------------------------"
log_echo "Test Summary:"
log_echo "Total Failed Tests: $FAILED_TESTS"
if [ ${#OP_COUNTS_100[@]} -gt 0 ]; then
    avg_100=$(calculate_average "${OP_COUNTS_100[@]}")
    log_echo "Number of Operations (Test100): $avg_100"
fi
if [ ${#OP_COUNTS_500[@]} -gt 0 ]; then
    avg_500=$(calculate_average "${OP_COUNTS_500[@]}")
    log_echo "Number of Operations (Test500): $avg_500"
fi
if [ "$FAILED_TESTS" -gt 0 ]; then
    log_echo "${RED}❌ Check logs:${RESET}"
    log_echo "Log file: file://$(realpath "$LOG_FILE")"
    log_echo "Error logs directory: file://$(realpath "$ERROR_LOG_DIR")"
else
    log_echo "${GREEN}✅ All tests passed!${RESET}"
    log_echo "Log file: file://$(realpath "$LOG_FILE")"
fi
log_echo "----------------------------------------"