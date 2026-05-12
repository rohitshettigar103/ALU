`timescale 1ns/1ps

module tb_alu;

parameter N = 8;
reg CLK;
reg RST;
reg [1:0] INP_VALID;
reg MODE;
reg [3:0] CMD;
reg CE;
reg [N-1:0] OPA, OPB;
reg CIN;

wire ERR,RERR;
wire [(2*N)-1:0] RES,RRES; 
wire OFLOW,ROFLOW;
wire COUT,RCOUT;
wire G,RG, RL,L, RE,E;

alu_new #(.DATA_WIDTH(N)) dut (.clk(CLK), .rst(RST), .ce(CE), .opa(OPA), .opb(OPB), .cin(CIN), .inp_valid(INP_VALID), .mode(MODE), .cmd(CMD), .res(RES), .err(ERR), .cout(COUT), .oflow(OFLOW), .g(G), .l(L), .e(E));

alu_comb_ref #(.DATA_WIDTH(N)) uut (.mode(MODE), .cin(CIN), .inp_valid(INP_VALID), .opa(OPA), .opb(OPB), .cmd(CMD), .res(RRES), .err(RERR), .cout(RCOUT), .oflow(ROFLOW), .g(RG), .l(RL), .e(RE));

task DRIVE_INPUT;
    input t_rst, t_ce;
    input [N-1:0] t_opa, t_opb;
    input t_mode;
    input [3:0] t_cmd;
    input t_cin;
    input [1:0] t_valid;
    begin
        @(negedge CLK);
        RST = t_rst; CE = t_ce; OPA = t_opa; OPB = t_opb;
        MODE = t_mode; CMD = t_cmd; CIN = t_cin; INP_VALID = t_valid;
        #1;
    end
endtask

always #5 CLK = ~CLK;

task SCORECARD;
    begin
    #1;
    if(RES!==RRES || ERR!==RERR || RCOUT!==COUT || OFLOW!==ROFLOW || G!==RG || L!==RL || E!==RE) begin
        $display("TEST FAILED");
        $display("INP_VALID=%b MODE=%b CMD=%0d OPA=%0d OPB=%0d CIN=%b RST=%b CE=%b",INP_VALID,MODE,CMD,OPA,OPB,CIN,RST,CE);
        $display("Actual Result RES=%0d ERR=%b COUT=%b OFLOW=%b G=%b L=%b E=%b",RES,ERR,COUT,OFLOW,G,L,E);
        $display("Expected Result RES=%0d ERR=%b COUT=%b OFLOW=%b G=%b L=%b E=%b",RRES,RERR,RCOUT,ROFLOW,RG,RL,RE);
        $display("**************************************************\n");
    end
    else begin
        $display("TEST PASSED");
        $display("INP_VALID=%b MODE=%b CMD=%0d OPA=%0d OPB=%0d CIN=%b RST=%b CE=%b",INP_VALID,MODE,CMD,OPA,OPB,CIN,RST,CE);
        $display("Result RES=%0d ERR=%b COUT=%b OFLOW=%b G=%b L=%b E=%b",RES,ERR,COUT,OFLOW,G,L,E);
        $display("**************************************************\n");
    end
    end
endtask

initial begin
    CLK = 0;
    RST = 1; CE = 0; MODE = 0; CMD = 0; 
    OPA = 0; OPB = 0; CIN = 0; INP_VALID = 0;

    #15 RST = 0; 

    $display("--- STARTING TESTS ---");
    
    DRIVE_INPUT(1'b0,1'b1,8'd2,8'd2,1'b1,4'd0,1'd0,2'd11);
    #20; SCORECARD();
    DRIVE_INPUT(1'b0,1'b1,8'd0,8'd0,1'b1,4'd0,1'd0,2'd11);
    #20; SCORECARD();
    DRIVE_INPUT(1'b0,1'b1,8'd255,8'd255,1'b1,4'd0,1'd0,2'd11);
    #20; SCORECARD();
    DRIVE_INPUT(1'b0,1'b1,8'd2,8'd2,1'b1,4'd0,1'd0,2'd10);
    #20; SCORECARD();
    DRIVE_INPUT(1'b0,1'b1,8'd2,8'd2,1'b1,4'd0,1'd0,2'd01);
    #20; SCORECARD();

    DRIVE_INPUT(1'b0,1'b1,8'd3,8'd2,1'b1,4'd1,1'd0,2'd11);
    #20; SCORECARD();
    DRIVE_INPUT(1'b0,1'b1,8'd0,8'd0,1'b1,4'd1,1'd0,2'd11);
    #20; SCORECARD();
    DRIVE_INPUT(1'b0,1'b1,8'd255,8'd255,1'b1,4'd1,1'd0,2'd11);
    #20; SCORECARD();
    DRIVE_INPUT(1'b0,1'b1,8'd2,8'd8,1'b1,4'd1,1'd0,2'd11);
    #20; SCORECARD();
    DRIVE_INPUT(1'b0,1'b1,8'd2,8'd8,1'b1,4'd1,1'd0,2'd01);
    #20; SCORECARD();
    DRIVE_INPUT(1'b0,1'b1,8'd2,8'd8,1'b1,4'd1,1'd0,2'd10);
    #20; SCORECARD();

    DRIVE_INPUT(1'b0,1'b1,8'd3,8'd2,1'b1,4'd3,1'd1,2'd11);
    #20; SCORECARD();
    DRIVE_INPUT(1'b0,1'b1,8'd0,8'd0,1'b1,4'd3,1'd1,2'd11);
    #20; SCORECARD();
    DRIVE_INPUT(1'b0,1'b1,8'd255,8'd255,1'b1,4'd3,1'd0,2'd11);
    #20; SCORECARD();
    DRIVE_INPUT(1'b0,1'b1,8'd2,8'd8,1'b1,4'd3,1'd0,2'd11);
    #20; SCORECARD();
    DRIVE_INPUT(1'b0,1'b1,8'd2,8'd8,1'b1,4'd3,1'd0,2'd01);
    #20; SCORECARD();
    DRIVE_INPUT(1'b0,1'b1,8'd2,8'd8,1'b1,4'd3,1'd0,2'd10);
    #20; SCORECARD();

    DRIVE_INPUT(1'b0,1'b1,8'd3,8'd2,1'b1,4'd2,1'd1,2'd11);
    #20; SCORECARD();
    DRIVE_INPUT(1'b0,1'b1,8'd0,8'd0,1'b1,4'd2,1'd1,2'd11);
    #20; SCORECARD();
    DRIVE_INPUT(1'b0,1'b1,8'd255,8'd255,1'b1,4'd2,1'd1,2'd11);
    #20; SCORECARD();
    DRIVE_INPUT(1'b0,1'b1,8'd2,8'd8,1'b1,4'd2,1'd1,2'd11);
    #20; SCORECARD();
    DRIVE_INPUT(1'b0,1'b1,8'd253,8'd1,1'b1,4'd2,1'd1,2'd10);
    #20; SCORECARD();
    DRIVE_INPUT(1'b0,1'b1,8'd253,8'd1,1'b1,4'd2,1'd1,2'd01);
    #20; SCORECARD();

    DRIVE_INPUT(1'b0,1'b1,8'd10,8'd0,1'b1,4'd4,1'b0,2'b11);
    #20; SCORECARD();
    DRIVE_INPUT(1'b0,1'b1,8'd0,8'd0,1'b1,4'd4,1'b0,2'b11);
    #20; SCORECARD();
    DRIVE_INPUT(1'b0,1'b1,8'd255,8'd0,1'b1,4'd4,1'b0,2'b11);
    #20; SCORECARD();
    DRIVE_INPUT(1'b0, 1'b1, 8'd15, 8'd255, 1'b1, 4'd4, 1'b0, 2'b11);
    #20; SCORECARD();
    DRIVE_INPUT(1'b0, 1'b1, 8'd10, 8'd0, 1'b1, 4'd4, 1'b0, 2'b10);
    #20; SCORECARD();
    DRIVE_INPUT(1'b0, 1'b1, 8'd10, 8'd0, 1'b1, 4'd4, 1'b0, 2'b01);
    #20; SCORECARD();

    DRIVE_INPUT(1'b0,1'b1,8'd10,8'd0,1'b1,4'd5,1'b0,2'b11);
    #20; SCORECARD();
    DRIVE_INPUT(1'b0, 1'b1, 8'd0, 8'd0, 1'b1, 4'd5, 1'b0, 2'b11);
    #20; SCORECARD();
    DRIVE_INPUT(1'b0, 1'b1, 8'd255, 8'd0, 1'b1, 4'd5, 1'b0, 2'b11);
    #20; SCORECARD();
    DRIVE_INPUT(1'b0, 1'b1, 8'd15, 8'd255, 1'b1, 4'd5, 1'b0, 2'b11);
    #20; SCORECARD();
    DRIVE_INPUT(1'b0, 1'b1, 8'd10, 8'd0, 1'b1, 4'd5, 1'b0, 2'b10);
    #20; SCORECARD();
    DRIVE_INPUT(1'b0, 1'b1, 8'd10, 8'd0, 1'b1, 4'd5, 1'b0, 2'b01);
    #20; SCORECARD();

    DRIVE_INPUT(1'b0,1'b1,8'd5,8'd4,1'b1,4'd9,1'b0,2'b11);
    #30; SCORECARD();
    DRIVE_INPUT(1'b0,1'b1,8'd10,8'd0,1'b1,4'd9,1'b0,2'b11);
    #30; SCORECARD();
    DRIVE_INPUT(1'b0, 1'b1, 8'd255, 8'd255, 1'b1, 4'd9, 1'b0, 2'b11);
    #30; SCORECARD();
    DRIVE_INPUT(1'b0, 1'b1, 8'd128, 8'd2, 1'b1, 4'd9, 1'b0, 2'b11);
    #30; SCORECARD();
    DRIVE_INPUT(1'b0, 1'b1, 8'd5, 8'd4, 1'b1, 4'd9, 1'b0, 2'b01);
    #30; SCORECARD();
    DRIVE_INPUT(1'b0, 1'b1, 8'd5, 8'd4, 1'b1, 4'd9, 1'b0, 2'b10);
    #30; SCORECARD();

    DRIVE_INPUT(1'b0,1'b1,8'b10110011,8'd1,1'b0,4'd12,1'b0,2'b11);
    #20; SCORECARD();
    DRIVE_INPUT(1'b0, 1'b1, 8'b10000000, 8'd1, 1'b0, 4'd12, 1'b0, 2'b11);
    #20; SCORECARD();
    DRIVE_INPUT(1'b0, 1'b1, 8'b10110011, 8'd0, 1'b0, 4'd12, 1'b0, 2'b11);
    #20; SCORECARD();
    DRIVE_INPUT(1'b0, 1'b1, 8'b10110011, 8'd7, 1'b0, 4'd12, 1'b0, 2'b11);
    #20; SCORECARD();
    DRIVE_INPUT(1'b0, 1'b1, 8'b10101010, 8'd8, 1'b0, 4'd12, 1'b0, 2'b11);
    #20; SCORECARD();

    DRIVE_INPUT(1'b0,1'b1,8'b00000001,8'd1,1'b0,4'd13,1'b0,2'b11);
    #20; SCORECARD();
    DRIVE_INPUT(1'b0, 1'b1, 8'b10110011, 8'd1, 1'b0, 4'd13, 1'b0, 2'b11);
    #20; SCORECARD();
    DRIVE_INPUT(1'b0, 1'b1, 8'b10110011, 8'd0, 1'b0, 4'd13, 1'b0, 2'b11);
    #20; SCORECARD();
    DRIVE_INPUT(1'b0, 1'b1, 8'b10110011, 8'd7, 1'b0, 4'd13, 1'b0, 2'b11);
    #20; SCORECARD();
    DRIVE_INPUT(1'b0, 1'b1, 8'b10101010, 8'd8, 1'b0, 4'd13, 1'b0, 2'b11);
    #20; SCORECARD();

    DRIVE_INPUT(1'b0,1'b0,8'b10110011,8'd2,1'b0,4'd13,1'b0,2'b10);
    #10; SCORECARD();
    DRIVE_INPUT(1'b1,1'b1,8'b10110011,8'd2,1'b0,4'd13,1'b0,2'b10);
    #10; SCORECARD();

    DRIVE_INPUT(1'b0,1'b1,8'd128,8'd127,1'b0,4'd15,1'b0,2'b10);
    #20; SCORECARD();
    DRIVE_INPUT(1'b0, 1'b1, 8'd128, 8'd127, 1'b1, 4'd15, 1'b0, 2'b10);
    #20; SCORECARD();

    #50 $finish;
end

endmodule
