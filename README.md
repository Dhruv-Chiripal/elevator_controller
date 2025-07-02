# elevator_controller

This is a 4-floor elevator controller using Verilog. It handles floor requests, moves one floor at a time, and opens the door at the requested floor for 10 clock cycles.

## Key Features

- 3 FSM states: `IDLE`, `MOVING`, `DOOR_OPEN`
- Floor requests via `req[3:0]`
- Direction control (up/down)
- Door opens on request for a short time


