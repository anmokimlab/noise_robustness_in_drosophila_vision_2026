# Noise Robustness in *Drosophila* Vision

Code and data for Kim et al., *Noise robustness in Drosophila vision*.

This repository contains analysis code and processed datasets for behavioral, calcium imaging, electrophysiology, and modeling experiments characterizing how visual noise shapes sensorimotor processing in *Drosophila*, alongside benchmarks against human psychophysics and a 3D ResNet model.

## Contents
- `behavior/` — tethered flight wing-response analysis (Figures 1, 2, 6, 7)
- `imaging/` — two-photon calcium imaging analysis for LPLC2, LC4, LC11, LC15 (Figures 4, 6)
- `ephys/` — whole-cell patch-clamp analysis for HS and DNp06 neurons (Figure 5)
- `human/` — psychophysics task and analysis scripts (Figure 3)
- `resnet/` — 3D ResNet-50 training and evaluation pipeline (Figure 3, S2)
- `model/` — linear-nonlinear visuomotor model (Figure 7, S7)
- `data/` — processed datasets sufficient to reproduce all main figures

## Requirements
MATLAB R2022a or later; Python 3.10+ with PyTorch 2.0+ for ResNet code; PsychoPy 2023.2 for human experiments.

## Citation
Kim H, Ha S, Lee J, Jo M, Kim K, Kim AJ. *Noise robustness in Drosophila vision* (2025).

## Contact
Anmo J. Kim — anmokim@hanyang.ac.kr
