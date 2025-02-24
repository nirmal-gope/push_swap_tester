#!/usr/bin/env python3
import sys
import subprocess
import time
import os
from shutil import get_terminal_size

def print_stacks(a, b, instruction=""):
    """Pretty-print stacks A and B side by side with the current instruction."""
    os.system('clear')
    width = get_terminal_size().columns
    a_str = "A: " + " ".join(map(str, a))
    b_str = "B: " + " ".join(map(str, b))
    print(f"{'-' * width}")
    print(f"{a_str:<{width//2}} {b_str}")
    print(f"{'-' * width}")
    if instruction:
        print(f"Instruction: {instruction}")
    time.sleep(0.1) 

def apply_instruction(inst, a, b):
    """Apply a push_swap instruction to stacks A and B."""
    if inst == "sa" and len(a) > 1:
        a[0], a[1] = a[1], a[0]
    elif inst == "sb" and len(b) > 1:
        b[0], b[1] = b[1], b[0]
    elif inst == "ss":
        if len(a) > 1: a[0], a[1] = a[1], a[0]
        if len(b) > 1: b[0], b[1] = b[1], b[0]
    elif inst == "pa" and b:
        a.insert(0, b.pop(0))
    elif inst == "pb" and a:
        b.insert(0, a.pop(0))
    elif inst == "ra" and a:
        a.append(a.pop(0))
    elif inst == "rb" and b:
        b.append(b.pop(0))
    elif inst == "rr":
        if a: a.append(a.pop(0))
        if b: b.append(b.pop(0))
    elif inst == "rra" and a:
        a.insert(0, a.pop())
    elif inst == "rrb" and b:
        b.insert(0, b.pop())
    elif inst == "rrr":
        if a: a.insert(0, a.pop())
        if b: b.insert(0, b.pop())
    return a, b

def is_sorted(a, b):
    """Check if stack A is sorted and stack B is empty."""
    return all(a[i] <= a[i+1] for i in range(len(a)-1)) and not b if a else not b

def main():
    if len(sys.argv) < 2:
        print("Usage: visualizer.py [numbers...]")
        return

    push_swap_path = "../push_swap"
    if not os.path.isfile(push_swap_path) or not os.access(push_swap_path, os.X_OK):
        print(f"Error: {push_swap_path} not found or not executable.")
        return

    cmd = [push_swap_path] + sys.argv[1:]
    try:
        instructions = subprocess.check_output(cmd, text=True, stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError as e:
        print(f"push_swap failed (exit {e.returncode}): {e.output}")
        return

    try:
        stack_a = list(map(int, sys.argv[1:]))
    except ValueError:
        print("Invalid input: All arguments must be integers.")
        return

    stack_b = []
    print_stacks(stack_a, stack_b, "Initial State")

    ops = instructions.strip().split('\n') if instructions.strip() else []
    for op in ops:
        stack_a, stack_b = apply_instruction(op, stack_a, stack_b)
        print_stacks(stack_a, stack_b, op)

    print("\nFinal State:")
    print(f"Stack A: {' '.join(map(str, stack_a))}")
    print(f"Stack B: {' '.join(map(str, stack_b))}")
    if is_sorted(stack_a, stack_b):
        print("Result: Sorted correctly!")
    else:
        print("Result: Not sorted or stack B not empty!")

if __name__ == "__main__":
    main()