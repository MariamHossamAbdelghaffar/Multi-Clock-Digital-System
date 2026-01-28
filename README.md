# Multi-Clock Digital System (UART-Based Processing Unit)

## Project Overview

This repository contains a complete **multi-clock digital system** implemented using **SystemVerilog**. The system receives commands via a UART interface, processes data using an ALU and Register File, and transmits results back through UART.

## SystemVerilog Features & Design Choices

### 1. Global Parameter (`package`)

**Feature:** `package`

System-wide parameters such as data width, FIFO depth, address width, and clock divider widths are defined in a dedicated package and imported where needed.

**Reasons Why it is used:**

* Centralizes all configuration parameters
* Eliminates duplicated constants
* Makes design scaling straightforward (changing data width globally)
* Encourages clean, reusable module design

### 2. Typed State Encoding (`typedef enum`)

**Feature:** `typedef enum`

Finite State Machines (FSMs) are defined using enumerated types instead of raw binary encodings.

**Reasons Why it is used:**
* Improves code readability and intent
* Reduces state encoding errors
* Enhances debugging (state names appear in waveforms)
* Makes FSMs easier to maintain and extend

### 3. Safer Decision Logic (`unique case`)

**Feature:** `unique case`

Used for mutually exclusive decision logic, especially in FSMs and control decoding.

**Reasons Why it is used:**
* Allows synthesis tools to optimize logic more effectively
* Detects overlapping or missing case items during simulation
* Prevents unintended priority logic
* Improves confidence that all valid conditions are handled

### 4. Intent-Explicit Logic Blocks (`always_ff`, `always_comb`)

**Feature:** `always_ff`, `always_comb`

These constructs replace generic `always` blocks.

**Reasons Why it is used:**

* `always_ff` guarantees proper flip-flop inference
* `always_comb` ensures purely combinational logic
* Prevents accidental latch inference
* Improves linting and tool diagnostics

### 5. Loop Syntax (C-Style Increment)

**Feature:** `i++` in `for` loops

SystemVerilog supports C-style increment operators.

**Why it matters:**

* Cleaner and more readable loop syntax
* More familiar with software and verification engineers
* Reduces verbosity without affecting synthesis

### 6. Named Block Termination

**Feature:** `endmodule : module_name`

Modules explicitly name their ending block.

**Reasons Why it is used:**

* Improves readability in large designs
* Makes navigation easier in deeply hierarchical code
* Reduces confusion when reviewing or debugging files

### 7. Implicit Port Connections (`.*`)

**Feature:** Wildcard port connections

Modules are instantiated using implicit port connections when signal names match.

**Reasons Why it is used:**

* It reduces boilerplate code
* Minimizes wiring mistakes
* Keeps top-level integration clean and readable
* Encourages consistent signal naming across the design

