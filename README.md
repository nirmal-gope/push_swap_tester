# Push Swap Tester

A robust and user-friendly tester for **42’s `Push Swap` project**, designed to validate sorting algorithms efficiently.

## Overview

This tool automates testing for the `Push Swap` project, ensuring your program meets 42’s requirements for correctness, efficiency, and error handling. It integrates memory leak detection, operation count validation, and visual debugging, all while generating detailed logs for analysis.

### Key Features
- ✅ **Memory Leak Detection**: Uses **Valgrind** to identify memory issues (if installed).
- ✅ **Sorting Verification**: Confirms correctness with `checker_linux` and `checker_ng`.
- ✅ **Operation Limits**: Validates move counts (e.g., ≤ 700 for 100 numbers, ≤ 5500 for 500).
- ✅ **Edge Case Testing**: Handles duplicates, invalid inputs, and empty arguments.
- ✅ **Visualization**: Includes [`visualizer.py`](./visualizer.py) to animate sorting steps.
- ✅ **Logging**: Generates `test_results.log` and detailed error reports in `error_logs/`.

---

## 🚀 Installation & Setup

Follow these steps to get started with the tester in your `push_swap` project directory.

### Prerequisites
- A compiled `push_swap` executable in the parent directory (`../push_swap`).
- Python 3 (for `visualizer.py`, optional).
- Valgrind (optional, for memory leak checks).

### Steps
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/nirmal-gope/push_swap_tester.git
   ```
   Clone this into your push_swap project folder so `../push_swap` is accessible.

2. **Navigate to the Tester Directory**:
   ```bash
   cd push_swap_tester
   ```

3. **Set Executable Permissions**:
   ```bash
   chmod +x checker_linux checker_ng checker.sh visualizer.py
   ```

4. **Verify Setup**: Ensure `push_swap` is compiled and located at `../push_swap`. The tester assumes this path by default.

---

## 🛠️ Usage

Run the tester with various options to validate your `push_swap` implementation. Below are the main commands and their purposes.

### Basic Commands

**Test 100 Random Numbers (≤ 700 operations)**:
```bash
./checker.sh test100
```

**Test 500 Random Numbers (≤ 5500 operations)**:
```bash
./checker.sh test500
```

**Test Duplicate Handling (expects "Error" output)**:
```bash
./checker.sh duplicates
```

**Test Edge Cases (sorted, reverse-sorted, single number, etc.)**:
```bash
./checker.sh edge
```

**Run Predefined Specific Tests**:
```bash
./checker.sh specific
```

**Run All Tests (`test100`, `test500`, `edge`, `duplicates`, `specific`)**:
```bash
./checker.sh
```

### Options

**Visualize Sorting (animate with `visualizer.py`)**:
```bash
./checker.sh test100 --v
./checker.sh test500 --v
```

**Quiet Mode (suppress verbose output)**:
```bash
./checker.sh test100 --q
```

**Help (display usage)**:
```bash
./checker.sh --h
```

### Standalone Visualization

Test specific inputs with the visualizer:
```bash
./visualizer.py 5 4 3 2 1
```
Custom Delay:
```bash
./visualizer.py --delay 0.5 5 4 3 2 1
```
---

## 📊 Output & Logs

**Terminal Output**: Displays test results with colored indicators (✅ for pass, ❌ for fail), operation counts, and sorting instructions (if verbose).

**Log File**: `test_results.log` captures all test details in plain text.

**Error Logs**: The `error_logs/` directory stores detailed reports for failed tests (e.g., crashes, incorrect sorting).

### Example Output

```
Using checker_linux as checker program
Valgrind detected, running with memory checks.
Verbose mode ON
Visualizer mode OFF
----------------------------------------
Running test100 (1 iteration, limit=700)...
Number of Operations: 542
✅ Passed: 542 ≤ 700
----------------------------------------
Running test500 (1 iteration, limit=5500)...
Number of Operations: 4412
✅ Passed: 4412 ≤ 5500
----------------------------------------
Running Edge Case Tests...
Already Sorted: ✅ Passed (0 operations)
Reverse Sorted: ✅ Passed (8 operations)
Single Number: ✅ Passed (0 operations)
Two Numbers: ✅ Passed (1 operation)
Overflow: ✅ Passed (Error detected)
Underflow: ✅ Passed (Error detected)
----------------------------------------
Running Duplicate Tests...
Duplicates: ✅ Passed (Error detected)
All Same: ✅ Passed (Error detected)
----------------------------------------
Running Predefined Specific Tests...
Predefined Test 1: ✅ Passed (14 operations)
Predefined Test 2: ✅ Passed (9 operations)
Predefined Test 3: ✅ Passed (0 operations)
Predefined Test 4: ✅ Passed (2 operations)
Predefined Test 5: ✅ Passed (Silent exit for no input)
Predefined Test 6: ✅ Passed (1 operation)
Predefined Test 7: ✅ Passed (Error detected)
Predefined Test 8: ✅ Passed (Error detected)
Predefined Test 9: ✅ Passed (10 operations)
----------------------------------------
Test Summary:
Total Failed Tests: 0
✅ All tests passed!
```

---

## ⚡ Tips

**Memory Leaks**: Install Valgrind for automatic leak detection:
```bash
sudo apt-get install valgrind  # On Debian/Ubuntu
```

**Debugging**: Use `--visualize` to step through sorting operations visually.

**Custom Tests**: Modify the `TESTS` array in `checker.sh` to add your own cases.

---

## 📝 Requirements

- **`push_swap`**: Must be in the parent directory (`../push_swap`) and executable.
- **Linux Environment**: Uses `checker_ng` or `checker_linux` (included) for sorting verification.
- **Python 3**: Required for visualization (optional).

---

### Author
- **Nirmal Gope**
- **GitHub**: [nirmal-gope](https://github.com/nirmal-gope)
