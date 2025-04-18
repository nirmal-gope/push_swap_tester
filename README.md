# Push Swap Tester

A robust and user-friendly tester for **42’s `Push Swap` project**, designed to validate sorting algorithms efficiently.

## Overview

This tool automates testing for the `Push Swap` project, ensuring your program meets 42’s requirements for correctness, efficiency, and error handling. It integrates memory leak detection, operation count validation, and visual debugging, all while generating detailed logs for analysis.

### Key Features
- ✅ **Memory Leak Detection**: Uses **Valgrind** to identify memory issues (if installed).
- ✅ **Sorting Verification**: Confirms correctness with `checker_linux` or `checker_ng`.
- ✅ **Operation Limits**: Validates move counts (e.g., ≤ 700 for 100 numbers, ≤ 5500 for 500).
- ✅ **Edge Case Testing**: Handles duplicates, invalid inputs, and empty arguments.
- ✅ **Custom Iterations**: Allows user-defined iteration counts for `test100` and `test500`.
- ✅ **Detailed Statistics**: Reports total iterations, min, average, and max operations in the summary.
- ✅ **Visualization**: Includes [`visualizer.py`](./visualizer.py) to animate sorting steps.
- ✅ **Logging**: Generates `test_results.log` and detailed error reports in a single `results/error_logs/` folder, cleared each run.

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

Run the tester with various options to validate your push_swap implementation. Below are the main commands and their purposes.

### Basic Commands

- **Test 100 Random Numbers** (≤ 700 operations, default 1 iteration):
  ```bash
  ./checker.sh test100
  ```
  With custom iterations (e.g., 100):
  ```bash
  ./checker.sh test100 100
  ```

- **Test 500 Random Numbers** (≤ 5500 operations, default 1 iteration):
  ```bash
  ./checker.sh test500
  ```
  With custom iterations (e.g., 100):
  ```bash
  ./checker.sh test500 100
  ```

- **Test Duplicate Handling** (expects "Error" output):
  ```bash
  ./checker.sh duplicates
  ```

- **Test Edge Cases** (sorted, reverse-sorted, single number, etc.):
  ```bash
  ./checker.sh edge
  ```

- **Run Predefined Specific Tests**:
  ```bash
  ./checker.sh specific
  ```

- **Run All Tests** (test100, test500, edge, duplicates, specific):
  ```bash
  ./checker.sh
  ```

### Options

- **Visualize Sorting** (animate with visualizer.py):
  ```bash
  ./checker.sh test100 --visualize
  ./checker.sh test500 -v
  ```

- **Quiet Mode** (suppress verbose output):
  ```bash
  ./checker.sh test100 --quiet
  ./checker.sh test500 -q
  ```

- **Disable Valgrind** (skip memory checks):
  ```bash
  ./checker.sh test100 --no-valgrind
  ```

- **Strict Mode** (test both quoted and separate argument formats):
  ```bash
  ./checker.sh test100 --strict
  ./checker.sh test500 -s
  ```

- **Help** (display usage):
  ```bash
  ./checker.sh --help
  ./checker.sh -h
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

All output files are stored in a single `results` folder, cleared at the start of each run.

- **Terminal Output**: Displays test results with colored indicators (✅ for pass, ❌ for fail), operation counts, and sorting instructions (if verbose). For `test100` and `test500`, only summaries per iteration are shown.
- **Log File**: `results/test_results.log` captures all test details in plain text.
- **Error Logs**: `results/error_logs/` stores detailed reports for failed tests.

---

## ⚡ Tips
- **Memory Leaks**: Install Valgrind for automatic leak detection:
  ```bash
  sudo apt-get install valgrind  # On Debian/Ubuntu
  ```
- **Debugging**: Use `--visualize` to step through sorting operations visually.
- **Efficiency**: Use `test100 <n>` and `test500 <n>` with higher iteration counts to benchmark average performance.

---

## 📝 Requirements
- `push_swap`: Must be in the parent directory (`../push_swap`) and executable.
- **Linux Environment**: Uses `checker_ng` or `checker_linux` (included) for sorting verification.
- **Python 3**: Required for visualization (optional).

---

## Demo

Watch the Push Swap tester in action on YouTube:

[▶️ Push Swap Tutorial](https://youtu.be/4dMsuxfqufg)

---

## Author
**Nirmal Gope**
- GitHub: [nirmal-gope](https://github.com/nirmal-gope)
