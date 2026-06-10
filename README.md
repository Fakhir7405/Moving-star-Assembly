# 🚀 MovingStar — x86 Assembly Maze Game

A real-mode x86 Assembly game written for DOS (.COM format).  
You control a moving star (`*`) and must navigate through a maze of obstacles to reach the red goal — without hitting walls.

This project demonstrates low-level systems programming using interrupts, hardware I/O, and direct video memory manipulation.

---

## 🎮 Gameplay

- You control a **blue moving star (`*`)**
- Navigate through **green obstacles (walls)**
- Reach the **red goal at the top-left corner (0,0)**
- Avoid collisions or going out of bounds
- Continuous movement based on current direction

---

## 🧭 Controls

| Key | Action |
|-----|--------|
| ↑ | Move Up |
| ↓ | Move Down |
| ← | Move Left |
| → | Move Right |

⚠️ The player moves continuously — there is no stop.

---

## 🧱 Obstacle Layout

### Horizontal Walls
- Row 14, columns 22–35  
- Row 7, columns 20–33  
- Row 8, columns 60–73  

### Vertical Walls
- Column 79, rows 0–24 (right border wall)  
- Column 10, rows 5–11  
- Column 43, rows 7–15  
- Column 50, rows 3–8  

---

## ⚙️ How to Run

### Requirements
- DOSBox or any DOS-compatible emulator
- NASM assembler

---

### 🛠 Build

```bash
nasm -f bin MovingStar.asm -o MovingStar.comg