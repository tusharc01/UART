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

