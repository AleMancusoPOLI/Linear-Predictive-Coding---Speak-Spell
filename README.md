# LPC Implementation of a Speak&Spell machine

## Assignment Overview
The aim of this project is to explore the powerfulness of Linear Predictive Coding (**LPC**) as a tool to perform speech coding, through a didactic yet insightful application.

## What are the goals?
* Implement the LPC-10 coding algorithm in MATLAB, including the computation of LPC coefficients from speech frames;
* Reconstruct the speech signal from the LPC parameters;
* Evaluate the quality of the reconstructed signal compared to the original.

## Repository Contents
| File                   | Description                                           |
|-----------------------|-------------------------------------------------------|
| `encoder.m`          | The function inside the script performs the computation of the needed parameters for the LPC-10 algorithm    |
| `decoder.m`| The function inside the scripts reconstructs an estimate of the original chosen signal.    |
| `generateexcitationsignal.m`  | Matlab script that produce as output the excitation signal array that the decoder will use to reconstruct the speech signal.
| `pitchdetectionamdf.m`       | This function receives as input a frame to analyze and returns as output the estimated pitch.  |
| `voicedframedetection.m`       | This function aims at estimating if a segment is voiced or not.     |
| `test_lpc.m` | Inside the script lies an interactive console program that allows the user to test the performance of the encoder and decoder when given different tasks.    |
| `Report.pdf`   | The assignment [report](Report.pdf) with detailed explanations and results. |

## Conclusions 

For a detailed analysis of each step of this assignment, please refer to the [report](Report.pdf).

This project was developed through a collaborative effort by [Matteo Di Giovanni](https://github.com/matteodigii) and [Alessandro Mancuso](https://github.com/AleMancusoPOLI).
