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

# UART Baud Rate and Data Packet Configuration

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



### Advantages and Disadvantages of UART

No communication protocol is perfect, but UARTs are pretty good at what they do. Here are some pros and cons to help you decide whether or not they fit the needs of your project:

## Advantages

- Only uses two wires
- No clock signal is necessary
- Has a parity bit to allow for error checking
- The structure of the data packet can be changed as long as both sides are configured for it
- Well documented and widely used method

## Disadvantages

- The size of the data frame is limited to a maximum of 9 bits
- Doesn’t support multiple slave or multiple master systems
- The baud rates of each UART must be within 10% of each other


