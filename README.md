# Bit-Level Sieve of Eratosthenes in Assembly

This repository contains an implementation of the **Sieve of Eratosthenes** using **bit-level operations** in assembly language.

The classic Sieve of Eratosthenes marks composite numbers in a boolean array, but this version optimizes memory by using a **bit array** (bitmap), where each bit represents whether a number is (potentially) prime or composite. This reduces memory usage by a factor of 8 compared to a byte-per-number array.

## Features

- Efficient memory usage via bit packing
- Direct bit manipulation with instructions like `bt`, `bts`, `btr` (x86-specific) or equivalent
- Optimized for odd numbers only (skipping evens after handling 2 separately) to further reduce space and time
- Finds all prime numbers up to a configurable limit

## Architecture

- **x86 (32-bit or 64-bit)** assembly (NASM/MASM/GAS syntax – specify in code comments)
- Tested on Linux/Windows (adjust as needed)


### Using NASM (example for Linux x86-64):

```bash
nasm -f elf64 sieve.asm -o sieve.o
ld sieve.o -o sieve
./sieve
