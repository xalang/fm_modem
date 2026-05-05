## Digital FM Modem Pipeline ##

The project implements a hardware-efficient digital modem for Frequency Modulation (FM) targeting the Digilent Arty-Z7 FPGA. 

The demodulator chain is inspired by "A Digital Demodulator for Frequency Modulated Signals" (Yu, 2005), which employs an IQ mixed-demodulator architecture for phase recovery, and CORDIC vectoring mode algorithm for fast and efficient computation of arctangent.

Q1.15 data format was chosen to balance hardware cost and precision.

#### Input Chain ####
<img width="720" height="174" alt="image" src="https://github.com/user-attachments/assets/c8ca1df4-35f5-450c-a823-1d05f5ffaf60" />
