`timescale 1ns / 1ps

module ALU #(parameter N = 8, parameter cmd = 4)(
input wire CLK,
input wire RST,
input wire CE,
input wire MODE,
input wire [1:0] INP_VALID,
input wire [cmd-1:0] CMD,
input wire [N-1:0] OPA,
input wire [N-1:0] OPB,
input wire CIN,
output reg ERR,
output reg OFLOW,
output reg COUT,
output reg G, L, E,
output reg [(N*2)-1:0] RES
);
reg DONE;
reg [N-1:0] PREV_OPA, PREV_OPB;
reg PREV_MODE, PREV_CIN;
reg [cmd-1:0] PREV_CMD;
reg [N-1:0] OPA_TEMP, OPB_TEMP;
reg [cmd-1:0] CMD_TEMP;
reg MODE_TEMP, CIN_TEMP;
reg [1:0] VALID_TEMP;
reg [1:0]PREV_INP_VALID;
wire [N-1:0] signed_sum;
assign signed_sum = $signed(OPA_TEMP) + $signed(OPB_TEMP);
wire [N-1:0] signed_dif;
assign signed_dif = $signed(OPA_TEMP) - $signed(OPB_TEMP);
reg [1:0] count;
wire inputs_changed;
assign inputs_changed = (INP_VALID != PREV_INP_VALID || MODE != PREV_MODE || OPA != PREV_OPA || OPB != PREV_OPB || CMD != PREV_CMD || PREV_CIN != CIN);
always @(posedge CLK or posedge RST) begin
    if (RST) begin
    count <= 0;
    PREV_OPA <= 0;
    PREV_OPB <= 0; 
    PREV_MODE <= 0;
    PREV_CMD <= 0; 
    PREV_CIN <= 0;
    OPA_TEMP <= 0; 
    OPB_TEMP <= 0; 
    CMD_TEMP <= 0; 
    MODE_TEMP <= 0; 
    CIN_TEMP <= 0; 
    VALID_TEMP <= 0;
    end else if (CE) begin
    PREV_OPA <= OPA;
    PREV_OPB <= OPB;
    PREV_MODE <= MODE;
    PREV_CMD <= CMD;
    PREV_CIN <= CIN;
    PREV_INP_VALID <=INP_VALID;
    if ((inputs_changed || OPA != OPA_TEMP || OPB != OPB_TEMP || CMD != CMD_TEMP || MODE != MODE_TEMP || CIN != CIN_TEMP || INP_VALID !=VALID_TEMP) && (count == 0 || count == 2 || (count == 1 && (!(MODE_TEMP == 1'b1 && (CMD_TEMP == 4'd9 || CMD_TEMP == 4'd10)) || CMD != CMD_TEMP)))) begin
        count <= 1; 
        OPA_TEMP <= OPA;
        OPB_TEMP <= OPB;
        CMD_TEMP <= CMD;
        MODE_TEMP <= MODE;
        CIN_TEMP <= CIN;
        VALID_TEMP <= INP_VALID;
    end 
    else if (count == 1 && (MODE_TEMP == 1'b1 && (CMD_TEMP == 4'd9 || CMD_TEMP == 4'd10))) begin
        count <= 2;
    end 
    else begin
        count <= 0;
    end
end
end
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        RES <= 0;
        DONE <= 0;
        {ERR, OFLOW, COUT, G, L, E} <= 6'b000000;
    end 
    else if (CE) begin
        DONE <= 0; 
        if (inputs_changed || (count == 2 && (OPA != OPA_TEMP || OPB != OPB_TEMP || CMD != CMD_TEMP || MODE != MODE_TEMP || CIN != CIN_TEMP))) begin
            {ERR, OFLOW, COUT, G, L, E} <= 6'b000000;
        end
        if (count == 1) begin
            if (MODE_TEMP) begin
            case (CMD_TEMP)
                4'd0: begin //ADD
                    if (VALID_TEMP == 2'b11) begin
                        RES  <= OPA_TEMP + OPB_TEMP;
                        COUT  <= ({1'b0, OPA_TEMP} + {1'b0, OPB_TEMP}) >> N;
                        OFLOW <= 1'b0;
                        {ERR, G, L, E} <= 4'b0000;
                        DONE <= 1;
                    end else ERR <= 1'b1;
                end
                4'd1: begin //SUB
                    if (VALID_TEMP == 2'b11) begin
                        RES   <= {{N{1'b0}},(OPA_TEMP - OPB_TEMP)};
                        COUT  <= 1'b0;
                        OFLOW <= (OPA_TEMP < OPB_TEMP);
                        {ERR, G, L, E} <= 4'b0000;
                        DONE <= 1;
                    end else ERR <= 1'b1;
                end
                4'd2: begin  //ADD_CIN
                    if (VALID_TEMP == 2'b11) begin
                        RES   <= OPA_TEMP + OPB_TEMP + CIN_TEMP;
                        COUT  <= ({1'b0, OPA_TEMP} + {1'b0, OPB_TEMP} + CIN_TEMP) >> N;
                        OFLOW <= 1'b0;
                        DONE <= 1;
                        {ERR, G, L, E} <= 4'b0000;
                    end else ERR <= 1'b1;
                end
                4'd3: begin  //SUB_CIN
                    if (VALID_TEMP == 2'b11) begin
                        RES  <= {{N{1'b0}},(OPA_TEMP - OPB_TEMP - CIN_TEMP)};
                        COUT  <= 1'b0;
                        DONE <= 1;
                        OFLOW <= ({1'b0, OPA_TEMP} < ({1'b0, OPB_TEMP} + CIN_TEMP));
                        {ERR, G, L, E} <= 4'b0000;
                    end else ERR <= 1'b1;
                end
                4'd4: begin  //INC_A
                    if (VALID_TEMP[0]) begin
                        RES   <= {{N{1'b0}},(OPA_TEMP + 1'b1)};
                        DONE <= 1;
                        COUT  <= 1'b0;
                        OFLOW <= 1'b0;
                        {ERR, G, L, E} <= 4'b0000;
                    end else ERR <= 1'b1;
                end
                4'd5: begin  //DEC_A
                    if (VALID_TEMP[0]) begin
                        RES  <= {{N{1'b0}},(OPA_TEMP - 1'b1)};
                        COUT  <= 1'b0;
                        DONE <= 1;
                        OFLOW <= 1'b0;
                        {ERR, G, L, E} <= 4'b0000;
                    end else ERR <= 1'b1;
                end
                4'd6: begin  //INC_B
                    if (VALID_TEMP[1]) begin
                        RES   <= {{N{1'b0}},(OPB_TEMP + 1'b1)};
                        COUT  <= 1'b0;
                        OFLOW <= 1'b0;
                        DONE <= 1;
                        {ERR, G, L, E} <= 4'b0000;
                    end else ERR <= 1'b1;
                end
                4'd7: begin  //DEC_B
                    if (VALID_TEMP[1]) begin
                        RES <= {{N{1'b0}},(OPB_TEMP - 1'b1)};
                        COUT  <= 1'b0;
                        OFLOW <= 1'b0;
                        DONE <= 1;
                        {ERR, G, L, E} <= 4'b0000;
                    end else ERR <= 1'b1;
                end
                4'd8: begin  //CMP
                    if (VALID_TEMP == 2'b11) begin
                        RES   <= 0;
                        DONE <= 1;
                        {ERR, G, L, E} <= {1'b0, (OPA_TEMP > OPB_TEMP), (OPA_TEMP < OPB_TEMP), (OPA_TEMP == OPB_TEMP)};
                    end else ERR <= 1'b1;
                end
                4'd11: begin //SIGNED ADDITION
                    if (VALID_TEMP == 2'b11) begin
                        DONE <= 1;
                        RES   <= {{N{1'b0}},($signed(OPA_TEMP) + $signed(OPB_TEMP))};
                        OFLOW <= (OPA_TEMP[N-1] == OPB_TEMP[N-1]) && (signed_sum[N-1] != OPA_TEMP[N-1]);
                        G <= $signed(OPA_TEMP) >  $signed(OPB_TEMP);
                        L <= $signed(OPA_TEMP) <  $signed(OPB_TEMP);
                        E <= $signed(OPA_TEMP) == $signed(OPB_TEMP);
                        COUT <= 1'b0;
                    end else ERR <= 1'b1;
                end
                4'd12: begin //SIGNED SUB
                    if (VALID_TEMP == 2'b11) begin
                        RES <= {{N{1'b0}},($signed(OPA_TEMP) - $signed(OPB_TEMP))};
                        DONE <= 1;
                        G <= $signed(OPA_TEMP) >  $signed(OPB_TEMP);
                        L <= $signed(OPA_TEMP) <  $signed(OPB_TEMP);
                        E <= $signed(OPA_TEMP) == $signed(OPB_TEMP);
                        COUT <= 1'b0;
                        OFLOW <= (OPA_TEMP[N-1] != OPB_TEMP[N-1]) && (signed_dif[N-1] != OPA_TEMP[N-1]);
                    end else ERR <= 1'b1;
                end
                default: RES <= RES;
            endcase
        end else begin
            case(CMD_TEMP)
                4'd0: begin //AND
                    if(VALID_TEMP==2'b11) begin
                        RES <= {{N{1'b0}},((OPA_TEMP & OPB_TEMP))};
                        DONE <= 1;
                        {ERR,G,L,E,COUT,OFLOW} <= 6'b000000;
                    end else ERR <= 1'b1;
                end
                4'd1: begin //NAND
                    if(VALID_TEMP==2'b11) begin
                        RES <= {{N{1'b0}},(~(OPA_TEMP & OPB_TEMP))};
                        DONE <= 1;
                        {ERR,G,L,E,COUT,OFLOW} <= 6'b000000;
                    end else ERR <= 1'b1;
                end
                4'd2: begin //OR
                    if(VALID_TEMP==2'b11) begin
                        RES <= {{N{1'b0}},(OPA_TEMP | OPB_TEMP)};
                        DONE <= 1;
                        {ERR,G,L,E,COUT,OFLOW} <= 6'b000000;
                    end else ERR <= 1'b1;
                end
                4'd3: begin //NOR
                    if(VALID_TEMP==2'b11) begin
                        RES <= {{N{1'b0}},(~(OPA_TEMP | OPB_TEMP))};
                        DONE <= 1;
                        {ERR,G,L,E,COUT,OFLOW} <= 6'b000000;
                    end else ERR <= 1'b1;
                end
                4'd4: begin //XOR
                    if(VALID_TEMP==2'b11) begin
                        RES <= {{N{1'b0}},(OPA_TEMP ^ OPB_TEMP)};
                        DONE <= 1;
                        {ERR,G,L,E,COUT,OFLOW} <= 6'b000000;
                    end else ERR <= 1'b1;
                end
                4'd5: begin //XNOR
                    if(VALID_TEMP==2'b11) begin
                        RES <= {{N{1'b0}},(~(OPA_TEMP ^ OPB_TEMP))};
                        DONE <= 1;
                        {ERR,G,L,E,COUT,OFLOW} <= 6'b000000;
                    end else ERR <= 1'b1;
                end
                4'd6: begin //NOT_A
                    if(VALID_TEMP[0]) begin
                        RES <= {{N{1'b0}},(~OPA_TEMP)};
                        DONE <= 1;
                        {ERR,G,L,E,COUT,OFLOW} <= 6'b000000;
                    end else ERR <= 1'b1;
                end
                4'd7: begin //NOT_B
                    if(VALID_TEMP[1]) begin
                        RES <= {{N{1'b0}},(~OPB_TEMP)};
                        DONE <= 1;
                        {ERR,G,L,E,COUT,OFLOW} <= 6'b000000;
                    end else ERR <= 1'b1;
                end
                4'd8: begin //OPA>>1
                    if(VALID_TEMP[0]) begin
                        RES <= {{N{1'b0}},(OPA_TEMP >> 1)};
                        DONE <= 1;
                        {ERR,G,L,E,COUT,OFLOW} <= 6'b000000;
                    end else ERR <= 1'b1;
                end
                4'd9: begin //OPA<<1
                    if(VALID_TEMP[0]) begin
                        RES <= {{N{1'b0}},(OPA_TEMP << 1)};
                        DONE <= 1;
                        {ERR,G,L,E,COUT,OFLOW} <= 6'b000000;
                    end else ERR <= 1'b1;
                end
                4'd10: begin //OPB>>1
                    if(VALID_TEMP[1]) begin
                        RES <= {{N{1'b0}},(OPB_TEMP >> 1)};
                        DONE <= 1;
                        {ERR,G,L,E,COUT,OFLOW} <= 6'b000000;
                    end else ERR <= 1'b1;
                end
                4'd11: begin //OPB<<1
                    if(VALID_TEMP[1]) begin
                        RES <= {{N{1'b0}},(OPB_TEMP << 1)};
                        DONE <= 1;
                        {ERR,G,L,E,COUT,OFLOW} <= 6'b000000;
                    end else ERR <= 1'b1;
                end
                4'd12: begin //ROTATE LEFT
                    if (VALID_TEMP == 2'b11) begin
                        RES <= {{N{1'b0}},((OPA_TEMP << OPB_TEMP[2:0]) | (OPA_TEMP >> (N - OPB_TEMP[2:0])))};
                        DONE <= 1;
                        ERR <= (|OPB_TEMP[7:4]);
                        {OFLOW, COUT, G, L, E} <= 5'b00000;
                    end else ERR <= 1'b1;
                end
                4'd13: begin //ROTATE RIGHT
                    if (VALID_TEMP == 2'b11) begin
                        RES <= {{N{1'b0}},((OPA_TEMP >> OPB_TEMP[2:0]) | (OPA_TEMP << (N - OPB_TEMP[2:0])))};
                        DONE <= 1;
                        ERR <= (|OPB_TEMP[7:4]);
                        {OFLOW, COUT, G, L, E} <= 5'b00000;
                    end else ERR <= 1'b1;
                end
                default: RES <= RES;
            endcase
        end
    end 
    
    if (count == 2) begin
        if (MODE_TEMP) begin
            if (CMD_TEMP == 4'd9) begin //INC_MULTIFICATION
                if (VALID_TEMP == 2'b11) begin
                    RES <= (OPA_TEMP + 1'b1) * (OPB_TEMP + 1'b1);
                    {ERR, OFLOW, COUT, G, L, E} <= 6'b000000;
                    DONE <= 1;
                end else ERR <= 1'b1;
            end
            else if (CMD_TEMP == 4'd10) begin //SHIFT_MULTIFICATION
                if (VALID_TEMP == 2'b11) begin
                    RES <= (OPA_TEMP << 1'b1) * (OPB_TEMP);
                    {ERR, OFLOW, COUT, G, L, E} <= 6'b000000;
                    DONE <= 1;
                end else ERR <= 1'b1;
            end
        end
    end
    end
end 
endmodule
