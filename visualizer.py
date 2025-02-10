#!/usr/bin/env python3
import sys
import subprocess
import time
import os

def print_stacks(a, b):
    print("Stack A :", a)
    print("Stack B :", b)
    time.sleep(0.05)

def apply_instruction(inst, a, b):
    if inst == "sa" and len(a) > 1:
        a[0], a[1] = a[1], a[0]
    elif inst == "sb" and len(b) > 1:
        b[0], b[1] = b[1], b[0]
    elif inst == "ss":
        if len(a) > 1:
            a[0], a[1] = a[1], a[0]
        if len(b) > 1:
            b[0], b[1] = b[1], b[0]
    elif inst == "pa" and b:
        a.insert(0, b.pop(0))
    elif inst == "pb" and a:
        b.insert(0, a.pop(0))
    elif inst == "ra" and a:
        a.append(a.pop(0))
    elif inst == "rb" and b:
        b.append(b.pop(0))
    elif inst == "rr":
        if a:
            a.append(a.pop(0))
        if b:
            b.append(b.pop(0))
    elif inst == "rra" and a:
        a.insert(0, a.pop())
    elif inst == "rrb" and b:
        b.insert(0, b.pop())
    elif inst == "rrr":
        if a:
            a.insert(0, a.pop())
        if b:
            b.insert(0, b.pop())
    return a, b

def main():
    if len(sys.argv) < 2:
        print("Usage: visualizer.py [numbers...]")
        return

    cmd = ["../push_swap"] + sys.argv[1:]
    try:
        instructions = subprocess.check_output(cmd, text=True)
    except FileNotFoundError:
        print("Error: ../push_swap not found or not executable.")
        return
    except subprocess.CalledProcessError as e:
        print(f"push_swap exited with code {e.returncode}")
        print("Output:", e.output)
        return

    try:
        stack_a = list(map(int, sys.argv[1:]))
    except ValueError:
        print("Invalid input: non-integers.")
        return

    stack_b = []
    print_stacks(stack_a, stack_b)

    ops = instructions.strip().split('\n') if instructions.strip() else []
    for op in ops:
        stack_a, stack_b = apply_instruction(op, stack_a, stack_b)
        print_stacks(stack_a, stack_b)

    print("\nFinal State:")
    print("Stack A:", stack_a)
    print("Stack B:", stack_b)

if __name__ == "__main__":
    main()
