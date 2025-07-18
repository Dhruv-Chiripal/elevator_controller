# 4-Floor Elevator Controller in Verilog

4-Floor Elevator System in Verilog
This repository contains the Verilog source code for a 4-floor elevator controller and its testbench. The controller's logic is implemented as a six-state Finite State Machine (FSM) that manages floor requests, movement, and door operations.

## Features

- Supports multiple simultaneous floor requests
- Dynamic bidirectional movement control
- Automatic door operation with timed delay
- FSM-based synchronous control logic
- Verified through testbench and waveform analysis

## FSM
  
IDLE	-- No pending requests
MOVE_UP -- Moving upward to a requested floor
MOVE_DOWN	 -- Moving downward to a requested floor
STOP -- At requested floor, door opens
WAIT -- Door remains open before next action

## Supporting Files
elevator_controller.v – Main design module
tb_elevator_controller.v – Simulation testbench
Output_Waveform – Output waveform screenshots (simulation results)
elevator_controller_output.pdf – Terminal output log from simulation
flowchart.pdf – FSM diagram
