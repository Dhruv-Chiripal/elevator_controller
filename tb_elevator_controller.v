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

    // Instantiate the Device Under Test (DUT)
    elevator_controller dut (
        .clk(clk),
        .reset(reset),
        .req(req),
        .floor(floor),
        .moving(moving),
        .door(door),
        .direction(direction)
    );

    // Clock Generation: 10ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Simulation Sequence
    initial begin
        // $monitor to print signals whenever they change
        $monitor("Time=%0t | Floor: %d | Moving: %b | Door: %b | Dir: %b | Reqs(internal): %b",
                 $time, floor, moving, door, direction, dut.requests);

        // --- Test Sequence ---
        
        // Reset to initialize the system
        $display("\n--- Initializing with Reset ---");
        reset = 1;
        req = 4'b0000;
        #20; // Hold reset for 2 clock cycles
        reset = 0;
        #10;
        
        // Test Case 1: Simple UP then DOWN trip
        $display("\n--- TC1: Simple trip from Floor 0 -> 2 -> 1 ---");
        req = 4'b0100; #10; req = 4'b0000; // Request floor 2
        #200; 
        req = 4'b0010; #10; req = 4'b0000; // Request floor 1
        #200; 

        // Test Case 2: Multiple requests in the same direction (UP)
        $display("\n--- TC2: Multiple UP requests (3 and 2 from 0) ---");
        req = 4'b1100; #10; req = 4'b0000; // Request floors 2 and 3
        #300;

        // Test Case 3: Multiple requests in the same direction (DOWN)
        $display("\n--- TC3: Multiple DOWN requests (0 and 1 from 3) ---");
        req = 4'b0011; #10; req = 4'b0000; // Request floors 0 and 1
        #300;

        // Test Case 4: UP-first Priority Test
        $display("\n--- TC4: UP-first priority (req 0 and 2 from floor 1) ---");
        // Elevator is at floor 0. First, go to floor 1.
        req = 4'b0010; #10; req = 4'b0000;
        #200;
        // Now at floor 1, request floors 0 and 2. Should go UP first.
        req = 4'b0101; #10; req = 4'b0000;
        #400; 

        // Test Case 5: Ignore request in opposite direction while moving UP
        $display("\n--- TC5: Ignore opposite request while moving UP ---");
        // From floor 0, request floor 3
        req = 4'b1000; #10; req = 4'b0000;
        #25; // Wait until it's moving (at floor 1)
        // Now request floor 0. It should be ignored until the trip up is done.
        req = 4'b0001; #10; req = 4'b0000;
        #500; 

        // End simulation
        $display("\n--- All Complex Test Cases Finished ---");
        $finish;
    end

endmodule
