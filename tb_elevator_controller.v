`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.07.2025 17:51:32
// Design Name: 
// Module Name: tb_elevator_controller
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




module tb_elevator_controller;

    // Inputs to the DUT
    reg clk;
    reg reset;
    reg [3:0] req;

    // Outputs from the DUT
    wire [1:0] floor;
    wire moving;
    wire door;
    wire direction;

    // Instantiate t    he Device Under Test (DUT)
    elevator_controller uut (
        .clk(clk),
        .reset(reset),
        .req(req),
        .floor(floor),
        .moving(moving),
        .door(door),
        .direction(direction)
    );

    // Clock generation: 100MHz → 10ns period (toggle every 5ns)
    always #5 clk = ~clk;

    // Stimulus block
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        req = 4'b0000;

        // Hold reset
        #20;
        reset = 0;

        // Request floor 3 (binary: 1000)
        #10;
        req = 4'b1000;

        // Clear request
        #100;
        req = 4'b0000;

        // Request floor 1 (binary 2 0010)
        #80;
        req = 4'b0010;

        // Clear request
        #100;
        req = 4'b0000;

        // Request floor 0 and 2 simultaneously (0001 | 0100) 
        #100;
        req = 4'b0101;

        // Clear request
        #150;
        req = 4'b0000;

        // Request all floors (0001 | 0010 | 0100 | 1000)
        #100;
        req = 4'b1111;

        // End simulation
        #300;
        $finish;
    end

    // Monitor key signals in the simulation console
    initial begin
        $display("Time\tFloor\tMoving\tDoor\tDir\tRequest");
        $monitor("%t\t%0d\t%b\t%b\t%b\t%b", $time, floor, moving, door, direction, req);
    end

endmodule

