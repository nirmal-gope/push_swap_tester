#!/usr/bin/env python3
import sys
import subprocess
import time
import os
from shutil import get_terminal_size
import argparse

RESET = "\033[0m"
BLUE = "\033[1;34m"
GREEN = "\033[1;32m"
YELLOW = "\033[1;33m"
RED = "\033[1;31m"

def print_stacks(a, b, instruction="", delay=0.1):
    """Pretty-print stacks A and B side by side with the current instruction."""
    os.system('clear')
    width = get_terminal_size().columns
    a_str = f"{BLUE}Stack A:{RESET} " + " ".join(map(str, a))
    b_str = f"{GREEN}Stack B:{RESET} " + " ".join(map(str, b))
    print(f"{YELLOW}{'=' * width}{RESET}")
    print(f"{a_str:<{width//2}} {b_str}")
    print(f"{YELLOW}{'=' * width}{RESET}")
    if instruction:
        print(f"{YELLOW}Instruction: {instruction}{RESET}")
    time.sleep(delay)

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

def parse_arguments():
    """Parse command-line arguments with support for quoted strings."""
    parser = argparse.ArgumentParser(description="Push Swap Visualizer")
    parser.add_argument("numbers", nargs="*", help="List of integers or quoted string of integers")
    parser.add_argument("--delay", type=float, default=0.1, help="Delay between instructions (seconds)")
    args = parser.parse_args()

    if not args.numbers:
        print(f"{RED}Error: No numbers provided. Usage: {sys.argv[0]} [numbers...] or \"num1 num2 ...\"{RESET}")
        sys.exit(1)

    if len(args.numbers) == 1 and " " in args.numbers[0]:
        args.numbers = args.numbers[0].split()

    try:
        args.numbers = list(map(int, args.numbers))
    except ValueError:
        print(f"{RED}Error: All inputs must be integers.{RESET}")
        sys.exit(1)

    return args

def main():
    args = parse_arguments()

    push_swap_path = "../push_swap"
    if not os.path.isfile(push_swap_path) or not os.access(push_swap_path, os.X_OK):
        print(f"{RED}Error: {push_swap_path} not found or not executable.{RESET}")
        sys.exit(1)

    cmd = [push_swap_path] + list(map(str, args.numbers))
    try:
        instructions = subprocess.check_output(cmd, text=True, stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError as e:
        print(f"{RED}push_swap failed (exit {e.returncode}): {e.output}{RESET}")
        sys.exit(1)

    stack_a = args.numbers[:]
    stack_b = []
    print_stacks(stack_a, stack_b, "Initial State", args.delay)

    ops = instructions.strip().split('\n') if instructions.strip() else []
    for op in ops:
        stack_a, stack_b = apply_instruction(op, stack_a, stack_b)
        print_stacks(stack_a, stack_b, op, args.delay)

    print(f"\n{YELLOW}=== Final State ==={RESET}")
    print(f"{BLUE}Stack A:{RESET} {' '.join(map(str, stack_a))}")
    print(f"{GREEN}Stack B:{RESET} {' '.join(map(str, stack_b))}")
    if is_sorted(stack_a, stack_b):
        print(f"{GREEN}Result: Sorted correctly!{RESET}")
    else:
        print(f"{RED}Result: Not sorted or stack B not empty!{RESET}")

if __name__ == "__main__":
    main()