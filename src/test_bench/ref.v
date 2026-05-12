`timescale 1ns / 1ps

module alu_ref #(parameter DATA_WIDTH = 8,parameter CMD_WIDTH = 4)
    (
    input wire mode,
    input wire cin,
    input wire [1:0] inp_valid,
    input wire [DATA_WIDTH-1:0] opa,
    input wire [DATA_WIDTH-1:0] opb,
    input wire [CMD_WIDTH-1:0] cmd,

    output reg [2*DATA_WIDTH-1:0] res,
    output reg oflow, cout, g, l, e, err
);

    wire signed [DATA_WIDTH-1:0] opa_s = opa;
    wire signed [DATA_WIDTH-1:0] opb_s = opb;

    always @(*) begin
        res = 0;
        oflow = 0;
        cout = 0;
        g = 0;
        l = 0;
        e = 0;
        err = 0;

        if (mode) begin
            case (cmd)
                4'd0: 
                    if (inp_valid == 2'b11) begin
                        {cout, res[DATA_WIDTH-1:0]} = opa + opb;
                    end else begin
                        err = 1'b1;
                    end
                4'd1: 
                    if (inp_valid == 2'b11) begin
                        res[DATA_WIDTH-1:0] = opa - opb;
                        oflow = (opb > opa);
                    end else begin
                        err = 1'b1;
                    end
                4'd2: 
                    if (inp_valid == 2'b11) begin
                        {cout, res[DATA_WIDTH-1:0]} = opa + opb + cin;
                    end else begin
                        err = 1'b1;
                    end
                4'd3: 
                    if (inp_valid == 2'b11) begin
                        res[DATA_WIDTH-1:0] = opa - opb - cin;
                        oflow = ((opb + cin) > opa);
                    end else begin
                        err = 1'b1;
                    end
                4'd4: 
                    if (inp_valid == 2'b11 || inp_valid == 2'b01) begin
                        res = opa + 1;
                    end else begin
                        err = 1'b1;
                    end
                4'd5: 
                    if (inp_valid == 2'b11 || inp_valid == 2'b01) begin
                        res = opa - 1;
                    end else begin
                        err = 1'b1;
                    end
                4'd6: 
                    if (inp_valid == 2'b11 || inp_valid == 2'b10) begin
                        res = opb + 1;
                    end else begin
                        err = 1'b1;
                    end
                4'd7: 
                    if (inp_valid == 2'b11 || inp_valid == 2'b10) begin
                        res = opb - 1;
                    end else begin
                        err = 1'b1;
                    end
                4'd8: 
                    if (inp_valid == 2'b11) begin
                        g = (opa > opb);
                        l = (opa < opb);
                        e = (opa == opb);
                    end else begin
                        err = 1'b1;
                    end
                4'd9: 
                    if (inp_valid == 2'b11) begin
                        res = (opa + 1) * (opb + 1);
                    end else begin
                        err = 1'b1;
                    end
                4'd10: 
                    if (inp_valid == 2'b11) begin
                        res = (opa << 1) * opb;
                    end else begin
                        err = 1'b1;
                    end
                4'd11: 
                    if (inp_valid == 2'b11) begin
                        res[DATA_WIDTH-1:0] = opa_s + opb_s;
                        oflow = (opa[DATA_WIDTH-1] == opb[DATA_WIDTH-1]) && (res[DATA_WIDTH-1] != opa[DATA_WIDTH-1]);
                    end else begin
                        err = 1'b1;
                    end
                4'd12: 
                    if (inp_valid == 2'b11) begin
                        res[DATA_WIDTH-1:0] = opa_s - opb_s;
                        oflow = (opa[DATA_WIDTH-1] != opb[DATA_WIDTH-1]) && (res[DATA_WIDTH-1] != opa[DATA_WIDTH-1]);
                    end else begin
                        err = 1'b1;
                    end
                default: begin
                    err = 1'b1;
                end
            endcase
        end else begin
            case (cmd)
                4'd0: 
                    if (inp_valid == 2'b11) begin
                        res = (opa & opb);
                    end else begin
                        err = 1'b1;
                    end
                4'd1: 
                    if (inp_valid == 2'b11) begin
                        res = ~(opa & opb);
                    end else begin
                        err = 1'b1;
                    end
                4'd2: 
                    if (inp_valid == 2'b11) begin
                        res = (opa | opb);
                    end else begin
                        err = 1'b1;
                    end
                4'd3: 
                    if (inp_valid == 2'b11) begin
                        res = ~(opa | opb);
                    end else begin
                        err = 1'b1;
                    end
                4'd4: 
                    if (inp_valid == 2'b11) begin
                        res = (opa ^ opb);
                    end else begin
                        err = 1'b1;
                    end
                4'd5: 
                    if (inp_valid == 2'b11) begin
                        res = ~(opa ^ opb);
                    end else begin
                        err = 1'b1;
                    end
                4'd6: 
                    if (inp_valid[0]) begin
                        res = ~opa;
                    end else begin
                        err = 1'b1;
                    end
                4'd7: 
                    if (inp_valid[1]) begin
                        res = ~opb;
                    end else begin
                        err = 1'b1;
                    end
                4'd8: 
                    if (inp_valid[0]) begin
                        res = (opa >> 1);
                    end else begin
                        err = 1'b1;
                    end
                4'd9: 
                    if (inp_valid[0]) begin
                        res = (opa << 1);
                    end else begin
                        err = 1'b1;
                    end
                4'd10: 
                    if (inp_valid[1]) begin
                        res = (opb >> 1);
                    end else begin
                        err = 1'b1;
                    end
                4'd11: 
                    if (inp_valid[1]) begin
                        res = (opb << 1);
                    end else begin
                        err = 1'b1;
                    end
                4'd12: 
                    if (inp_valid == 2'b11) begin
                        casez (opb[3:0])
                            4'b?000: res = opa;
                            4'b?001: res = {opa[0], opa[DATA_WIDTH-1:1]};
                            4'b?010: res = {opa[1:0], opa[DATA_WIDTH-1:2]};
                            4'b?011: res = {opa[2:0], opa[DATA_WIDTH-1:3]};
                            4'b?100: res = {opa[3:0], opa[DATA_WIDTH-1:4]};
                            4'b?101: res = {opa[4:0], opa[DATA_WIDTH-1:5]};
                            4'b?110: res = {opa[5:0], opa[DATA_WIDTH-1:6]};
                            4'b?111: res = {opa[6:0], opa[DATA_WIDTH-1:DATA_WIDTH-7]};
                        endcase
                        if (opb[DATA_WIDTH-1:4] == 4'b1111 || opb[4] || opb[5] || opb[6] || opb[7]) begin
                            err = 1'b1;
                        end else begin
                            err = 1'b0;
                        end
                    end else begin
                        err = 1'b1;
                    end
                4'd13: 
                    if (inp_valid == 2'b11) begin
                        casez (opb[3:0])
                            4'b?000: res = opa;
                            4'b?001: res = {opa[DATA_WIDTH-2:0], opa[DATA_WIDTH-1]};
                            4'b?010: res = {opa[DATA_WIDTH-3:0], opa[DATA_WIDTH-1:DATA_WIDTH-2]};
                            4'b?011: res = {opa[DATA_WIDTH-4:0], opa[DATA_WIDTH-1:DATA_WIDTH-3]};
                            4'b?100: res = {opa[DATA_WIDTH-5:0], opa[DATA_WIDTH-1:DATA_WIDTH-4]};
                            4'b?101: res = {opa[DATA_WIDTH-6:0], opa[DATA_WIDTH-1:DATA_WIDTH-5]};
                            4'b?110: res = {opa[DATA_WIDTH-7:0], opa[DATA_WIDTH-1:DATA_WIDTH-6]};
                            4'b?111: res = {opa[0], opa[DATA_WIDTH-1:1]};
                        endcase
                        if (opb[DATA_WIDTH-1:4] == 4'b1111 || opb[4] || opb[5] || opb[6] || opb[7]) begin
                            err = 1'b1;
                        end else begin
                            err = 1'b0;
                        end
                    end else begin
                        err = 1'b1;
                    end
                default: begin
                    err = 1'b1;
                end
            endcase
        end
    end

endmodule
