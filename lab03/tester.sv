`timescale 1ns/1ps

module tester(alu_bfm bfm);
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

function bit[2:0] rand_error;
    automatic bit[2:0] error_type = 3'b0;

    if (3'($random()) == 3'b000) begin
        error_type[$random() % 3] = 1'b1;
    end
    return error_type;
endfunction

initial begin
    bit [31:0] A_test, B_test;
    bit [2:0] error_sim;
    operation_t op_set;
    transmission_data_t transmission_data;
    
    bfm.reset_alu();
    repeat(10000) begin
        A_test = rand_data();
        B_test = rand_data();
        op_set = rand_op();
        error_sim = rand_error();
        
        bfm.start_transmission(A_test, B_test, op_set, error_sim, transmission_data);
    end
    $finish();
end

endmodule
