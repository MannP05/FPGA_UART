# FPGA UART Communication Interface (VHDL)

Full-duplex UART transceiver written in VHDL with programmable baud rates, parity/error detection, and **8× receiver oversampling**. The UART is integrated with a **traffic light controller** so that each traffic-light state transition broadcasts a short ASCII status message over serial using an FSM-driven message pipeline.

This project was built and validated using **ModelSim/GHDL** (simulation/timing verification) and deployed to FPGA using **Altera Quartus II**.

---

## Features

- **UART Transmitter + Receiver**
  - 7-bit ASCII payload
  - Start bit, data bits, parity bit
  - Receiver samples at **8× baud** and reports framing/parity errors
- **Baud generator** driven from a 25 MHz clock
- **Traffic light controller integration**
  - Detects state changes and transmits a corresponding message
  - If the light state changes mid-message, it **truncates** the old message and starts sending the current state (prevents “falling behind”)

---

## Top-Level Design

### `debuggableTrafficLightController.vhdl`
Top-level module that wires together:
- `trafficLightController` (the FSM for light states)
- `message_writer` (selects which message to send based on state)
- `uart` (baud generator + TX + RX)
- clock division logic (board clock → 25 MHz → 1 Hz for traffic light timing)

---

## Message Behavior

The `message_writer` contains **4 message banks** (one per relevant traffic-light state), each implemented using a `message_holder`. A `message_holder` outputs characters sequentially and then remains in a `done` state until reset.

A key design detail: the writer uses the UART’s **TDRE (transmit data register empty)** behavior to pace character emission, so transmission stays synchronized to UART throughput.

---

## Repository Structure (Key Files)

### UART
- `uart.vhdl`  
  Wraps `baud_generator`, `uart_transmitter`, and `uart_receiver` into a single reusable component.
- `uart_transmitter.vhdl`  
  FSM-based transmitter: start → data bits → parity → stop/idle.
- `uart_receiver.vhdl`  
  Dual-FSM style: one-hot pulse counter at 8× baud + receive FSM, builds a received register and raises `RDRF`.

### Messaging Layer
- `message_holder.vhdl`  
  Generic 6-character (7-bit) ASCII message sequencer.
- `message_writer.vhdl`  
  Instantiates 4 message holders; selects the active one based on the light state.

### Clocks / Utility
- `baud_generator.vhdl`  
  Divides 25 MHz into baud and 8× baud.
- `clk_div.vhdl`, `n_clk_divider.vhdl`  
  Clock division to produce the 1 Hz traffic-light clock (and other intermediate clocks).
- Various utility components: registers, comparators, mux, etc.

A more detailed “what each file does” list exists in the lab report text (see “Explaining each file”, pages 4–5).

---

## Simulation Notes

Because the design includes large clock dividers, simulation can be slow if you run with real-time clock settings.

Suggested approach (from the project report, “Simulating”, page 9):
- In `clk_div`, bypass the final divider stage and map the “1 Hz” clock to a faster internal clock (e.g., `clock_1hz <= clk_10khz;`) to make simulation practical.

There is also an end-to-end loopback-style simulation approach described in the report:
- Loop **TxD → RxD** and observe received characters in the UART’s `RDR` register.

> Expect long runtimes and large VCD outputs if you dump full waves.

---

## Hardware/Board Notes

- Design assumes a board clock is divided down to a **25 MHz** clock for the UART subsystem.
- UART I/O uses `TxD` and `RxD` pins.

---

## Known Issues / Lessons Learned

- Some toolchains (notably older Quartus II) claim VHDL-2008 support but can be unreliable; parts may need refactoring for older VHDL compatibility.
- Common UART pitfalls encountered during development included bit ordering and parity handling (both corrected in the final working version).

(See “Conclusion and Problems”, page 11 of the report.)

---


## Authors

- Mann Patel
- Justin Scaffidi

---
