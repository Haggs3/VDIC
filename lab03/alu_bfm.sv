`timescale 1ns/1ps

interface alu_bfm;
import alu_pkg::*;

bit clk, rst_n, sin;
logic sout;
bit transmission_finished;
bit [31:0] A, B;
operation_t op_set;
bit [2:0] err_flags_expected;
bit [3:0] alu_flags_expected;
transmission_data_t transmission_data;

initial begin : clk_gen
    sin = 1;
    clk = 0;
    forever begin : clk_frv
        #10;
        clk = ~clk;
    end
end

task reset_alu;
    rst_n = 1'b0;
    repeat(10) @(negedge clk);
    rst_n = 1'b1;
    @(negedge clk);
endtask

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

function bit[3:0] get_expected_flags;
    input bit[31:0] B;
    input bit[31:0] A;
    input operation_t op_set;

    automatic bit [31:0] result;
    automatic bit [32:0] result2;
    automatic bit [3:0] flags = 0;

    case(op_set)
        AND_OP : result = A & B;
        OR_OP  : result = A | B;
        ADD_OP : begin
            result  = A + B;
            result2 = A + B;
            if ((result[31] == 1'b1 && A[31] == 1'b0 && B[31] == 1'b0) ||
                (result[31] == 1'b0 && A[31] == 1'b1 && B[31] == 1'b1))
                flags = flags | `FLAG_OF;
            if (result2[32] == 1'b1)
                flags = flags | `FLAG_C;
        end
        SUB_OP : begin
            result  = B - A;
            result2 = B - A;
            if ((result[31] == 1'b1 && A[31] == 1'b1 && B[31] == 1'b0) ||
                (result[31] == 1'b0 && A[31] == 1'b0 && B[31] == 1'b1))
                flags = flags | `FLAG_OF;
            if (result2[32] == 1'b1)
                flags = flags | `FLAG_C;
        end
    endcase

    if (result[31:0] == 0)
        flags = flags | `FLAG_ZERO;
    if (result[31] == 1'b1)
        flags = flags | `FLAG_NEG;
    return(flags);
endfunction

task get_packet;
    output transmission_data_t tran_data;
    
    packet_type_t packet_type;
    automatic transmission_result_t tran_result = NO_TRANSMISSION;
    automatic bit[31:0] C_temp = 0;
    bit[7:0] ctl_byte;

    // Get first byte
    get_byte(packet_type, ctl_byte);
    
    if (packet_type == DATA_PACKET) begin
        C_temp[31:24] = ctl_byte;
        get_byte(packet_type, C_temp[23:16]);
        get_byte(packet_type, C_temp[15:8]);
        get_byte(packet_type, C_temp[7:0]);
        get_byte(packet_type, ctl_byte);
        tran_result = TRANSMISSION_CORRECT;
    end
    else begin
        tran_result = TRANSMISSION_ERROR;        
    end
    
    tran_data = handle_ctl_byte(ctl_byte, tran_result);
    tran_data.C = C_temp;
endtask

task get_byte;
    output packet_type_t packet_type;
    output bit[0:7] data;
    
    // Wait for sout = 0
    @(negedge sout);
    
    // Start
    @(negedge clk);
    
    @(negedge clk);
    if (sout == 0)
        packet_type = DATA_PACKET;
    else
        packet_type = CMD_PACKET;
    
    foreach(data[i]) @(negedge clk) data[i] = sout;
    // Idle bit
    @(negedge clk);

endtask

function transmission_data_t handle_ctl_byte;
    input bit[7:0] ctl_byte;
    input transmission_result_t tran_result;
    
    transmission_data_t tran_data;
    
    tran_data.alu_flags = 0;
    tran_data.crc3b = 0;
    tran_data.err_flags = 0;
    tran_data.parity = 0;
    tran_data.result = tran_result;
    
    if (tran_result == TRANSMISSION_CORRECT) begin
        tran_data.alu_flags = ctl_byte[6:3];
        tran_data.crc3b = ctl_byte[2:0];
    end
    else if (tran_result == TRANSMISSION_ERROR) begin
        tran_data.err_flags = ctl_byte[6:1];
        tran_data.parity = ctl_byte[0];
    end
    
    return tran_data;
    
endfunction

task send_packet;
    input bit[31:0] A;
    input bit[31:0] B;
    input operation_t OP;
    input bit [2:0] error_sim;
    
    integer i;
    integer j;
    // byte endian swap
    automatic byte A_endian [0:3] = {>>byte{A}};
    automatic byte B_endian [0:3] = {>>byte{B}};
    automatic bit sim_data_error = 1'b0;
    bit [3:0] crc4b;
    
    crc4b = nextCRC4_D68({B, A, 1'b1, OP}, 4'b0000);
    case (error_sim)
        `ERR_DATA: begin
            sim_data_error = 1'b1;
        end
        `ERR_CRC: begin
            i = $urandom();
            crc4b[i % 3] = ~crc4b[i % 3];
        end
        `ERR_OP: begin
            OP[1] = 1'b1;
            crc4b = nextCRC4_D68({B, A, 1'b1, OP}, 4'b0000);
        end
    endcase
    
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

task start_transmission;
    input bit [31:0] A_in;
    input bit [31:0] B_in;
    input operation_t op_set_in;
    input bit [2:0] error_sim;
    output transmission_data_t tran_data;
    
    A = A_in;
    B = B_in;
    op_set = op_set_in;
    err_flags_expected = error_sim;
    
    case (op_set_in)
        NO_OP   : begin
            repeat(($random() % 64) + 1) @(negedge clk);
            tran_data.result = NO_TRANSMISSION;
        end
        RST_OP  : begin
            reset_alu();
            tran_data.result = NO_TRANSMISSION;
        end
        default : begin
            alu_flags_expected = get_expected_flags(B_in, A_in, op_set_in);
            send_packet(A_in, B_in, op_set_in, error_sim);
            get_packet(tran_data);
        end
    endcase
    transmission_data = tran_data;
    transmission_finished = 1;
    @(negedge clk);
endtask

endinterface : alu_bfm
