# push_swap_tester

A simple Push Swap Tester for **42’s push_swap** project.

### Features:
- ✅ **Checks for memory leaks** using **Valgrind**
- ✅ **Sorting correctness verification** via `checker_linux`
- ✅ **Operation count validation** (e.g., ≤ 700 for 100 numbers, ≤ 5500 for 500)
- ✅ **Handles edge cases** (duplicates, invalid input, no arguments)
- ✅ **Includes a [`visualizer.py`](./visualizer.py)** to animate sorting steps
- ✅ **Generates logs (`test_results.log`) and error reports (`error_logs/`)**

---

## 🚀 Installation & Setup

1. **Clone this repository inside your push_swap project directory:**
   ```bash
   git clone https://github.com/nirmal-gope/push_swap_tester.git
   ```
2. **Enter the folder:**
   ```bash
   cd push_swap_tester
   ```
3. **Make the scripts executable:**
   ```bash
   chmod +x checker_linux
   chmod +x checker.sh
   chmod +x visualizer.py
   ```
4. **Running Tests:**

   - Tests 100 random numbers once (must sort within ≤ 700 moves):
     ```bash
     ./checker.sh test100
     ```
   - Tests 500 random numbers once (must sort within ≤ 5500 moves):
     ```bash
     ./checker.sh test500
     ```
   - Checks duplicate input handling (push_swap should return "Error"):
     ```bash
     ./checker.sh duplicates
     ```
   - Tests edge cases (sorted list, reverse-sorted list, single number, etc.):
     ```bash
     ./checker.sh edge
     ```
   - Runs everything (test100, test500, edge, duplicates, specific):
     ```bash
     ./checker.sh
     ```
   - If you want to visualize:
     ```bash
     ./checker.sh test100 --visualize
     ./checker.sh test500 --visualize
     ./visualizer.py 5 4 3 2 1
