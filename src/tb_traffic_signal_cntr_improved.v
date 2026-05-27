`timescale 1ns / 1ps

module tb_traffic_signal_cntr_improved;

wire [1:0] main_highway_signal;
wire [1:0] country_signal;

reg car_on_countryroad;
reg emergency;
reg night_mode;
reg reset;
reg clock;


// Unit Under Test
traffic_signal_cntr_improved uut (
    .hwy(main_highway_signal),
    .cntry(country_signal),
    .car_country(car_on_countryroad),
    .emergency(emergency),
    .night_mode(night_mode),
    .clock(clock),
    .reset(reset)
);


// Clock generation
// clock period = 40 ns
initial begin
    clock = 1'b0;
    forever #20 clock = ~clock;
end


// Input stimulus
initial begin

    // Initial values
    reset = 1'b1;
    car_on_countryroad = 1'b0;
    emergency = 1'b0;
    night_mode = 1'b0;


    // ==================================================
    // Test 0. Reset
    // Expected: state = S0
    // hwy = GREEN(10), cntry = RED(00)
    // ==================================================
    @(posedge clock);
    @(negedge clock);
    reset = 1'b0;

    @(posedge clock);


    // ==================================================
    // Test 1. Normal cycle 1
    // car_country remains 1
    // Expected:
    // S0 -> S1 -> S2 -> S3
    // S3 is maintained until green_count reaches GREEN_LIMIT
    // Then S3 -> S4 -> S0
    // ==================================================
    @(negedge clock);
    car_on_countryroad = 1'b1;
    emergency = 1'b0;
    night_mode = 1'b0;

    @(posedge clock); // Expected: S1
    @(posedge clock); // Expected: S2
    @(posedge clock); // Expected: S3

    // car_on_countryroad remains 1 here
    // Check Country road green time limit
    @(posedge clock); // Expected: S3, green_count increases
    @(posedge clock); // Expected: S3, green_count increases
    @(posedge clock); // Expected: S3, green_count reaches limit
    @(posedge clock); // Expected: S4 by GREEN_LIMIT

    @(negedge clock);
    car_on_countryroad = 1'b0;

    @(posedge clock); // Expected: S0


    // ==================================================
    // Test 2. Normal cycle 2
    // car_country becomes 0 before GREEN_LIMIT
    // Expected:
    // S0 -> S1 -> S2 -> S3
    // In S3, car_country becomes 0
    // Then S3 -> S4 -> S0
    // ==================================================
    @(negedge clock);
    car_on_countryroad = 1'b1;
    emergency = 1'b0;
    night_mode = 1'b0;

    @(posedge clock); // Expected: S1
    @(posedge clock); // Expected: S2
    @(posedge clock); // Expected: S3

    // Car disappears before green_count reaches GREEN_LIMIT
    @(negedge clock);
    car_on_countryroad = 1'b0;

    @(posedge clock); // Expected: S4 because car_country = 0
    @(posedge clock); // Expected: S0


    // ==================================================
    // Test 3-1. Emergency at S0
    // Expected:
    // S0 -> S5
    // emergency off -> S0
    // ==================================================
    @(negedge clock);
    car_on_countryroad = 1'b0;
    emergency = 1'b1;
    night_mode = 1'b0;

    @(posedge clock); // Expected: S5

    @(negedge clock);
    emergency = 1'b0;

    @(posedge clock); // Expected: S0


    // ==================================================
    // Test 3-2. Emergency at S1
    // Expected:
    // S0 -> S1 -> S5
    // emergency off -> S0
    // ==================================================
    @(negedge clock);
    car_on_countryroad = 1'b1;
    emergency = 1'b0;
    night_mode = 1'b0;

    @(posedge clock); // Expected: S1

    @(negedge clock);
    emergency = 1'b1;

    @(posedge clock); // Expected: S5

    @(negedge clock);
    emergency = 1'b0;
    car_on_countryroad = 1'b0;

    @(posedge clock); // Expected: S0


    // ==================================================
    // Test 3-3. Emergency at S2
    // Expected:
    // S0 -> S1 -> S2 -> S5
    // emergency off -> S0
    // ==================================================
    @(negedge clock);
    car_on_countryroad = 1'b1;
    emergency = 1'b0;
    night_mode = 1'b0;

    @(posedge clock); // Expected: S1
    @(posedge clock); // Expected: S2

    @(negedge clock);
    emergency = 1'b1;

    @(posedge clock); // Expected: S5

    @(negedge clock);
    emergency = 1'b0;
    car_on_countryroad = 1'b0;

    @(posedge clock); // Expected: S0


    // ==================================================
    // Test 3-4. Emergency at S3
    // Expected:
    // S0 -> S1 -> S2 -> S3 -> S5
    // emergency off -> S0
    // ==================================================
    @(negedge clock);
    car_on_countryroad = 1'b1;
    emergency = 1'b0;
    night_mode = 1'b0;

    @(posedge clock); // Expected: S1
    @(posedge clock); // Expected: S2
    @(posedge clock); // Expected: S3

    @(negedge clock);
    emergency = 1'b1;

    @(posedge clock); // Expected: S5

    @(negedge clock);
    emergency = 1'b0;
    car_on_countryroad = 1'b0;

    @(posedge clock); // Expected: S0


    // ==================================================
    // Test 3-5. Emergency at S4
    // Expected:
    // S0 -> S1 -> S2 -> S3
    // car_country becomes 0
    // S3 -> S4
    // emergency at S4
    // S4 -> S5
    // emergency off -> S0
    // ==================================================
    @(negedge clock);
    car_on_countryroad = 1'b1;
    emergency = 1'b0;
    night_mode = 1'b0;

    @(posedge clock); // Expected: S1
    @(posedge clock); // Expected: S2
    @(posedge clock); // Expected: S3

    @(negedge clock);
    car_on_countryroad = 1'b0;

    @(posedge clock); // Expected: S4

    @(negedge clock);
    emergency = 1'b1;

    @(posedge clock); // Expected: S5

    @(negedge clock);
    emergency = 1'b0;

    @(posedge clock); // Expected: S0


    // ==================================================
    // Test 4. Night mode check
    // Expected:
    // S0 -> S6
    // hwy = OFF(11), cntry = OFF(11)
    // night_mode off -> S0
    // ==================================================
    @(negedge clock);
    car_on_countryroad = 1'b0;
    emergency = 1'b0;
    night_mode = 1'b1;

    @(posedge clock); // Expected: S6

    // In night mode, car_country should be ignored
    @(negedge clock);
    car_on_countryroad = 1'b1;

    @(posedge clock); // Expected: S6
    @(posedge clock); // Expected: S6

    @(negedge clock);
    night_mode = 1'b0;
    car_on_countryroad = 1'b0;

    @(posedge clock); // Expected: S0


    // ==================================================
    // Test 5. Night mode + Emergency
    // Expected:
    // S0 -> S6
    // emergency = 1
    // S6 -> S5
    // emergency = 0 while night_mode remains 1
    // S5 -> S6
    // night_mode = 0
    // S6 -> S0
    // ==================================================
    @(negedge clock);
    car_on_countryroad = 1'b0;
    emergency = 1'b0;
    night_mode = 1'b1;

    @(posedge clock); // Expected: S6

    @(negedge clock);
    emergency = 1'b1;

    @(posedge clock); // Expected: S5

    @(negedge clock);
    emergency = 1'b0;
    night_mode = 1'b1;

    @(posedge clock); // Expected: S6

    @(negedge clock);
    night_mode = 1'b0;

    @(posedge clock); // Expected: S0


    // Finish simulation
    #200;
    $finish;

end


// Monitor for simulation console
initial begin
    $monitor("time=%0t reset=%b car=%b emergency=%b night=%b state=%d green_count=%d hwy=%b cntry=%b",
             $time,
             reset,
             car_on_countryroad,
             emergency,
             night_mode,
             uut.state,
             uut.green_count,
             main_highway_signal,
             country_signal);
end

endmodule
