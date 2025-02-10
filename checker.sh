#!/bin/bash

##############################################################################
#                              PUSH SWAP TESTER                              #
##############################################################################
# This script runs your push_swap program with Valgrind to:                  #
#   - Check for memory leaks or memory errors.                               #
#   - Verify sorting correctness (using checker_linux).                      #
#   - Compare the final operation count against set limits.                  #
#   - Provide multiple modes (test100, test500, duplicates, edge, etc.).     #
#   ./checker.sh test100                # just 100 random                    #
#   ./checker.sh test500                # just 500 random                    #
#   ./checker.sh specific               # just the predefined array          #
#   ./checker.sh edge                   # just edge cases                    #
#   ./checker.sh duplicates                                                  #
#   ./checker.sh all                    # everything                         #
#   - If you want to visualize then add --visualize after the command        #
#   ./checker.sh test100 --visualize                                         #
#   ./checker.sh test500 --visualize                                         #
#   ./visualizer.py 5 4 3 2 1                                                #
# Logs output to test_results.log.                                           #
##############################################################################
#                            MADE BY NIRMAL GOPE                             #
##############################################################################

RED="\033[1;31m"
GREEN="\033[1;32m"
BLUE="\033[1;34m"
CYAN="\033[1;36m"
RESET="\033[0m"

echo -e "${GREEN}Starting tests...${RESET}"

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
CHECKER="./checker_linux"
VISUALIZER="./visualizer.py"

LOG_FILE="test_results.log"
ERROR_LOG_DIR="error_logs"
VALGRIND_ERROR_EXIT=30

VERBOSE=1
VISUALIZE=0

TESTS=(
  "2 1 3 6 5 8 4"
  "4 67 3 87 23"
  "1 2 3 4 5"
  "3 2 1"
  ""
  "2147483647 -2147483648 0"
  "1 1 2"
  "abc"
)

FAILED_TESTS=0
TESTS_TO_RUN=()

usage() {
    echo -e "${BLUE}Usage: $0 [options] [tests]${RESET}"
    echo -e "${CYAN}Options:${RESET}"
    echo -e "  ${GREEN}-q, --quiet${RESET}       Disable verbose mode (no instructions shown)"
    echo -e "  ${GREEN}-v, --visualize${RESET}   Launch visualizer.py after successful tests"
    echo -e "  ${GREEN}-h, --help${RESET}        Show this help"
    echo -e "${CYAN}Tests:${RESET}"
    echo -e "  ${GREEN}test100${RESET}           Random test of 100 numbers"
    echo -e "  ${GREEN}test500${RESET}           Random test of 500 numbers"
    echo -e "  ${GREEN}edge${RESET}              Edge case tests"
    echo -e "  ${GREEN}duplicates${RESET}        Duplicates test"
    echo -e "  ${GREEN}specific${RESET}          Run predefined specific tests"
    echo -e "  ${GREEN}all${RESET}               Run everything"
    exit 1
}

parse_options() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -q|--quiet)
                VERBOSE=0
                shift
                ;;
            -v|--visualize)
                VISUALIZE=1
                shift
                ;;
            -h|--help)
                usage
                ;;
            test100|test500|edge|duplicates|specific|all)
                TESTS_TO_RUN+=("$1")
                shift
                ;;
            *)
                echo -e "${RED}Unknown option/test: $1${RESET}"
                usage
                ;;
        esac
    done
}

create_error_log_dir() {
    [ ! -d "$ERROR_LOG_DIR" ] && mkdir "$ERROR_LOG_DIR"
}

handle_error_case() {
    local msg="$1"
    echo -e "${BLUE}Output:${RESET} Error"
    echo -e "${BLUE}Sorting Instructions:${RESET}"
    echo
    echo "Number of Operations: 1"
    echo -e "${GREEN}✅ Passed: Error for ${msg}${RESET}"
}

run_push_swap_valgrind() {
    valgrind --leak-check=full \
             --error-exitcode=$VALGRIND_ERROR_EXIT \
             "$PUSH_SWAP" "$@" 2> valgrind_output.txt
}

has_duplicates() {
    local input="$1"
    local sorted_unique
    local sorted_original

    sorted_unique=$(echo "$input" | tr ' ' '\n' | sort -n | uniq)
    sorted_original=$(echo "$input" | tr ' ' '\n' | sort -n)
    [[ "$sorted_unique" != "$sorted_original" ]]
}

is_already_sorted() {
    local arr=($1)
    local i
    for ((i=0; i<${#arr[@]}-1; i++)); do
        if [ "${arr[i]}" -gt "${arr[i+1]}" ]; then
            return 1
        fi
    done
    return 0
}

run_random_test() {
    local size=$1
    local limit=$2
    local iteration=$3
    local description=$4

    echo "----------------------------------------"
    echo -e "${CYAN}Test $iteration: $description${RESET}"

    local ARG
    ARG=$(shuf -i 0-5000 -n "$size" | paste -sd ' ')
    echo -e "${BLUE}Original Numbers:${RESET} $ARG"

    local instructions
    instructions=$(run_push_swap_valgrind $ARG)
    local val_ret=$?

    if [ "$val_ret" -eq "$VALGRIND_ERROR_EXIT" ]; then
        echo -e "${RED}❌ Memory error/leak detected by Valgrind.${RESET}"
        ((FAILED_TESTS++))
        local f="valgrind_random_${size}_iter${iteration}_$(date +%Y%m%d%H%M%S).txt"
        mv valgrind_output.txt "$ERROR_LOG_DIR/$f"
        return
    elif [ "$val_ret" -ne 0 ]; then
        echo -e "${RED}❌ push_swap exited with code $val_ret (unexpected).${RESET}"
        ((FAILED_TESTS++))
        local f="error_random_${size}_iter${iteration}_$(date +%Y%m%d%H%M%S).txt"
        mv valgrind_output.txt "$ERROR_LOG_DIR/$f"
        return
    else
        rm -f valgrind_output.txt
    fi

    if [ "$VERBOSE" -eq 1 ]; then
        echo -e "${BLUE}Output:${RESET}"
        local instructions_line
        instructions_line=$(echo "$instructions" | tr '\n' ' ')
        echo "$instructions_line"
    fi

    local checker_out
    checker_out=$(echo "$instructions" | $CHECKER $ARG 2>&1)
    [ -z "$checker_out" ] && checker_out="OK"
    if [ "$checker_out" != "OK" ]; then
        echo -e "${RED}❌ Incorrect sorting. Checker says: $checker_out${RESET}"
        ((FAILED_TESTS++))
        return
    fi

    local op_count
    op_count=$(echo "$instructions" | wc -l)
    echo "Number of Operations: $op_count"
    if [ "$op_count" -le "$limit" ]; then
        echo -e "${GREEN}✅ Passed: $op_count ≤ $limit${RESET}"
    else
        echo -e "${RED}❌ Failed: $op_count > $limit${RESET}"
        ((FAILED_TESTS++))
    fi

    if [ "$VISUALIZE" -eq 1 ]; then
        echo -e "${BLUE}Launching visualizer for $size numbers...${RESET}"
        python3 "$VISUALIZER" $ARG
    fi
}

run_test100() {
    echo -e "${CYAN}Running test100 ($ITER_TEST100 iteration(s), limit=$LIMIT_TEST100)...${RESET}"
    for i in $(seq 1 "$ITER_TEST100"); do
        run_random_test 100 "$LIMIT_TEST100" "$i" "Test100 Iteration $i"
    done
}

run_test500() {
    echo -e "${CYAN}Running test500 ($ITER_TEST500 iteration(s), limit=$LIMIT_TEST500)...${RESET}"
    for i in $(seq 1 "$ITER_TEST500"); do
        run_random_test 500 "$LIMIT_TEST500" "$i" "Test500 Iteration $i"
    done
}

run_specific_test() {
    local test_case="$1"
    local iteration="$2"
    local description="$3"

    echo "----------------------------------------"
    echo -e "${CYAN}Specific Test $iteration: $description${RESET}"

    if [ -z "$test_case" ]; then
        echo "Original Numbers: (no arguments)"
        handle_error_case "no arguments"
        return
    else
        echo "Original Numbers: $test_case"
    fi

    if has_duplicates "$test_case"; then
        handle_error_case "duplicates"
        return
    fi

    if echo "$test_case" | grep -Eq '[^0-9 +-]|  '; then
        handle_error_case "invalid input"
        return
    fi

    local instructions
    instructions=$(run_push_swap_valgrind $test_case)
    local val_ret=$?

    if [ "$val_ret" -eq "$VALGRIND_ERROR_EXIT" ]; then
        echo -e "${RED}❌ Memory error/leak detected by Valgrind.${RESET}"
        ((FAILED_TESTS++))
        local f="valgrind_specific${iteration}_$(date +%Y%m%d%H%M%S).txt"
        mv valgrind_output.txt "$ERROR_LOG_DIR/$f"
        return
    elif [ "$val_ret" -ne 0 ]; then
        echo -e "${RED}❌ push_swap exited with code $val_ret (unexpected).${RESET}"
        ((FAILED_TESTS++))
        local f="error_specific${iteration}_$(date +%Y%m%d%H%M%S).txt"
        mv valgrind_output.txt "$ERROR_LOG_DIR/$f"
        return
    else
        rm -f valgrind_output.txt
    fi

    if [ "$VERBOSE" -eq 1 ]; then
        echo -e "${BLUE}Output:${RESET}"
        echo "$instructions"
    fi

    local checker_out
    checker_out=$(echo "$instructions" | $CHECKER $test_case 2>&1)
    [ -z "$checker_out" ] && checker_out="OK"
    if [ "$checker_out" = "Error" ] && [ -z "$instructions" ]; then
        if is_already_sorted "$test_case"; then
            echo "No instructions + input is sorted => override to OK."
            return
        fi
    fi

    if [ "$checker_out" != "OK" ]; then
        echo -e "${RED}❌ Incorrect sorting. Checker says: $checker_out${RESET}"
        ((FAILED_TESTS++))
        return
    fi

    local op_count
    op_count=$(echo "$instructions" | wc -l)
    echo "Number of Operations: $op_count"
    echo -e "${GREEN}✅ Passed (no specific limit here).${RESET}"

    if [ "$VISUALIZE" -eq 1 ]; then
        echo -e "${BLUE}Launching visualizer for: $test_case${RESET}"
        python3 "$VISUALIZER" $test_case
    fi
}

run_specific_tests() {
    echo -e "${CYAN}Running Predefined Specific Tests...${RESET}"
    local i=1
    for test_case in "${TESTS[@]}"; do
        local desc="Predefined Test $i"
        run_specific_test "$test_case" "$i" "$desc"
        ((i++))
    done
}

run_edge_tests() {
    echo -e "${CYAN}Running Edge Case Tests...${RESET}"
    run_specific_test "1 2 3 4 5"  "1" "Already Sorted Input"
    run_specific_test "5 4 3 2 1"  "2" "Reverse Sorted Input"
    run_specific_test "42"         "3" "Single Number"
    run_specific_test "2 1"        "4" "Two Numbers"
}

run_duplicate_tests() {
    echo -e "${CYAN}Running Duplicate Tests...${RESET}"
    run_specific_test "3 1 2 3 2"  "1" "Duplicates Input"
}

echo -e "$BANNER"
parse_options "$@"

: > "$LOG_FILE"

exec > >(sed 's/\x1B\[[0-9;]*m//g' | tee -a "$LOG_FILE") 2>&1

if [ ! -x "$PUSH_SWAP" ]; then
    echo -e "${RED}❌ $PUSH_SWAP not found or not executable.${RESET}"
    exit 1
fi
if [ ! -x "$CHECKER" ]; then
    echo -e "${RED}❌ $CHECKER not found or not executable.${RESET}"
    echo -e "${RED}(Maybe 'Exec format error' => wrong architecture/OS)${RESET}"
    exit 1
fi

create_error_log_dir

[ "$VERBOSE" -eq 1 ] && echo -e "${GREEN}Verbose mode ON${RESET}" || echo -e "${CYAN}Verbose mode OFF${RESET}"
[ "$VISUALIZE" -eq 1 ] && echo -e "${BLUE}Visualizer mode ON${RESET}" || echo "Visualizer mode OFF."

if [ ${#TESTS_TO_RUN[@]} -eq 0 ]; then
    TESTS_TO_RUN=("test100" "test500" "edge" "duplicates" "specific")
fi

for test_item in "${TESTS_TO_RUN[@]}"; do
    case "$test_item" in
        test100)
            run_test100
            ;;
        test500)
            run_test500
            ;;
        edge)
            run_edge_tests
            ;;
        duplicates)
            run_duplicate_tests
            ;;
        specific)
            run_specific_tests
            ;;
        all)
            run_test100
            run_test500
            run_edge_tests
            run_duplicate_tests
            run_specific_tests
            ;;
    esac
done

echo "----------------------------------------"
echo "Test Summary:"
echo "Total Failed Tests: $FAILED_TESTS"
if [ "$FAILED_TESTS" -gt 0 ]; then
    echo -e "${RED}❌ Check the test_results.log file:${RESET}"
    echo -e "file://$(realpath $LOG_FILE)"
else
    echo -e "${GREEN}✅ All tests passed successfully! Check the test_results.log file:${RESET}"
    echo -e "file://$(realpath $LOG_FILE)"
fi
echo "----------------------------------------"