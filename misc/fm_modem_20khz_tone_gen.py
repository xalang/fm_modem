import numpy as np

fs = 50e6
fc = 10.7e6
fd = 75e3
fa = 20e3

N = 200000

t = np.arange(N)/fs

audio = np.sin(2*np.pi*fa*t)

phase = np.cumsum(2*np.pi*(fc + fd*audio)/fs)

rf = np.cos(phase)

# Q1.15
rf_q15 = np.int16(np.round(rf * 32767))

with open("fm_if.mem", "w") as f:
    for x in rf_q15:
        f.write(f"{int(x) & 0xffff:04x}\n")
