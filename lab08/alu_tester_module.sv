`timescale 1ns/1ps

module alu_tester_module(alu_bfm bfm);
import alu_pkg::*;

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

function error_t rand_error;
    automatic bit[2:0] error_type = 3'b0;

    if (3'($random()) == 3'b000) begin
        error_type[$random() % 3] = 1'b1;
    end
    return error_t'(error_type);
endfunction

initial begin
    transmission_input_t tran_input;
    transmission_output_t tran_output;
    
    bfm.reset_alu();
    repeat(1000) begin
        tran_input.A = rand_data();
        tran_input.B = rand_data();
        tran_input.op = rand_op();
        tran_input.error = rand_error();
        tran_input.alu_flags = '0;
        
        bfm.make_transaction(tran_input, tran_output);
    end
end

endmodule
