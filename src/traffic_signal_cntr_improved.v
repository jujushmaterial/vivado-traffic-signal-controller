`timescale 1ns / 1ps

module traffic_signal_cntr_improved (
    hwy,
    cntry,
    car_country,
    emergency,
    night_mode,
    clock,
    reset
);

output [1:0] hwy, cntry;
reg    [1:0] hwy, cntry;

input car_country;
input emergency;
input night_mode;
input clock, reset;

// Light color definition
// R = 00, Y = 01, G = 10, OFF = 11
parameter RED    = 2'd0;
parameter YELLOW = 2'd1;
parameter GREEN  = 2'd2;
parameter OFF    = 2'd3;

// State definition
// State        HWY       CNTRY
parameter S0 = 3'd0; // GREEN     RED
parameter S1 = 3'd1; // YELLOW    RED
parameter S2 = 3'd2; // RED       RED
parameter S3 = 3'd3; // RED       GREEN
parameter S4 = 3'd4; // RED       YELLOW
parameter S5 = 3'd5; // GREEN     RED      Emergency mode
parameter S6 = 3'd6; // OFF       OFF      Night mode

// Country road green time limit
// Simulation에서 확인하기 쉽게 3 clock으로 설정
parameter GREEN_LIMIT = 3'd3;

// Internal state variables
reg [2:0] state;
reg [2:0] next_state;

// Counter for limiting Country Road green time
reg [2:0] green_count;


// State Register + Green Counter
always @(posedge clock) begin
    if (reset) begin
        state <= S0;
        green_count <= 3'd0;
    end else begin
        state <= next_state;

        // Count only when current state is S3
        // S3 = Country Road Green state
        if (state == S3) begin
            if (green_count < GREEN_LIMIT)
                green_count <= green_count + 3'd1;
            else
                green_count <= green_count;
        end else begin
            green_count <= 3'd0;
        end
    end
end


// Next State Function - combinational logic
always @(*) begin
    next_state = state; // default: keep current state

    case (state)

        // S0: Main highway Green, Country road Red
        S0: begin
            if (emergency)
                next_state = S5;
            else if (night_mode)
                next_state = S6;
            else if (car_country)
                next_state = S1;
            else
                next_state = S0;
        end

        // S1: Main highway Yellow, Country road Red
        S1: begin
            if (emergency)
                next_state = S5;
            else
                next_state = S2;
        end

        // S2: All Red
        S2: begin
            if (emergency)
                next_state = S5;
            else
                next_state = S3;
        end

        // S3: Main highway Red, Country road Green
        // Country road green is limited by green_count
        S3: begin
            if (emergency)
                next_state = S5;
            else if (car_country && (green_count < GREEN_LIMIT))
                next_state = S3;
            else
                next_state = S4;
        end

        // S4: Main highway Red, Country road Yellow
        S4: begin
            if (emergency)
                next_state = S5;
            else
                next_state = S0;
        end

        // S5: Emergency mode
        // Main highway Green, Country road Red
        S5: begin
            if (emergency)
                next_state = S5;
            else if (night_mode)
                next_state = S6;
            else
                next_state = S0;
        end

        // S6: Night mode
        // Both lights OFF
        S6: begin
            if (emergency)
                next_state = S5;
            else if (night_mode)
                next_state = S6;
            else
                next_state = S0;
        end

        default: begin
            next_state = S0;
        end

    endcase
end


// Output Function - Moore output logic
always @(*) begin
    case (state)

        S0: begin
            hwy   = GREEN;
            cntry = RED;
        end

        S1: begin
            hwy   = YELLOW;
            cntry = RED;
        end

        S2: begin
            hwy   = RED;
            cntry = RED;
        end

        S3: begin
            hwy   = RED;
            cntry = GREEN;
        end

        S4: begin
            hwy   = RED;
            cntry = YELLOW;
        end

        S5: begin
            hwy   = GREEN;
            cntry = RED;
        end

        S6: begin
            hwy   = OFF;
            cntry = OFF;
        end

        default: begin
            hwy   = GREEN;
            cntry = RED;
        end

    endcase
end

endmodule
