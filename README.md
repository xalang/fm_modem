## Digital FM Modem Pipeline ##

The project implements a hardware-efficient digital modem for Frequency Modulation (FM) targeting the Digilent Arty-Z7 FPGA. 

The demodulator chain is inspired by "A Digital Demodulator for Frequency Modulated Signals" (Yu, 2005), which employs an IQ mixed-demodulator architecture for phase recovery, and CORDIC vectoring mode algorithm for fast and efficient computation of arctangent. 

Q1.15 data format was chosen to balance hardware cost and precision. 50 MHz system sample rate.

### Input Chain ###
<img width="673" height="144" alt="image" src="https://github.com/user-attachments/assets/9f245155-7b63-4fd3-9183-9e9df1e0ff51" />


- 48 KHz 16-bit signed audio samples
- 105-tap 21-phase polyphase FIR interpolator for upsampling. Upsamples 48 KHz audio to ~1 MHz for smoother FM modulation transitions.
- Digital FM modulator with carrier frequency 10.7MHz, max frequency deviation 75 KHz.  
