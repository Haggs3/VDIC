`timescale 1ns/1ps

interface alu_bfm;
import alu_pkg::*;

bit clk, rst_n, sin;
logic sout;
bit transmission_finished;
bit [3:0] alu_flags_expected;
transmission_input_t transmission_input;
transmission_output_t transmission_output;

command_monitor command_monitor_h;
result_monitor result_monitor_h;

initial begin : clk_gen
    sin = 1;
    clk = 0;
    forever begin : clk_frv
        #10;
        clk = ~clk;
    end
end

initial begin : op_monitor
    transmission_input_t tran_input;
    forever begin
        @(posedge transmission_finished);
        tran_input  = transmission_input;
        command_monitor_h.write_to_monitor(tran_input);
    end
end : op_monitor

initial begin : result_monitor_thread
    forever begin
        @(posedge transmission_finished);
        result_monitor_h.write_to_monitor(transmission_output);
    end
end : result_monitor_thread

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
    input transmission_input_t tran_input;
    
    automatic bit[31:0] B;
    automatic bit[31:0] A;
    automatic operation_t op_set;

    automatic bit [31:0] result;
    automatic bit [32:0] result2;
    automatic bit [3:0] flags = 0;
    
    B = tran_input.B;
    A = tran_input.A;
    op_set = tran_input.op;

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
    output transmission_output_t tran_data;
    
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

function transmission_output_t handle_ctl_byte;
    input bit[7:0] ctl_byte;
    input transmission_result_t tran_result;
    
    transmission_output_t tran_data;
    
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
    input transmission_input_t tran_input;
    
    automatic bit[31:0] A = tran_input.A;
    automatic bit[31:0] B = tran_input.B;
    automatic operation_t OP = tran_input.op;
    automatic error_t error_sim = tran_input.error;
    
    // byte endian swap
    automatic byte A_endian [0:3] = {>>byte{A}};
    automatic byte B_endian [0:3] = {>>byte{B}};
    
    automatic bit sim_data_error = 1'b0;
    automatic bit [3:0] crc4b = nextCRC4_D68({B, A, 1'b1, OP}, 4'b0000);
    
    integer i;
    integer j;
    
    case (error_sim)
        ERR_DATA: begin
            sim_data_error = 1'b1;
        end
        ERR_CRC: begin
            i = $urandom();
            crc4b[i % 3] = ~crc4b[i % 3];
        end
        ERR_OP: begin
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

task make_transaction;
    input transmission_input_t tran_input;
    output transmission_output_t tran_output;
    
    automatic transmission_output_t tran_output_tmp;
    transmission_finished = 0;
    
    case (tran_input.op)
        NO_OP   : begin
            repeat(($random() % 64) + 1) @(negedge clk);
            tran_output_tmp.result = NO_TRANSMISSION;
        end
        RST_OP  : begin
            reset_alu();
            tran_output_tmp.result = NO_TRANSMISSION;
        end
        default : begin
            tran_input.alu_flags = get_expected_flags(tran_input);
            send_packet(tran_input);
            get_packet(tran_output_tmp);
        end
    endcase
    tran_output = tran_output_tmp;
    
    transmission_input = tran_input;
    transmission_output = tran_output;
    transmission_finished = 1;
    @(negedge clk);
endtask

endinterface : alu_bfm
