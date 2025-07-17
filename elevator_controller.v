`timescale 1ns / 1ps


module elevator_controller (
    input clk,                   // System clock
    input reset,                 // Reset signal (active high)
    input [3:0] req,             // Requests for each floor (req[0],req[1],req[2],req[3])
    output reg [1:0] floor,      // Current floor (2-bit: 0 to 3[00,01,10,11])
    output reg moving,           // Elevator is moving (1 = yes)
    output reg door,             // Door is open (1 = open)
    output reg direction         // Direction: 1 = up, 0 = down
);

    // FSM states 
    parameter IDLE         = 3'b000; // Idle case 
    parameter DOOR_OPEN    = 3'b001; // Opening the Door
    parameter DOOR_CLOSING = 3'b010; // Closing the Door
    parameter MOVING_UP    = 3'b011; // Moving UP
    parameter MOVING_DOWN  = 3'b100; // Moving DOWN
    parameter DECIDE_MOVE  = 3'b101; // Deciding next move

    // Internal registers
    reg [2:0] state;             // Current state (3 bits for 6 states)
    reg [3:0] requests;          // Floor request register
    reg [3:0] door_timer;        // Counter for how long the door remains open and closing time

    // Main 
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            floor      <= 2'd0;       // Start at floor 0
            state      <= IDLE;       // Start in idle state
            moving     <= 0;          // Not moving
            door       <= 0;          // Door close
            direction  <= 1;           // Default direction: up
            requests   <= 4'b0000;     // No request
            door_timer <= 0;
        end
        else begin
            //Get new requests
            requests <= requests | req;

            case (state)
                IDLE: begin
                    moving <= 0;
                    door   <= 0;
                    // If there's a request for the current floor, open the door
                    if (requests[floor]) begin
                        requests[floor] <= 0; // Request cleared 
                        state <= DOOR_OPEN;
                        door_timer <= 4'd10; // Door open for 10 
                    end
                    // If there are other requests, decide where to go
                    else if (requests != 4'b0000) begin
                        state <= DECIDE_MOVE;
                    end
                end
                
                // Opening door at a floor
                DOOR_OPEN: begin
                    moving <= 0;
                    door   <= 1; // Door is open
                    // Wait for the timer to finish
                    if (door_timer > 0) begin
                        door_timer <= door_timer - 1;
                    end 
                    else begin
                        // Once timer is done,closing the door
                        state <= DOOR_CLOSING;
                        door_timer <= 4'd3; // Set timer for door closing duration 
                    end
                end

                // Closing door before moving 
                DOOR_CLOSING: begin
                    moving <= 0;
                    door   <= 0; // Door is now considered closed
                    if (door_timer > 0) begin
                        door_timer <= door_timer - 1;
                    end else begin
                        // After door is closed, decide where to go
                        state <= DECIDE_MOVE;
                    end
                end
                
                // Deciding where to go ?
                DECIDE_MOVE: begin
                    // If no requests, go back to IDLE
                    if (requests == 4'b0000) begin
                        state <= IDLE;
                    end
                    // Check for any request on a floor above the current floor
                    else if ( (floor == 2'd0 && (requests[1] || requests[2] || requests[3])) ||
                              (floor == 2'd1 && (requests[2] || requests[3])) ||
                              (floor == 2'd2 && (requests[3])) ) begin
                        direction <= 1;
                        state <= MOVING_UP;
                    end
                    // Check for any request on a floor below the current floor
                    else if ( (floor == 2'd1 && requests[0]) ||
                              (floor == 2'd2 && (requests[0] || requests[1])) ||
                              (floor == 2'd3 && (requests[0] || requests[1] || requests[2])) ) begin
                        direction <= 0;
                        state <= MOVING_DOWN;
                    end
                    // case where the only request is for the current floor
                    else begin
                        state <= IDLE;
                    end
                end

                // For moving up
                MOVING_UP: begin
                    moving <= 1; //moving
                    door   <= 0; //closed
                    direction <= 1; //up
                    
                    if (floor < 3) begin
                        floor <= floor + 1; //gone one floor up
                        // Check if the arriving floor is requested
                        if (requests[floor + 1]) begin
                            requests[floor + 1] <= 0; // Clear request
                            state <= DOOR_OPEN;
                            door_timer <= 4'd10;
                        end
                    end 
                    else
                    begin
                        // Reached to destination, now must go idle or go down
                        state <= DECIDE_MOVE;
                    end
                end

                // For moving down
                MOVING_DOWN: begin
                    moving <= 1;
                    door   <= 0;
                    direction <= 0;
                    
                    if (floor > 0) begin
                        floor <= floor - 1;
                        // Check if the arriving floor is requested
                        if (requests[floor - 1]) begin
                            requests[floor - 1] <= 0; // Clear request
                            state <= DOOR_OPEN;
                            door_timer <= 4'd10;
                        end
                    end else begin
                        // Reached the requried one, now must go idle or go up
                        state <= DECIDE_MOVE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule
