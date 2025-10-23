# Green-hydrogen
This repository presents 18 experiments on simulating and optimizing a hydrogen-based power system for residential building. It integrates PV, electrolyzer, fuel cell, hydrogen tank, battery and heat pump. Simulations use public data for energy and power flows, control logic, thermal integration of fuel cell and economic evaluation.

This folder contains a collection of 18 experiments conducted for system control and optimization.

Experiment 1 uses the ControlLogic controller.

Experiments 2–18 use an updated control strategy, ControlLogicElectrolyzer, designed to handle the minimum operating limit of the electrolyzer.

# Data Sources

Household Consumption Data
Dataset:data778721(Total2022, HeatPump2022, Other2022)
Includes total household consumption, heat pump demand, and other electrical loads.
Source: HEAPO – An Open Dataset for Heat Pump Optimization with Smart Electricity Meter Data and On-Site Inspection Protocols.

Solar Irradiation Data
Dataset: sun2019
Source: Slovenian Environment Agency (ARSO) — solar radiation and meteorological data for Slovenia.



│
├── ControlLogic                      # Base control algorithm (used in Experiment_1)
├── ControlLogicElectrolyzer          # Modified control logic (used in Experiments 2–18)
│
├── data778721HeatPump2022            # Heat pump consumption data
├── data778721Other2022               # Other household consumption data
├── data778721Total2022               # Total household consumption data
│
├── sun2019                           # Solar irradiation data (ARSO, Slovenia)
│
├── Experiment_1                      # Simulation using ControlLogic
├── Experiment_2                      # Simulation using ControlLogicElectrolyzer
├── Experiment_3
├── Experiment_4
├── Experiment_5
├── Experiment_6
├── Experiment_7
├── Experiment_8
├── Experiment_9
├── Experiment_10
├── Experiment_11
├── Experiment_12
├── Experiment_13
├── Experiment_14
├── Experiment_15
├── Experiment_16
├── Experiment_17
└── Experiment_18sub                  # Subsidy
