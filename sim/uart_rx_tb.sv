`timescale 1ns/1ps

module uart_rx_tb;
    localparam CLOCKS_PER_PULSE = 4, W_OUT = 16, BITS_PER_WORD = 8,
               NUM_WORDS = W_OUT/BITS_PER_WORD,
               CLK_PERIOD = 10;

    logic clk=0, rstn=0, rx=1, m_valid;
    logic [NUM_WORDS-1:0][BITS_PER_WORD-1:0] m_data, data;
    logic [BITS_PER_WORD+2-1:0] packet;

    initial forever #(CLK_PERIOD/2) clk <= ~clk;

    uart_rx #(
        .CLOCKS_PER_PULSE(CLOCKS_PER_PULSE),
        .W_OUT(W_OUT),
        .BITS_PER_WORD(BITS_PER_WORD)
    ) dut (.*);

    //driver
    initial begin
        $dumpfile("uart_rx_dump.vcd"); $dumpvars;
        repeat(2) @(posedge clk) #1;
        rstn = 1;
        repeat (5) @(posedge clk) #1;

        repeat (10) begin
            data = $urandom();

            for (int iw = 0; iw < NUM_WORDS; iw = iw+1) begin
                packet = {1'b1, data[iw], 1'b0};

                repeat ($urandom_range(1,20)) @(posedge clk); // random delay between packets

                    for (int ib = 0; ib < BITS_PER_WORD; ib = ib+1) begin // send data, hold every bit for 4 clocks
                        repeat (CLOCKS_PER_PULSE) begin
                            #1 rx <= packet[ib];
                            @(posedge clk);
                        end
                    end
            end
            repeat ($urandom_range(1,100)) @(posedge clk); // random delay between sets
        end
        $finish();
    end

    //Monitor
    initial forever begin
        @(posedge clk) if (m_valid) assert (m_data == data) $$display("OK, %b", m_data);
            else $error("Sent %b, got %b", data, m_data);
    end

    //Count UART bits on waveform

    int bits;
    initial forever begin
        bits = 0;
        wait(!rx);
        for (int n=0; n<BITS_PER_WORD+2; n++) begin
            bits += 1; repeat(CLOCKS_PER_PULSE) @(posedge clk);
        end
    end

endmodule