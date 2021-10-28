`timescale 1ns/1ps

module alu_tb();
	
`define DEBUG_

`define FLAG_C    4'b1000
`define FLAG_OF   4'b0100
`define FLAG_ZERO 4'b0010
`define FLAG_NEG  4'b0001

`define ERR_DATA  3'b100
`define ERR_CRC   3'b010
`define ERR_OP    3'b001
    
typedef enum bit {
	DATA_PACKET = 1'b0,
	CMD_PACKET  = 1'b1
} packet_type_t;
    
typedef enum bit[1:0] {
    TRANSMISSION_CORRECT = 2'b00,
    TRANSMISSION_ERROR   = 2'b01,
    NO_TRANSMISSION      = 2'b10
} transmission_result_t;

typedef enum bit[2:0] {
    AND_OP = 3'b000,
    OR_OP  = 3'b001,
    ADD_OP = 3'b100,
    SUB_OP = 3'b101,
    NO_OP  = 3'b111,
    RST_OP = 3'b010
} operation_t;

bit clk, rst_n, sin, sout; //TODO: logic
bit[31:0] A, B, C, C_expected;
operation_t op_set;
bit[7:0] ctl_byte;
transmission_result_t transmission_result;
bit[3:0] alu_flags, alu_flags_expected;
bit[3:0] crc4b;
bit[2:0] crc3b, crc3b_expected;
bit sim_data_error;
bit[5:0] err_flags, err_flags_expected;
bit parity, parity_expected;

string test_result = "PASSED";
    

//------------------------------------------------------------------------------
// DUT instantiation
//------------------------------------------------------------------------------

mtm_Alu u_mtm_Alu (
	.clk  (clk),   //posedge active clock
	.rst_n(rst_n), //synchronous reset active low
	.sin  (sin),   //serial data input
	.sout (sout)   //serial data output
	);
	
//------------------------------------------------------------------------------
// Generators
//------------------------------------------------------------------------------

initial begin : clk_gen
    clk = 0;
    forever begin : clk_frv
        #10;
        clk = ~clk;
    end
end

function [3:0] nextCRC4_D68;
    input [67:0] Data;
    input [3:0] crc;
    reg [67:0] d;
    reg [3:0] c;
    reg [3:0] newcrc;
    begin
    d = Data;
    c = crc;
    
    newcrc[0] = 
        d[66] ^ d[64] ^ d[63] ^ d[60] ^ d[56] ^ d[55] ^ d[54] ^ d[53] ^ d[51] ^ d[49] ^ d[48] ^ 
        d[45] ^ d[41] ^ d[40] ^ d[39] ^ d[38] ^ d[36] ^ d[34] ^ d[33] ^ d[30] ^ d[26] ^ d[25] ^ 
        d[24] ^ d[23] ^ d[21] ^ d[19] ^ d[18] ^ d[15] ^ d[11] ^ d[10] ^ d[9] ^ d[8] ^ d[6] ^ 
        d[4] ^ d[3] ^ d[0] ^ c[0] ^ c[2];
    newcrc[1] = 
        d[67] ^ d[66] ^ d[65] ^ d[63] ^ d[61] ^ d[60] ^ d[57] ^ d[53] ^ d[52] ^ d[51] ^ d[50] ^ 
        d[48] ^ d[46] ^ d[45] ^ d[42] ^ d[38] ^ d[37] ^ d[36] ^ d[35] ^ d[33] ^ d[31] ^ d[30] ^ 
        d[27] ^ d[23] ^ d[22] ^ d[21] ^ d[20] ^ d[18] ^ d[16] ^ d[15] ^ d[12] ^ d[8] ^ d[7] ^ 
        d[6] ^ d[5] ^ d[3] ^ d[1] ^ d[0] ^ c[1] ^ c[2] ^ c[3];
    newcrc[2] = 
        d[67] ^ d[66] ^ d[64] ^ d[62] ^ d[61] ^ d[58] ^ d[54] ^ d[53] ^ d[52] ^ d[51] ^ d[49] ^ 
        d[47] ^ d[46] ^ d[43] ^ d[39] ^ d[38] ^ d[37] ^ d[36] ^ d[34] ^ d[32] ^ d[31] ^ d[28] ^ 
        d[24] ^ d[23] ^ d[22] ^ d[21] ^ d[19] ^ d[17] ^ d[16] ^ d[13] ^ d[9] ^ d[8] ^ d[7] ^ 
        d[6] ^ d[4] ^ d[2] ^ d[1] ^ c[0] ^ c[2] ^ c[3];
    newcrc[3] = 
        d[67] ^ d[65] ^ d[63] ^ d[62] ^ d[59] ^ d[55] ^ d[54] ^ d[53] ^ d[52] ^ d[50] ^ d[48] ^ 
        d[47] ^ d[44] ^ d[40] ^ d[39] ^ d[38] ^ d[37] ^ d[35] ^ d[33] ^ d[32] ^ d[29] ^ d[25] ^ 
        d[24] ^ d[23] ^ d[22] ^ d[20] ^ d[18] ^ d[17] ^ d[14] ^ d[10] ^ d[9] ^ d[8] ^ d[7] ^ 
        d[5] ^ d[3] ^ d[2] ^ c[1] ^ c[3];
    nextCRC4_D68 = newcrc;
    end
endfunction

function [2:0] nextCRC3_D37;
    input [36:0] Data;
    input [2:0] crc;
    reg [36:0] d;
    reg [2:0] c;
    reg [2:0] newcrc;
    begin
        d = Data;
        c = crc;
        
        newcrc[0] = d[35] ^ d[32] ^ d[31] ^ d[30] ^ d[28] ^ d[25] ^ d[24] ^ d[23] ^ d[21] ^ d[18] ^
            d[17] ^ d[16] ^ d[14] ^ d[11] ^ d[10] ^ d[9] ^ d[7] ^ d[4] ^ d[3] ^ d[2] ^ d[0] ^ c[1];
        newcrc[1] = d[36] ^ d[35] ^ d[33] ^ d[30] ^ d[29] ^ d[28] ^ d[26] ^ d[23] ^ d[22] ^ d[21] ^
            d[19] ^ d[16] ^ d[15] ^ d[14] ^ d[12] ^ d[9] ^ d[8] ^ d[7] ^ d[5] ^ d[2] ^ d[1] ^
            d[0] ^ c[1] ^ c[2];
        newcrc[2] = d[36] ^ d[34] ^ d[31] ^ d[30] ^ d[29] ^ d[27] ^ d[24] ^ d[23] ^ d[22] ^ d[20] ^
            d[17] ^ d[16] ^ d[15] ^ d[13] ^ d[10] ^ d[9] ^ d[8] ^ d[6] ^ d[3] ^ d[2] ^ d[1] ^
            c[0] ^ c[2];
        nextCRC3_D37 = newcrc;
    end
endfunction

function bit parity_gen;
    input [6:0] d;
    return (d[6] ^ d[5] ^ d[4] ^ d[3] ^ d[2] ^ d[1] ^ d[0]);
endfunction

task reset_alu;
    rst_n = 1'b0;
    repeat(10) @(negedge clk);
    rst_n = 1'b1;
endtask

//------------------------------------------------------------------------------
// Random functions
//------------------------------------------------------------------------------

function operation_t rand_op;
    bit [2:0] op_choice;
    op_choice = 3'($random);
    case (op_choice)
        3'b000 : return AND_OP;
        3'b001 : return OR_OP;
        3'b010 : return ADD_OP;
        3'b011 : return SUB_OP;
        default :
            if(op_choice[1])
                return NO_OP;
            else
                return RST_OP;     
    endcase
endfunction : rand_op

//---------------------------------
function bit[31:0] rand_data;
    bit [1:0] zero_ones;
    zero_ones = 2'($random);
    if (zero_ones == 2'b00)
        return 32'h00000000;
    else if (zero_ones == 2'b11)
        return 32'hFFFFFFFF;
    else
        return 32'($random);
endfunction : rand_data

//------------------------------------------------------------------------------
// Send data tasks/functions
//------------------------------------------------------------------------------

task send_packet;
    input bit[31:0] A;
    input bit[31:0] B;
    input operation_t OP;
    input bit[3:0] crc4b;
    input bit sim_data_error;
    
    integer i;
    integer j;
    // byte endian swap
    automatic byte A_endian [0:3] = {>>byte{A}};
    automatic byte B_endian [0:3] = {>>byte{B}};
    
    j = (sim_data_error ? ($urandom_range(3, 0)) : 4);
    for(i = 0; i < j; i++)
        send_byte(B_endian[i], DATA_PACKET);
    for(i = 0; i < j; i++)
        send_byte(A_endian[i], DATA_PACKET);
    // Send CTL( {1'b0, OP, CRC} )
    send_byte({1'b0, OP, crc4b}, CMD_PACKET);
endtask

task send_byte;
    input bit[0:7] data; //endian swap to send MSB first
    input packet_type_t packet_type;
    
    // Start
    @(negedge clk) sin = 1'b0;
    @(negedge clk) sin = packet_type;
    foreach(data[i])
        @(negedge clk) sin = data[i];
    // End, back to idle
    @(negedge clk) sin = 1'b1;
endtask

//------------------------------------------------------------------------------
// Receive data tasks/functions
//------------------------------------------------------------------------------

task get_packet;
    output bit[31:0] C;
    output bit[7:0] ctl_byte;
    output transmission_result_t transmission_result;
    operation_t operation;
    packet_type_t packet_type;
    integer i;

    // Get first byte
    get_byte(packet_type, ctl_byte);
    
    if (packet_type == DATA_PACKET) begin
        C[31:24] = ctl_byte;
        get_byte(packet_type, C[23:16]);
        get_byte(packet_type, C[15:8]);
        get_byte(packet_type, C[7:0]);
        get_byte(packet_type, ctl_byte);
        transmission_result = TRANSMISSION_CORRECT;
    end
    else begin
        transmission_result = TRANSMISSION_ERROR;        
    end
endtask

task get_byte;
    output packet_type_t packet_type;
    output bit[0:7] data;
    
    // Wait for sout = 0
    @(negedge sout);
    
    // Start
    @(negedge clk);
    if (sout != 1'b0) begin
        $display("%0t Error: Start bit = 1'b1", $time);
        test_result = "FAILED";
    end
    @(negedge clk);
    if (sout == 0)
        packet_type = DATA_PACKET;
    else
        packet_type = CMD_PACKET;
    
    foreach(data[i]) @(negedge clk) data[i] = sout;
    // Idle bit
    @(negedge clk);
    if (sout != 1'b1) begin
        $display("%0t Error: Idle bit = 1'b0", $time);
        test_result = "FAILED";
    end
endtask

task handle_ctl_byte;
    input bit[7:0] ctl_byte;
    input transmission_result_t transmission_result;
    output bit[3:0] alu_flags;
    output bit[2:0] crc;
    output bit[5:0] err_flags;
    output bit pariry;
    
    if (transmission_result == TRANSMISSION_CORRECT) begin
        if (ctl_byte[7] != 1'b0)
            $display("FAILED: Transmission correct, but error CTL byte received");
        alu_flags = ctl_byte[6:3];
        crc = ctl_byte[2:0];
    end
    else if (transmission_result == TRANSMISSION_ERROR) begin
        if (ctl_byte[7] != 1'b1)
            $display("FAILED: Transmission error, but ALU flags CTL byte received");
        err_flags = ctl_byte[6:1];
        pariry = ctl_byte[0];
    end
endtask

//------------------------------------------------------------------------------
// Tester
//------------------------------------------------------------------------------

function bit[31:0] get_expected_result;
    input bit [31:0] B;
    input bit [31:0] A;
    input operation_t op_set;

    bit [31:0] ret;
    case(op_set)
        AND_OP : ret = A & B;
        OR_OP  : ret = A | B;
        ADD_OP : ret = A + B;
        SUB_OP : ret = B - A;
        default: begin
            $display("%0t INTERNAL ERROR. get_expected: unexpected case argument: %s", $time, op_set);
            return -1;
        end
    endcase
    return(ret);
endfunction

function bit[3:0] get_expected_flags;
    input bit[31:0] B;
    input bit[31:0] A;
    input operation_t op_set;

    automatic bit [31:0] result;
    automatic bit [32:0] result2;
    automatic bit [3:0] flags;

    case(op_set)
        AND_OP : result = A & B;
        OR_OP  : result = A | B;
        ADD_OP : begin
            result  = A + B;
            result2 = A + B;
            if ((result[31] == 1'b1 && A[31] == 1'b0 && B[31] == 1'b0) ||
                (result[31] == 1'b0 && A[31] == 1'b1 && B[31] == 1'b1))
                flags = flags | `FLAG_OF;
        end
        SUB_OP : begin
            result  = B - A;
            result2 = B - A;
            if ((result[31] == 1'b1 && A[31] == 1'b1 && B[31] == 1'b0) ||
                (result[31] == 1'b0 && A[31] == 1'b0 && B[31] == 1'b1))
                flags = flags | `FLAG_OF;
        end
        default: begin
            $display("%0t INTERNAL ERROR. get_expected: unexpected case argument: %s", $time, op_set);
            return -1;
        end
    endcase
    
    if (result[31:0] == 0)
        flags = flags | `FLAG_ZERO;
    if (result[31] == 1'b1)
        flags = flags | `FLAG_NEG;
    if (result2[32] == 1'b1)
        flags = flags | `FLAG_C;
    return(flags);
endfunction

task check_results;
    automatic bit failed = 0;
    C_expected = 0;
    alu_flags_expected = 0;
    crc3b_expected = 0;
    parity_expected = 0;
    
    if (transmission_result == TRANSMISSION_CORRECT) begin
        C_expected = get_expected_result(B, A, op_set);
        alu_flags_expected = get_expected_flags(B, A, op_set);
        crc3b_expected = nextCRC3_D37({C, 1'b0, alu_flags_expected}, 3'b000);
        if (C != C_expected) begin
            $display("FAILED: C != C_expected");
            failed = 1'b1;
        end        
        if (alu_flags != alu_flags_expected) begin
            $display("FAILED: alu_flags != alu_flags_expected");
            failed = 1'b1;
        end
        if (crc3b != crc3b_expected) begin
            $display("FAILED: crc3b != crc3b_expected");
            failed = 1'b1;
        end
    end
    else if (transmission_result == TRANSMISSION_ERROR) begin
        parity_expected = parity_gen({1'b1, err_flags_expected});
        if (parity != parity_expected) begin
            $display("FAILED: parity != parity_expected");
            failed = 1'b1;
        end
        if (err_flags != err_flags_expected) begin
            $display("FAILED: err_flags != err_flags_expected");
            failed = 1'b1;
        end
        if (err_flags[2:0] != err_flags[5:3]) begin
            $display("FAILED: err_flags duplication mismatch");
            failed = 1'b1;
        end
    end
    
    if (failed) begin
        test_result = "FAILED";
        $display("%0t", $time);
        $display("Operation = %b", op_set);
        $display("A = %h\tB = %h", A, B);
        $display("Expected C = %h", C_expected);
        $display("         C = %h", C);
        $display("Expected flags = %b\tFlags = %b", alu_flags_expected, alu_flags);
        $display("Expected errors = %b\tErrors = %b", err_flags_expected, err_flags);
        $display("---------------------------------------------------------\n");
    end
    `ifdef DEBUG
    else begin
        $display("%0t", $time);
        if (transmission_result == TRANSMISSION_CORRECT)
            $display("Test passed for A=%h B=%h op_set=%b", A, B, op_set);
        else if (transmission_result == NO_TRANSMISSION)
            $display("Test passed for %s", (op_set == NO_OP) ? "NO_OP" : "RST_OP");
        else if (transmission_result == TRANSMISSION_ERROR)
            $display("Test passed for %b error", err_flags_expected[2:0]);
        $display("---------------------------------------------------------\n");
    end
    `endif
endtask

function bit[5:0] add_error;
    automatic bit[2:0] error_type = 3'b0;
    automatic integer i;
    sim_data_error = 1'b0;
    if (3'($random()) == 4'b000) begin
        error_type[$random() % 3] = 1'b1;
        case (error_type)
            `ERR_DATA: begin
                sim_data_error = 1'b1;
            end
            `ERR_CRC: begin
                i = $urandom();
                crc4b[i % 3] = ~crc4b[i % 3];
            end
            `ERR_OP: begin
                op_set[1] = 1'b1;
            end
        endcase
    end
    return {2{error_type}};
endfunction

initial begin
    sin = 1;
    reset_alu();
    repeat(100000) begin
        @(negedge clk);
        op_set = rand_op();
        transmission_result = NO_TRANSMISSION;
        case (op_set)
            NO_OP   : begin
                repeat(($random() % 64) + 1) @(negedge clk);
            end
            RST_OP  : begin
                reset_alu();
            end
            default : begin
                A = rand_data();
                B = rand_data();
                crc4b = nextCRC4_D68({B, A, 1'b1, op_set}, 4'b0000);
                
                err_flags_expected = add_error();
                if (err_flags_expected == {2{`ERR_OP}})
                    crc4b = nextCRC4_D68({B, A, 1'b1, op_set}, 4'b0000);
                
                send_packet(A, B, op_set, crc4b, sim_data_error);
                
                get_packet(C, ctl_byte, transmission_result);
                handle_ctl_byte(ctl_byte, transmission_result, alu_flags, crc3b, err_flags, parity);
            end
        endcase
        check_results();
    end
    $display("Tests %s", test_result);
    $finish();
end
    
endmodule
