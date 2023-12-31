`timescale 1ns/1ps

class Matrix #(W=8, R=8, C=8);
    typedef logic signed [R-1:0][C-1:0][W-1:0] m_t;
    rand m_t data;

    typedef logic signed [C-1:0][R-1:0][W-1:0] mt_t;
    function mt_t transpose ();
        foreach (transpose[c,r]) begin
            transpose[c][r] = this.data[r][c];
        end
    endfunction
endclass

virtual class Matmul #(W1=8, W2=8, R1=8 , C1=8, C2=8);
    localparam R2=C1, WO=W1+W2+$clog2(C1);
    typedef logic signed [R1-1:0][C1-1:0][W1-1:0] m1_t;
    typedef logic signed [R2-1:0][C2-1:0][W2-1:0] m2_t;
    typedef logic signed [R1-1:0][C2-1:0][WO-1:0] m3_t;

    static function mo_t matmul(m1_t m1, m2_t m2);
        foreach (matmul[r,c]) begin
            integer signed sum = 0;
            foreach (m1[,n]) begin
                sum += m1[r][n] * m2[n][c];
            end
            matmul[r][c] = sum;
        end
    endfunction
endclass

module matvec_mul_tb;

    logic clk=0;
    localparam CLK_PERIOD=10;
    initial forever #(CLK_PERIOD/2) clk <= ~clk;

    localparam R=2, C=2, W_X=3, W_K=4;
    localparam DEPTH = $clog2(C),
               W_Y = W_X + W_K + DEPTH,
               LATENCY = DEPTH + 1;
    
    logic signed [R-1:0][C-1:0][W_K-1:0] k;
    logic signed [C-1:0][W_X-1:0] x;
    logic signed [R-1:0][W_Y-1:0] y, y_exp;

    matvec_mul #(.R(R), .C(C), .W_X(W_X), .W_K(W_K)) dut (.*);

    Matrix #(.W(W_K), .R(R), .C(C)) km = new();
    Matrix #(.W(W_K), .R(R), .C(1)) xm = new();

    task drive_wait_assert;
        #1 k = km.data; x = xm.transpose();

        repeat(LATENCY) begin 
            @(posedge clk);
            #1 y_exp = Matmul#(W_K,W_X,R,C,1)::matmul(km.data, xm.data);
            assert (y==y_exp) $display("%p", y);
            else $error("y_dut[0]:%d != y_exp[0]:%d", y[0], y_exp[0]);
            k = '0; x = '0;
        end
        repeat(2) @(posedge clk);
    endtask

    int status;
    initial begin
        $dumpfile("matvec_mul_dump.vcd"); $dumpvars;
        @(posedge clk);
        km.data = '{default:1};
        xm.data = '{default:1};
        drive_wait_assert;

        @(posedge clk);
        for (int r=0; r<R; r++)
            for (int c=0; c<C; c++) begin
                km.data[r][c] <= 10*r + c;
                xm.data[c][0] <= 1;
            end
        drive_wait_assert;

        @(posedge clk);
        foreach (km.data[r,c]) begin
            km.data[r][c] <= 10*r + c;
            xm.data[c][0] <= 1;
        end
        drive_wait_assert;

        repeat(20) begin
            @(posedge clk);
            status = km.randomize();
            status = xm.randomize();
            drive_wait_assert;
        end
        $finish();
    end
    
endmodule