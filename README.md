# Digital FM Modem Pipeline #

The project implements a hardware-efficient digital modem for Frequency Modulation (FM) targeting the Digilent Arty-Z7 FPGA. 

The demodulator chain is inspired by "A Digital Demodulator for Frequency Modulated Signals" (Yu, 2005), which employs an IQ mixed-demodulator architecture for phase recovery, and CORDIC vectoring mode algorithm for fast and efficient computation of arctangent. 

Q1.15 data format was chosen to balance hardware cost and precision. 50 MHz system sample rate.

## Input Chain ##
<img width="673" height="144" alt="image" src="https://github.com/user-attachments/assets/9f245155-7b63-4fd3-9183-9e9df1e0ff51" />


- 48 KHz 16-bit signed audio samples in input binary file.
- 105-tap 21-phase polyphase FIR interpolator for upsampling. Upsamples 48 KHz audio to ~1 MHz for smoother FM modulation steps instead of zero-stuffing.
- Digital FM modulator with carrier frequency 10.7MHz, max frequency deviation 75 KHz, implementing using dynamic phase increment + NCO.  

## FM Demodulator ##
<img width="1267" height="363" alt="image" src="https://github.com/user-attachments/assets/85baa8d9-fe6b-4c77-8e02-8de76c667d7e" />

- Reference 10.7 MHz cos and sin are generated using NCO and used to mix FM signal down to baseband + generate I & Q arms for phase discrimination.
- **CIC Decimator**
  - Cascaded Integrator-Comb filter
  - Hardware efficient anti-aliasing + decimating filter only using adders and subtractors.
  - Brings sample rate down from 50 MHz to 2 MHz (25x) to relax computational requirement of downstream filters.
  - Combines frequency response of cascaded integrator and comb stages, which together approximate a sinc-shaped low-pass response
  - 3 stages to improve rejection and sharpen roll-off of sinc
- **FIR LPF**
  - 79-tap FIR LPF with cutoff frequency 150KHz to reject double frequency term.
  - Employs tap symmetry and time-multplexing of multipliers to reduce computations and DSP usage
  - Also decimates by a factor of 2 (output 1 MHz sample rate)
  - I and Q outputs correspond to cos and sin components centered at DC.

### Baseband Demodulation ###
<img width="1280" height="542" alt="image" src="https://github.com/user-attachments/assets/794b1d40-f724-4725-8020-01a6f0afb623" />

- Computes sin{phi(n) - phi(n-1)} and cos{phi(n) - phi(n-1)} using delay elements, multipliers, and adders, based on angle subtraction identities.
- Outputs preserved as Q2.30 for precision.
- Output feeds into CORDIC module.
- **CORDIC**
  - Implements the CORDIC algorithm in vectoring mode for hardware efficient (shift add operatons only) calculation of arctan.
  - Input vector (x,y) corresponds to (cos,sin) output from previous demod stage.
  - Algorithm is based on the relation:
  - <img width="129" height="34" alt="image" src="https://github.com/user-attachments/assets/1ba85842-073c-4a29-a5b3-2809619a9c4d" />
  - Precomputed angle_i and 2^-i pairs are stored in a LUT and used to iteratively rotate input vector toward the x-axis.
  - Rotation angle (output) is accumulated over 16 iterations and scaled to Q1.15.

### Output ###
- Recovered signal is passed through final 63-tap symmetrical audio FIR LPF with decimation factor 40 to get output rate of 25 KHz.
- Samples are fed into PWM module which geneates PWM for FPGA audio output.

## Integration with Zynq-7000 PS ##
<img width="1557" height="449" alt="image" src="https://github.com/user-attachments/assets/a0ec07ec-eca7-4bdf-88cf-36edc25d7591" />

- Binary file with raw 48 KHz audio samples stored in SD card.
- PS reads samples into DDR.
- DMA to send samples from buffer in DDR to PL through AXI-stream with FIFO to handle buffering.



  
