`timescale 1ns/1ps

module coverage(alu_bfm bfm);
import alu_pkg::*;

bit [31:0] A, B;
operation_t op_set;
bit [3:0] alu_flags_expected;
bit [2:0] err_flags_expected;


covergroup alu_ops;
    op_covp: coverpoint op_set {
        bins A1_all_ops[]     = {AND_OP,OR_OP,ADD_OP,SUB_OP};
        bins A2_rst_op[]      = (RST_OP => AND_OP,OR_OP,ADD_OP,SUB_OP);
        bins A3_op_rst[]      = (AND_OP,OR_OP,ADD_OP,SUB_OP => RST_OP);
        bins A4_two_ops[]     = ([AND_OP:OR_OP] [* 2]);
    }
    
    alu_neg_flag:  coverpoint alu_flags_expected[0];
    alu_zero_flag: coverpoint alu_flags_expected[1];
    alu_of_flag:   coverpoint alu_flags_expected[2];
    alu_c_flag:    coverpoint alu_flags_expected[3];
    
 
    
    alu_flags_and_ops: cross op_covp, alu_neg_flag, alu_zero_flag, alu_of_flag, alu_c_flag {
        bins A5_AND_NEG_z  = binsof(op_covp.A1_all_ops) intersect {AND_OP} && binsof(alu_neg_flag) intersect {1'b0};
        bins A5_AND_ZERO_z = binsof(op_covp.A1_all_ops) intersect {AND_OP} && binsof(alu_zero_flag) intersect {1'b0};
        bins A5_AND_OF_z   = binsof(op_covp.A1_all_ops) intersect {AND_OP} && binsof(alu_of_flag) intersect {1'b0};
        bins A5_AND_C_z    = binsof(op_covp.A1_all_ops) intersect {AND_OP} && binsof(alu_c_flag) intersect {1'b0};
        bins A5_OR_NEG_z   = binsof(op_covp.A1_all_ops) intersect {OR_OP}  && binsof(alu_neg_flag) intersect {1'b0};
        bins A5_OR_ZERO_z  = binsof(op_covp.A1_all_ops) intersect {OR_OP}  && binsof(alu_zero_flag) intersect {1'b0};
        bins A5_OR_OF_z    = binsof(op_covp.A1_all_ops) intersect {OR_OP}  && binsof(alu_of_flag) intersect {1'b0};
        bins A5_OR_C_z     = binsof(op_covp.A1_all_ops) intersect {OR_OP}  && binsof(alu_c_flag) intersect {1'b0};
        bins A5_ADD_NEG_z  = binsof(op_covp.A1_all_ops) intersect {ADD_OP} && binsof(alu_neg_flag) intersect {1'b0};
        bins A5_ADD_ZERO_z = binsof(op_covp.A1_all_ops) intersect {ADD_OP} && binsof(alu_zero_flag) intersect {1'b0};
        bins A5_ADD_OF_z   = binsof(op_covp.A1_all_ops) intersect {ADD_OP} && binsof(alu_of_flag) intersect {1'b0};
        bins A5_ADD_C_z    = binsof(op_covp.A1_all_ops) intersect {ADD_OP} && binsof(alu_c_flag) intersect {1'b0};
        bins A5_SUB_NEG_z  = binsof(op_covp.A1_all_ops) intersect {SUB_OP} && binsof(alu_neg_flag) intersect {1'b0};
        bins A5_SUB_ZERO_z = binsof(op_covp.A1_all_ops) intersect {SUB_OP} && binsof(alu_zero_flag) intersect {1'b0};
        bins A5_SUB_OF_z   = binsof(op_covp.A1_all_ops) intersect {SUB_OP} && binsof(alu_of_flag) intersect {1'b0};
        bins A5_SUB_C_z    = binsof(op_covp.A1_all_ops) intersect {SUB_OP} && binsof(alu_c_flag) intersect {1'b0};
        
        bins A5_AND_NEG_o  = binsof(op_covp.A1_all_ops) intersect {AND_OP} && binsof(alu_neg_flag) intersect {1'b1};
        bins A5_AND_ZERO_o = binsof(op_covp.A1_all_ops) intersect {AND_OP} && binsof(alu_zero_flag) intersect {1'b1};
        bins A5_OR_NEG_o   = binsof(op_covp.A1_all_ops) intersect {OR_OP}  && binsof(alu_neg_flag) intersect {1'b1};
        bins A5_OR_ZERO_o  = binsof(op_covp.A1_all_ops) intersect {OR_OP}  && binsof(alu_zero_flag) intersect {1'b1};
        bins A5_ADD_NEG_o  = binsof(op_covp.A1_all_ops) intersect {ADD_OP} && binsof(alu_neg_flag) intersect {1'b1};
        bins A5_ADD_ZERO_o = binsof(op_covp.A1_all_ops) intersect {ADD_OP} && binsof(alu_zero_flag) intersect {1'b1};
        bins A5_ADD_OF_o   = binsof(op_covp.A1_all_ops) intersect {ADD_OP} && binsof(alu_of_flag) intersect {1'b1};
        bins A5_ADD_C_o    = binsof(op_covp.A1_all_ops) intersect {ADD_OP} && binsof(alu_c_flag) intersect {1'b1};
        bins A5_SUB_NEG_o  = binsof(op_covp.A1_all_ops) intersect {SUB_OP} && binsof(alu_neg_flag) intersect {1'b1};
        bins A5_SUB_ZERO_o = binsof(op_covp.A1_all_ops) intersect {SUB_OP} && binsof(alu_zero_flag) intersect {1'b1};
        bins A5_SUB_OF_o   = binsof(op_covp.A1_all_ops) intersect {SUB_OP} && binsof(alu_of_flag) intersect {1'b1};
        bins A5_SUB_C_o    = binsof(op_covp.A1_all_ops) intersect {SUB_OP} && binsof(alu_c_flag) intersect {1'b1};
        
        ignore_bins ig = !binsof(op_covp.A1_all_ops);
    }
endgroup

covergroup zeros_or_ones_on_ops;

    all_ops : coverpoint op_set {
        ignore_bins null_ops = {RST_OP, NO_OP};
    }

    a_leg: coverpoint A {
        bins zeros = {'h00000000};
        bins others= {['h00000001:'hFFFFFFFE]};
        bins ones  = {'hFFFFFFFF};
    }

    b_leg: coverpoint B {
        bins zeros = {'h00000000};
        bins others= {['h00000001:'hFFFFFFFE]};
        bins ones  = {'hFFFFFFFF};
    }

    B_op_00_FF: cross a_leg, b_leg, all_ops {
        bins B1_and_0s = binsof(all_ops) intersect {AND_OP} && (binsof(a_leg.zeros) || binsof(b_leg.zeros));
        bins B1_or_0s  = binsof(all_ops) intersect {OR_OP}  && (binsof(a_leg.zeros) || binsof(b_leg.zeros));
        bins B1_add_0s = binsof(all_ops) intersect {ADD_OP} && (binsof(a_leg.zeros) || binsof(b_leg.zeros));
        bins B1_sub_0s = binsof(all_ops) intersect {SUB_OP} && (binsof(a_leg.zeros) || binsof(b_leg.zeros));
        bins B2_and_Fs = binsof(all_ops) intersect {AND_OP} && (binsof(a_leg.ones)  || binsof(b_leg.ones));
        bins B2_or_Fs  = binsof(all_ops) intersect {OR_OP}  && (binsof(a_leg.ones)  || binsof(b_leg.ones));
        bins B2_add_Fs = binsof(all_ops) intersect {ADD_OP} && (binsof(a_leg.ones)  || binsof(b_leg.ones));
        bins B2_sub_Fs = binsof(all_ops) intersect {SUB_OP} && (binsof(a_leg.ones)  || binsof(b_leg.ones));

        ignore_bins others_only = binsof(a_leg.others) && binsof(b_leg.others);
    }

endgroup

covergroup error_flags;
    err_covp: coverpoint err_flags_expected {
        bins C1_all_errs[] = {{`ERR_DATA}, {`ERR_CRC}, {`ERR_OP}};
    }
endgroup

alu_ops alu_op_cg;
zeros_or_ones_on_ops zeros_or_ones_on_ops_cg;
error_flags error_flags_cg;
initial begin : coverage
    alu_op_cg = new();
    zeros_or_ones_on_ops_cg = new();
    error_flags_cg = new();
    forever begin : sample_cov
        @(posedge bfm.clk)
        A = bfm.A;
        B = bfm.B;
        op_set = bfm.op_set;
        err_flags_expected = bfm.err_flags_expected;
        alu_flags_expected = bfm.alu_flags_expected;

        alu_op_cg.sample();
        zeros_or_ones_on_ops_cg.sample();
        error_flags_cg.sample();
        if($get_coverage() == 100) break;
    end
    $finish;
end : coverage

endmodule
