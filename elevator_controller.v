`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.07.2025 17:44:37
// Design Name: 
// Module Name: elevator_controller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module elevator_controller (
    input clk,                // System clock
    input reset,              // Reset signal (active high)
    input [3:0] req,          // Requests for each floor (floor 0,1,2,3) req[0], req[1], req[2], req[3]
    output reg [1:0] floor,   // Current floor (2-bit: 0 to 3)
    output reg moving,        // Elevator is moving (1 = yes)
    output reg door,          // Door is open (1 = open)
    output reg direction      // Direction: 1 = up, 0 = down
);

   //states
    parameter IDLE      = 2'b00;
    parameter MOVING    = 2'b01;
    parameter DOOR_OPEN = 2'b10;

    //internal registers
    reg [1:0] state;         // current state
    reg [3:0] requests;      // floor request 
    reg [3:0] door_timer;    // Counter for how long door remains open

    // main block 
    always @(posedge clk or posedge reset) begin
        if (reset) begin
           
            floor      <= 2'd0;      // Start at floor 0
            state      <= IDLE;      // Start in idle state
            moving     <= 0;
            door       <= 0;
            direction  <= 1;         // Default direction: up
            requests   <= 4'b0000;   // No requests initially
            door_timer <= 0;
        end 
        else begin
            
            requests <= requests | req; // or with existing ones

            case (state)
                //IDLE : wait for the requests
                IDLE: begin
                    moving <= 0;
                    door   <= 0;

                    if (requests != 4'b0000) begin
                        // Set direction based on requests
                        if (
                            (floor == 0 && (requests[1] | requests[2] | requests[3])) ||
                            (floor == 1 && (requests[2] | requests[3])) ||
                            (floor == 2 && (requests[3]))
                        )
                            direction <= 1; // Go up 
                        else if (
                            (floor == 3 && (requests[0] | requests[1] | requests[2])) ||
                            (floor == 2 && (requests[0] | requests[1])) ||
                            (floor == 1 && (requests[0]))
                        )
                            direction <= 0; // Go down

                        state <= MOVING;
                    end
                end
                
                // MOVING: Move one floor up/down per clock cycle
                
                MOVING: begin
                
                
                    moving <= 1;
                    door   <= 0;
                    

                    // Move in the set direction
                    if (direction == 1 && floor < 3)
                        floor <= floor + 1;
                    else if (direction == 0 && floor > 0)
                        floor <= floor - 1;

                    // Check if this floor is requested
                    if (requests[floor]) begin
                        requests[floor] <= 0;       // Clear request for this floor
                        door_timer      <= 4'd10;   // Keep door open for 10 cycles
                        state           <= DOOR_OPEN;
                        moving          <= 0;
                    end
                end

                
                // DOOR_OPEN: now keeping the door open on the requested floor
                
                DOOR_OPEN: begin
                    door <= 1;
                    moving <= 0;

                    if (door_timer > 0)
                        door_timer <= door_timer - 1;
                    else begin
                        door <= 0;
                        state <= IDLE;
                    end
                end

                // default condition
                default: state <= IDLE;
            endcase
        end
    end

endmodule
