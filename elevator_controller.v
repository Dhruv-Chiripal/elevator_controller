`timescale 1ns / 1ps


module elevator_controller (
    input clk,
    input reset,
    input [3:0] req,               // Floor requests [floor 3 to 0]
    output reg [1:0] floor,        // Current floor (0 to 3)
    output reg moving,             // 1 = elevator moving
    output reg door,               // 1 = door open
    output reg direction           // 1 = up, 0 = down
);

    // FSM states
    parameter IDLE         = 3'b000;
    parameter DOOR_OPEN    = 3'b001;
    parameter DOOR_CLOSING = 3'b010;
    parameter MOVING_UP    = 3'b011;
    parameter MOVING_DOWN  = 3'b100;
    parameter DECIDE_MOVE  = 3'b101;

    reg [2:0] state;
    reg [3:0] requests;
    reg [3:0] door_timer;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            floor      <= 2'd0;
            state      <= IDLE;
            moving     <= 0;
            door       <= 0;
            direction  <= 1; // Default direction: up
            requests   <= 4'b0000;
            door_timer <= 0;
        end else begin
            // Latch new requests
            requests <= requests | req;

            case (state)
                IDLE: begin
                    moving <= 0;
                    door   <= 0;

                    if (requests[floor]) begin
                        requests[floor] <= 0;
                        state <= DOOR_OPEN;
                        door_timer <= 4'd10;
                    end else if (requests != 4'b0000) begin
                        state <= DECIDE_MOVE;
                    end
                end

                DOOR_OPEN: begin
                    moving <= 0;
                    door <= 1;

                    if (door_timer > 0)
                        door_timer <= door_timer - 1;
                    else begin
                        state <= DOOR_CLOSING;
                        door_timer <= 4'd3;
                    end
                end

                DOOR_CLOSING: begin
                    moving <= 0;
                    door <= 0;

                    if (door_timer > 0)
                        door_timer <= door_timer - 1;
                    else
                        state <= DECIDE_MOVE;
                end

                DECIDE_MOVE: begin
                    if (requests == 4'b0000)
                        state <= IDLE;
                    else if (
                        (floor == 2'd0 && (requests[1] || requests[2] || requests[3])) ||
                        (floor == 2'd1 && (requests[2] || requests[3])) ||
                        (floor == 2'd2 && (requests[3]))
                    ) begin
                        direction <= 1;
                        state <= MOVING_UP;
                    end else if (
                        (floor == 2'd1 && requests[0]) ||
                        (floor == 2'd2 && (requests[0] || requests[1])) ||
                        (floor == 2'd3 && (requests[0] || requests[1] || requests[2]))
                    ) begin
                        direction <= 0;
                        state <= MOVING_DOWN;
                    end else
                        state <= IDLE;
                end

                MOVING_UP: begin
                    moving <= 1;
                    door <= 0;
                    direction <= 1;

                    if (floor < 3)
                        floor <= floor + 1;

                    // After floor update, check if request exists
                    if (floor < 3 && requests[floor + 1]) begin
                        requests[floor + 1] <= 0;
                        state <= DOOR_OPEN;
                        door_timer <= 4'd10;
                    end else
                        state <= DECIDE_MOVE;
                end

                MOVING_DOWN: begin
                    moving <= 1;
                    door <= 0;
                    direction <= 0;

                    if (floor > 0)
                        floor <= floor - 1;

                    if (floor > 0 && requests[floor - 1]) begin
                        requests[floor - 1] <= 0;
                        state <= DOOR_OPEN;
                        door_timer <= 4'd10;
                    end else
                        state <= DECIDE_MOVE;
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule
