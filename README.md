# Adaptive Thermal Management System using ANSYS & MATLAB

<p align="center">
  <img src="Images/workflow.png" width="700">
</p>

<p align="center">
<b>Complete Design → Simulation → Optimization → MATLAB Controller Development</b>
</p>
----
This project presents an **Adaptive Thermal Management System (ATMS)** designed to maintain an aluminium plate at a constant operating temperature of **35°C** under varying external heat loads (0–120 W).

The project combines **CAD modeling, Finite Element Analysis (FEA), Design of Experiments (DOE), Response Surface Optimization, and MATLAB-based control engineering** to develop an intelligent heating and cooling strategy suitable for future Electric Vehicle (EV) battery thermal management systems and electronic cooling applications.

---

## Problem Statement

Electronic devices and EV battery packs experience continuously changing thermal loads during operation. Conventional cooling systems operate at fixed fan speeds and cannot maintain a constant operating temperature efficiently.

This project proposes an adaptive solution that automatically switches between:

- Heating Mode (Low Heat Load)
- Cooling Mode (High Heat Load)

to maintain the plate temperature near **35°C**.

---

## Key Features

- Adaptive Heating and Cooling Strategy
- Serpentine Heater Design
- Optimized Cooling Fin Geometry
- ANSYS Steady-State Thermal Analysis
- Design of Experiments (DOE)
- Response Surface Generation
- Response Surface Optimization
- MATLAB Controller Development
- Fan RPM Prediction
- Future Hardware Implementation Ready

---

## Software Used

- SolidWorks
- ANSYS Workbench
- ANSYS Mechanical
- MATLAB
- Microsoft Excel

---

## Methodology

```
SolidWorks Design
        │
        ▼
ANSYS Geometry
        │
        ▼
Steady-State Thermal Analysis
        │
        ▼
Parameter Set
        │
        ▼
Design of Experiments (DOE)
        │
        ▼
Response Surface
        │
        ▼
Response Surface Optimization
        │
        ▼
MATLAB Controller
        │
        ▼
Adaptive Heating & Cooling System
```

---

## Adaptive Control Strategy

### Heating Mode

- External Heat: **0–15 W**
- Internal Heater: **15 W → 0 W**
- Fan: OFF
- Natural Convection: **8 W/m²·K**

### Cooling Mode

- External Heat: **15–120 W**
- Heater: OFF
- Fan Speed: Variable
- Convection Coefficient: Obtained from ANSYS Optimization

---

## Engineering Concepts Used

- Heat Conduction
- Forced Convection
- Natural Convection
- Newton's Law of Cooling
- Fourier's Law
- Thermal Resistance
- Finite Element Analysis
- Design Optimization
- Response Surface Methodology
- Control Engineering

---
## Repository Structure

```text
Adaptive-Thermal-Management-System/
│
├── ANSYS/
├── MATLAB/
├── SolidWorks/
├── Images/
├── Report/
├── README.md
└── LICENSE
```
---

## Results

- Maintained plate temperature near **35°C**
- Reduced computational effort using DOE
- Developed an adaptive thermal controller
- Optimized convection coefficient using Response Surface Optimization
- Predicted practical BLDC fan speed using MATLAB

---

## Future Scope

- CFD-based airflow analysis
- Real-time hardware implementation
- ESP32/Arduino integration
- PWM-controlled BLDC fan
- Temperature sensor feedback
- IoT-based monitoring
- Machine Learning-based thermal prediction

---

## Applications

- Electric Vehicle Battery Thermal Management
- Battery Energy Storage Systems
- Power Electronics Cooling
- Embedded Electronics
- LED Cooling Systems
- Aerospace Electronics
- Industrial Thermal Management

---

## Contributors

- **Abhay Agrahari**
- **Abhik Dixit**


---

⭐ **If you found this project helpful, please consider giving this repository a Star!**
