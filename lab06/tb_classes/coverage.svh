`ifndef COVERAGE_SVH
`define COVERAGE_SVH

class coverage extends uvm_subscriber #(transmission_input_t);
    
    `uvm_component_utils(coverage)

    protected bit [31:0] A, B;
    protected operation_t op_set;
    protected bit [3:0] alu_flags_expected;
    protected error_t err_flags_expected;


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
            bins C1_all_errs[] = {{ERR_DATA}, {ERR_CRC}, {ERR_OP}};
        }
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        alu_ops = new();
        zeros_or_ones_on_ops = new();
        error_flags = new();
    endfunction

    function void write(transmission_input_t t);
        A      = t.A;
        B      = t.B;
        op_set = t.op;
        alu_flags_expected = t.alu_flags;
        err_flags_expected = t.error;
        alu_ops.sample();
        zeros_or_ones_on_ops.sample();
        error_flags.sample();
    endfunction : write

endclass : coverage

`endif
