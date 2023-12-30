`timescale 1ns/1ps

module uart_tx #(
    parameter CLOCKS_PER_PULSE = 4, //200_000_000/9600
              BITS_PER_WORD = 8,
              PACKET_SIZE = BITS_PER_WORD+5,
              W_OUT = 16,

    localparam NUM_WORDS = W_OUT/BITS_PER_WORD
) (
    input logic clk, rstn, s_valid,
    input logic [NUM_WORDS-1:0][BITS_PER_WORD-1:0] s_data,
    output logic tx, s_ready
);
    localparam END_BITS = PACKET_SIZE-BITS_PER_WORD-1;
    logic [NUM_WORDS-1:0][PACKET_SIZE-1:0] s_packets;
    logic [NUM_WORDS*PACKET_SIZE-1:0] m_packets;

    genvar n;
    for (n = 0; n < NUM_WORDS; n=n+1) begin
        assign s_packets[n] = {~(END_BITS'(0)), s_data[n], 1'b0};
    end
    assign tx = m_packets[0];

    //Counters
    logic [$clog2(NUM_WORDS*PACKET_SIZE)-1:0] c_pulses;
    logic [$clog2(CLOCKS_PER_PULSE)-1:0] c_clocks;

    //State Machine
    enum {IDLE, SEND} state;

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state <= IDLE;
            m_packets <= '1;
            {c_pulses, c_clocks} <= '0;
        end
        else begin
            case (state)
                IDLE : begin
                        state <= (s_valid) ? SEND : IDLE;
                        m_packets <= (s_valid) ? s_packets : m_packets;
                    end

                SEND : begin
                    if (c_clocks == CLOCKS_PER_PULSE-1) begin
                        c_clocks <= 0;

                        if(c_pulses == NUM_WORDS*PACKET_SIZE-1) begin
                            c_pulses <= 0;
                            m_packets <= '1;
                            state <= IDLE;
                        end
                        else begin
                            c_pulses <= c_pulses + 1;
                            m_packets <= (m_packets >> 1);
                        end
                    end else c_clocks <= c_clocks + 1;
                end
            endcase
        end
    end

    assign s_ready = (state == IDLE);
endmodule