`timescale 1ns / 1ps

module tb_elevator_controller;

    // Inputs
    reg clk;
    reg reset;
    reg [3:0] req;

    // Outputs
    wire [1:0] floor;
    wire moving;
    wire door;
    wire direction;

    // Instantiate DUT
    elevator_controller dut (
        .clk(clk),
        .reset(reset),
        .req(req),
        .floor(floor),
        .moving(moving),
        .door(door),
        .direction(direction)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test sequence
    initial begin
        $monitor("Time=%0t | Floor: %d | Moving: %b | Door: %b | Dir: %b | Reqs: %b",
                 $time, floor, moving, door, direction, dut.requests);

        // Reset
        reset = 1; req = 0;
        #20; reset = 0; #10;

        // Test Case 1: 0 → 2 → 1
        $display("\n--- TC1 ---");
        req = 4'b0100; #10; req = 0; #200;
        req = 4'b0010; #10; req = 0; #200;

        // Test Case 2: 0 → 2, 3
        $display("\n--- TC2 ---");
        req = 4'b1100; #10; req = 0; #300;

        // Test Case 3: 3 → 1, 0
        $display("\n--- TC3 ---");
        req = 4'b0011; #10; req = 0; #300;

        // Test Case 4: UP priority from floor 1
        $display("\n--- TC4 ---");
        req = 4'b0010; #10; req = 0; #200;
        req = 4'b0101; #10; req = 0; #400;

        // Test Case 5: Opposite request while going up
        $display("\n--- TC5 ---");
        req = 4'b1000; #10; req = 0; #25;
        req = 4'b0001; #10; req = 0; #500;

        $display("\n--- DONE ---");
        $finish;
    end

endmodule
