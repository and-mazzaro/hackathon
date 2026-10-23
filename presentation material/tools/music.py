"""Synthesise an upbeat chiptune track (DS-era adventure style). Usage: music.py OUT.wav SECONDS"""
import sys, wave
import numpy as np
out, total = sys.argv[1], float(sys.argv[2])
SR = 44100
BPM = 150
beat = 60 / BPM
n = int(total * SR)
mix = np.zeros(n)
def note_freq(m): return 440.0 * 2 ** ((m - 69) / 12)
def env(length, a=0.005, d=0.08, s=0.6, r=0.05):
    t = np.arange(length) / SR
    e = np.ones(length) * s
    ai = int(a * SR); di = int(d * SR); ri = int(r * SR)
    e[:ai] = np.linspace(0, 1, ai) if ai else e[:ai]
    if di: e[ai:ai + di] = np.linspace(1, s, len(e[ai:ai + di]))
    if ri: e[-ri:] *= np.linspace(1, 0, len(e[-ri:]))
    return e
def square(f, length, duty=0.5):
    t = np.arange(length) / SR
    return np.where((t * f) % 1 < duty, 1.0, -1.0)
def tri(f, length):
    t = np.arange(length) / SR
    return 2 * np.abs(2 * ((t * f) % 1) - 1) - 1
def add(sig, start_s, gain):
    i = int(start_s * SR)
    if i >= n: return
    j = min(n, i + len(sig))
    mix[i:j] += sig[:j - i] * gain
# C - G - Am - F, one bar each (4 beats)
chords = [(60, [60, 64, 67]), (55, [55, 59, 62]), (57, [57, 60, 64]), (53, [53, 57, 60])]
melody_a = [72, 74, 76, 79, 76, 74, 72, 74,  71, 74, 79, 77, 76, 74, 71, 74,
            72, 76, 81, 79, 76, 74, 72, 76,  77, 76, 74, 72, 74, 76, 77, 79]
melody_b = [79, None, 79, 81, 79, 77, 76, None, 74, None, 74, 76, 74, 72, 71, None,
            72, None, 76, 79, 81, 79, 76, 72, 77, 76, 74, 72, 71, 72, 74, None]
bar = 4 * beat
t = 0.0
section = 0
rng = np.random.default_rng(7)
while t < total:
    intro = t < 4 * bar
    for ci, (root, triad) in enumerate(chords):
        bt = t + ci * bar
        if bt >= total: break
        # bass: eighth notes, triangle
        for k in range(8):
            m = root - 12 if k % 2 == 0 else root
            L = int(beat / 2 * SR * 0.9)
            add(tri(note_freq(m), L) * env(L, d=0.05, s=0.8), bt + k * beat / 2, 0.30)
        # arpeggio: sixteenth notes, 12.5% square, quiet
        for k in range(16):
            m = triad[k % 3] + 12
            L = int(beat / 4 * SR * 0.8)
            add(square(note_freq(m), L, 0.125) * env(L, d=0.03, s=0.3), bt + k * beat / 4, 0.045)
        # drums
        if not intro or ci >= 2:
            for k in range(4):
                kt = bt + k * beat
                L = int(0.18 * SR); tt = np.arange(L) / SR
                kick = np.sin(2 * np.pi * (60 + 120 * np.exp(-tt * 30)) * tt) * np.exp(-tt * 18)
                if k in (0, 2): add(kick, kt, 0.55)
                if k in (1, 3):
                    L2 = int(0.15 * SR); sn = rng.uniform(-1, 1, L2) * np.exp(-np.arange(L2) / SR * 25)
                    add(sn, kt, 0.22)
                for h in (0, 0.5):
                    L3 = int(0.04 * SR); hh = rng.uniform(-1, 1, L3) * np.exp(-np.arange(L3) / SR * 90)
                    add(hh, kt + h * beat, 0.08)
        # lead: 50% square melody, eighth notes
        if not intro:
            mel = melody_a if section % 2 == 0 else melody_b
            for k in range(8):
                m = mel[(ci * 8 + k) % len(mel)]
                if m is None: continue
                L = int(beat / 2 * SR * 0.92)
                vib = 1 + 0.004 * np.sin(2 * np.pi * 6 * np.arange(L) / SR)
                tt = np.arange(L) / SR
                sig = np.where((np.cumsum(note_freq(m) * vib) / SR) % 1 < 0.5, 1.0, -1.0)
                add(sig * env(L, d=0.06, s=0.55), bt + k * beat / 2, 0.11)
    t += 4 * bar
    section += 1
# fade in/out, normalise
fi = int(0.5 * SR); fo = int(3.0 * SR)
mix[:fi] *= np.linspace(0, 1, fi); mix[-fo:] *= np.linspace(1, 0, fo)
mix = mix / np.max(np.abs(mix)) * 0.85
data = (mix * 32767).astype(np.int16)
with wave.open(out, 'wb') as w:
    w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR); w.writeframes(data.tobytes())
print('wrote', out, total, 's')
