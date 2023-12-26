`timescale 1ns/1ps

module p2s #(
    parameter N = 8
) (
    input clk, rstn,
    input logic [7:0] par_data,
    input logic par_valid,
    output logic par_ready,

    output logic ser_data,
    output logic ser_valid,
    input logic ser_ready
);

localparam N_BITS = $clog2(N);
enum logic { TX, RX } state, next_state;
logic [N_BITS-1:0] count;
logic [N-1:0] shift_reg;

always_comb begin
    unique case(state)
        RX: next_state = par_valid ? TX : RX;
        TX: next_state = (ser_ready && (count==N-1)) ? RX : TX;
    endcase
end

always_ff @( posedge clk or negedge rstn ) begin
    state <= (!rstn) ? RX : next_state;
end

assign ser_data = shift_reg[0];
assign par_ready = (state == RX);
assign ser_valid = (state == TX);

always_ff @( posedge clk or negedge rstn ) begin
    if (!rstn) count <= 'd0;
    else unique case (state)
        RX : begin
            shift_reg <= par_data;
            count <= 'd0;
        end
        TX : begin
            shift_reg <= (ser_ready) ? shift_reg >> 1 : shift_reg;
            count <= (ser_ready) ? count + 1'd1 : count;
        end
    endcase
end

endmodule