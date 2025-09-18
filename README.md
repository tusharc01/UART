# UART
FPGA Implementation 



**UART (Universal Asynchronous Receiver/Transmitter)** is a hardware data transfer interface, often integrated into microcontrollers or available as a standalone IC. Its main function is to facilitate asynchronous serial communication by converting parallel data from a device into serial bits for transmission and, conversely, converting received serial bits back into parallel data.

In simpler terms:

- UART enables two devices to send and receive data bit-by-bit over just two wires: **Transmit (TX)** and **Receive (RX)**.

- Each UART frames the data with a **start bit**, optional **parity bit**, and **stop bit(s)**. These bits help the receiving device recognize when data begins and ends, and they allow for basic error detection.

- UART operates **asynchronously**, meaning it does not use a shared clock signal. Instead, both devices must agree on parameters such as **baud rate**, data bit length, parity, and stop bits to keep the transfer synchronized.

- It supports **full duplex communication**, so both devices can transmit and receive data simultaneously without interference, thanks to separate TX and RX lines.

- Physically, the **TX pin of one device connects to the RX pin of the other device, and vice versa**, enabling data sent from one device’s transmitter to be received by the other’s receiver.

- Both devices also share a common **ground (GND)** reference to ensure correct voltage levels.

**Why two wires?**  
Because one wire is dedicated to transmitting data and the other to receiving, UART communication is full duplex: data can flow simultaneously in both directions. If a single wire were used for both transmission and reception, the communication would have to be half duplex, where sending and receiving occur alternately, not simultaneously.

**Typical UART Wiring:**  
```
Device 1 TX → Device 2 RX  
Device 1 RX ← Device 2 TX  
Device 1 GND ↔ Device 2 GND
```

This cross-connection of TX to RX (and vice versa) ensures proper data flow between the devices. The shared ground completes the circuit and provides voltage reference.

This wiring is standard and necessary for UART to function correctly, enabling full-duplex serial communication between two devices.


**UART communication is asynchronous**, meaning there is **no clock line shared** with the receiver. Instead, the transmitting UART uses **start and stop bits** to signal the beginning and end of each data packet (usually a single byte). These bits allow the receiving UART to know exactly when to start sampling incoming bits and when a packet ends, thus achieving proper synchronization between sender and receiver without a shared clock.

Note: **Synchronous transmission** uses a clock signal to keep both sides precisely in sync, so data can be sent continuously without start/stop bits.

Here is the exact text formatted as a README section, preserving the original content exactly as you requested:

### UART Baud Rate and Data Packet Configuration

When the receiving UART detects a start bit, it starts to read the incoming bits at a specific frequency known as the baud rate. Baud rate is a measure of the speed of data transfer, expressed in bits per second (bps). Both UARTs must operate at about the same baud rate. The baud rate between the transmitting and receiving UARTs can only differ by about 10% before the timing of bits gets too far off. Both UARTs must also must be configured to transmit and receive the same data packet structure.

The statement **"The baud rate between the transmitting and receiving UARTs can only differ by about 10% before the timing of bits gets too far off"** means the following:

- **Baud rate** is how fast bits are sent per second in UART communication.
- Both the transmitting UART and the receiving UART must operate at very close baud rates—typically within about ±10% of each other.
- If the baud rates differ by more than roughly 10%, the timing at which the receiver samples each bit will drift too much relative to the transmitter's bit timing.
- This drift causes the receiver to sample bits too early or too late, leading to incorrect interpretation of the bits (bit errors) and communication failures.

In essence, since UART is asynchronous (no clock line), the receiver relies on timing based on the agreed baud rate. Too large a difference in baud rates between sender and receiver causes their clocks to get out of sync over the course of a byte, so the receiver cannot correctly detect the start, data, parity, and stop bits.

More precise analysis and practical experience usually indicate the tolerance is often smaller—commonly around 2-5% for reliable communication depending on the UART's bit frame and oversampling method. The mentioned ~10% is a general upper limit threshold beyond which errors become very likely.

The phrase **"Both UARTs must also be configured to transmit and receive the same data packet structure"** means that the communicating UART devices need to agree on how the data bits are formatted within each transmitted frame or packet. This ensures that data sent by one UART is correctly understood by the other.

A typical UART data packet (or frame) consists of several parts:

- **Start bit:** Signals the beginning of a data frame. It is a low voltage bit that tells the receiver to start reading incoming bits.
- **Data bits:** The actual data being transmitted, usually between 5 and 9 bits per frame (commonly 8 bits).
- **Parity bit (optional):** Used for basic error detection, indicates whether the number of 1s in the data bits is even or odd.
- **Stop bits:** One or two bits at a high voltage level indicating the end of the data frame.

Both UART devices must be configured with the exact same settings for these parameters to communicate properly:

| Parameter        | Explanation                          |
|------------------|------------------------------------|
| Number of data bits | How many bits represent the data (e.g., 7 or 8 bits) |
| Parity           | None, even, or odd parity for error checking |
| Number of stop bits | One or two bits to mark frame end   |

If the UARTs differ—for example, one uses 7 data bits with parity and the other expects 8 data bits with no parity—the receiving device will misinterpret the data, leading to communication errors.

In summary, "same data packet structure" means matching the frame format parameters so both UARTs agree on how to package and interpret the serial data bits.

This is essential because UART communication is asynchronous and relies on these agreed protocols to frame the serial data correctly without a shared clock.


### Maximum Speed for UART
- UART baud rates commonly range from low speeds like **300 baud** up to **115200 baud** or higher.
- **115200 baud** (bits per second) is widely considered a practical maximum speed for many standard UART implementations on microcontrollers and serial devices.
- Some high-performance UART hardware can support speeds beyond 115200 baud, even up to 1 Mbps or more, but this depends on the device capabilities and signal quality.

**Typical Use Speeds**
- **9600 baud** is one of the most common default UART speeds—often used for simple serial communication because it balances speed and reliability.
- Lower speeds (like 1200, 2400, 4800, etc.) are also common, especially in older devices or long cable runs.
- Higher speeds (e.g., 57600, 115200 baud) are common when more data throughput is required, and the communication medium supports it.

**Notes about Maximum Speed Limits**
- The maximum achievable baud rate depends on:
  - The hardware UART module capability.
  - The quality of the wiring and electrical environment (noise, cable length).
  - The microcontroller or device clock accuracy and configuration.
  - The UART driver or software timing precision.
- When increasing the baud rate, error rates may increase unless all hardware and connections are optimal.

**Summary**
| Baud Rate         | Typical Usage                            |
|-------------------|----------------------------------------|
| 9600 baud         | Common default speed for many devices  |
| 115200 baud       | Common maximum practical speed          |
| >115200 baud      | Possible with advanced hardware & setup|


**Note:** In UART serial transmission, the data bits within a byte are sent **least significant bit (LSB) first**, meaning bit 0 (the lowest order bit) is transmitted first, then bit 1, bit 2, and so on up to bit 7 (for an 8-bit data frame). This order is part of the data frame sent after the start bit.

This LSB-first sequence is standard for UART communication, helping the receiver to reconstruct the original parallel data correctly.




### ❓ Does UART require a clock to operate?

Yes, you can absolutely say that **UART requires a clock to operate**, but it's important to clarify the nuance of **"clock"** in this context.
Here's a breakdown:



**1. UART is asynchronous – no shared clock signal**

Unlike synchronous protocols like **SPI** or **I2C**, UART does **not transmit a separate clock signal** along with the data.
This means the transmitter and receiver do **not share a common clock line** to synchronize their operations,
according to *Pantech.AI*.


**2. Each UART has an internal clock**

However, both the **transmitting** and **receiving** UART devices do have their own **internal clock circuits**,
according to *Analog Devices*.
These internal clocks are used to **generate and interpret the bit stream** based on the agreed-upon **baud rate**.


**3. Baud rate and synchronization**

Instead of a shared clock, UART relies on both the transmitter and receiver being **configured to the same baud rate**,
according to *Analog Devices*.

* The **baud rate** defines the number of bits transmitted per second.
* The **receiver uses its internal clock** and the **start bit** to synchronize its sampling with the incoming data stream,
  according to *Pantech.AI*.
* It **samples the data line** at precise intervals determined by the baud rate to capture each bit correctly.


**Summary**

> UART relies on **internal clocks within each device** and a **pre-agreed baud rate** to achieve synchronization
> and successful data transfer.
> So, while it doesn't use an **external, shared clock signal** like some other serial protocols,
> **internal clocks are essential** for its operation.



### Advantages and Disadvantages of UART

No communication protocol is perfect, but UARTs are pretty good at what they do. Here are some pros and cons to help you decide whether or not they fit the needs of your project:

**Advantages**

- Only uses two wires
- No clock signal is necessary
- Has a parity bit to allow for error checking
- The structure of the data packet can be changed as long as both sides are configured for it
- Well documented and widely used method

**Disadvantages**

- The size of the data frame is limited to a maximum of 9 bits
- Doesn’t support multiple slave or multiple master systems
- The baud rates of each UART must be within 10% of each other

---


# UART Implementation


This UART design is broken down into three main Verilog modules: a **transmitter (`uart_tx`)**, a **receiver (`uart_rx`)**, and a **top-level module (`uart_top`)** that connects them. The design is fully synchronous, using a single clock, and is parameterized to allow for different baud rates.


## **UART Transmitter (`uart_tx`)**



The transmitter's job is to take a parallel 8-bit byte and send it out serially, bit-by-bit, following the standard UART frame format. I've implemented this using a simple four-state finite state machine (FSM).

### **States and Operation**

1.  **`IDLE` State**: This is the default state. The serial output `Tx_Serial` is held high (logic '1'), which is the mark state. The FSM waits for the `Tx_Start` signal to go high. When it does, the FSM latches the input `Tx_Byte` into an internal register, asserts the `Tx_Active` signal to indicate transmission is in progress, and moves to the `START` state.

2.  **`START` State**: In this state, the FSM generates the **start bit**. It pulls the `Tx_Serial` line low (logic '0') for one full bit period. The duration of this period is determined by the `CLKS_PER_BIT` parameter. An internal counter, `r_Clk_Count`, is used to count the system clock cycles to ensure the bit timing is precise.

3.  **`DATA` State**: After the start bit, the FSM begins transmitting the 8 data bits, starting from the least significant bit (LSB). For each bit, `Tx_Serial` is set to the value of the current data bit. The FSM holds this value for one bit period. After each bit is sent, an index counter, `r_Bit_Index`, is incremented to move to the next bit. This process repeats until all 8 bits have been transmitted.

4.  **`STOP` State**: Once all data bits are sent, the FSM generates the **stop bit**. It drives the `Tx_Serial` line high for one bit period. After this, it de-asserts `Tx_Active`, asserts the `Tx_Done` signal for one bit period to signal the completion of the transfer, and returns to the `IDLE` state to await the next transmission.


## **UART Receiver (`uart_rx`)**



The receiver's function is the inverse of the transmitter. It listens on the serial input line for an incoming UART frame, receives the bits, and reassembles them into an 8-bit parallel byte.

### **Operation and Sampling**

The receiver also uses a four-state FSM. The key challenge for the receiver is to sample the incoming serial line at the correct time to reliably read the value of each bit.

1.  **`IDLE` State**: The receiver waits for a start bit, which is detected by a high-to-low transition on the `Rx_Serial` line.

2.  **`START` State**: Once a potential start bit is detected, the receiver doesn't immediately trust it. Instead, it waits for half a bit period—`(CLKS_PER_BIT - 1) / 2` clock cycles—and then samples the `Rx_Serial` line again. This **mid-bit sampling** ensures that the receiver is reading the value in the middle of the bit period, which is the most stable point and avoids errors due to timing skew between the transmitter and receiver. If the line is still low, the start bit is considered valid, and the FSM transitions to the `DATA` state. If not, it was a glitch, and it returns to `IDLE`.

3.  **`DATA` State**: The receiver now proceeds to sample the 8 data bits. It waits for one full bit period, samples the line at the midpoint, and stores the value in the corresponding position of an internal `r_Rx_Byte` register. This process is repeated for all 8 bits, from LSB to MSB.

4.  **`STOP` State**: After receiving 8 data bits, the FSM expects a stop bit (logic '1'). It waits for one final bit period. Upon completion, it asserts the `Data_Valid` signal for one bit period to indicate that a new, valid byte is available on the `Rx_Byte` output. The FSM then returns to the `IDLE` state to wait for the next frame.


---

In this Verilog design, the **baud rate** is not set directly with a single number like "50" or "9600". Instead, it is **indirectly defined** by the relationship between the system's input clock frequency and a parameter called `CLKS_PER_BIT`.

You can find it on the very first line of both the `uart_tx` and `uart_rx` modules:

```verilog
module uart_tx
  #(parameter CLKS_PER_BIT = 2000000) // <-- Right here
  (
  ...
```

### How the Calculation Works

The core principle is that all timing in a synchronous digital circuit must be derived from its main clock. The baud rate is a measure of bits per second, so we need to figure out how many clock cycles correspond to the time duration of a single bit.

The formula is:

**Baud Rate = System Clock Frequency / `CLKS_PER_BIT`**

Let's use the example from your code's comment: you want a **50 baud** rate with a **100 MHz** system clock.

1.  **System Clock Frequency:** 100 MHz = 100,000,000 cycles per second.
2.  **Desired Baud Rate:** 50 bits per second.
3.  **Calculate `CLKS_PER_BIT`:**
      * `CLKS_PER_BIT` = (100,000,000 cycles/sec) / (50 bits/sec)
      * `CLKS_PER_BIT` = 2,000,000 cycles per bit.

This is exactly the value set in your parameter.

### How It's Used in the Logic

Inside the state machine, a counter (`r_Clk_Count`) is used to measure the duration of each bit.

In the `START`, `DATA`, and `STOP` states, you'll see this logic:

```verilog
if (r_Clk_Count < CLKS_PER_BIT-1)
  begin
    r_Clk_Count <= r_Clk_Count + 1; // Keep waiting in the same bit
    ...
  end
else
  begin
    r_Clk_Count <= 0; // Reset for the next bit
    // Move to the next state or the next bit
    ...
  end
```

This code block effectively makes the state machine wait for `2,000,000` clock cycles before moving on, ensuring that the serial line is held at the correct value for the exact time required by the 50 baud rate.

### Why It's Implemented This Way

This approach is standard practice for a few important reasons:

1.  **Flexibility:** The module is now generic. To change the baud rate to 9600, you would simply recalculate `CLKS_PER_BIT` (`100,000,000 / 9600 ≈ 10417`) and change the parameter value when you instantiate the module.
2.  **Portability:** You can use this same UART module in a different project with a different system clock (e.g., 50 MHz) without changing the core logic. You would only need to update the `CLKS_PER_BIT` parameter to match the new clock frequency.

## **Top-Level Module (`uart_top`)**

The top-level module is straightforward. It instantiates both the transmitter and the receiver. The `Tx_Serial` output of the transmitter is connected directly to the `Rx_Serial` input of the receiver via an internal wire. This creates a simple loopback configuration, which is very useful for testing the design on an FPGA. The module's inputs and outputs are simply passed through to the respective ports of the transmitter and receiver instances.

