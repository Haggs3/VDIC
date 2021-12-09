`ifndef SCOREBOARD_SVH
`define SCOREBOARD_SVH

class scoreboard extends uvm_subscriber #(transmission_output_t);

    `uvm_component_utils(scoreboard)
    
    virtual alu_bfm bfm;
    uvm_tlm_analysis_fifo #(transmission_input_t) cmd_f;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
            $fatal(1,"Failed to get BFM");
        cmd_f = new ("cmd_f", this);
    endfunction : build_phase
    
    protected function [2:0] nextCRC3_D37;
        input [36:0] Data;
        input [2:0] crc;
        reg [36:0] d;
        reg [2:0] c;
        reg [2:0] newcrc;
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
    endfunction
    
    protected function bit parity_gen;
        input [6:0] d;
        return (d[6] ^ d[5] ^ d[4] ^ d[3] ^ d[2] ^ d[1] ^ d[0]);
    endfunction
    
    protected function bit[31:0] get_expected_result;
        input transmission_input_t tran_input;
        
        automatic bit [31:0] B = tran_input.B;
        automatic bit [31:0] A = tran_input.A;
        automatic operation_t op_set = tran_input.op;
    
        bit [31:0] ret;
        case(op_set)
            AND_OP : ret = A & B;
            OR_OP  : ret = A | B;
            ADD_OP : ret = A + B;
            SUB_OP : ret = B - A;
        endcase
        return(ret);
    endfunction
    
    protected function bit check_results;
        input transmission_output_t tran_data;
        input transmission_output_t tran_data_exp;
        automatic bit failed = 0;
        
        if (tran_data.result == TRANSMISSION_CORRECT) begin
            if (tran_data.C != tran_data_exp.C) begin
                $display("FAILED: C != C_expected");
                failed = 1'b1;
            end        
            if (tran_data.alu_flags != tran_data_exp.alu_flags) begin
                $display("FAILED: alu_flags != alu_flags_expected");
                failed = 1'b1;
            end
            if (tran_data.crc3b != tran_data_exp.crc3b) begin
                $display("FAILED: crc3b != crc3b_expected");
                failed = 1'b1;
            end
        end
        else if (tran_data.result == TRANSMISSION_ERROR) begin
            if (tran_data.parity != tran_data_exp.parity) begin
                $display("FAILED: parity != parity_expected");
                failed = 1'b1;
            end
            if (tran_data.err_flags != tran_data_exp.err_flags) begin
                $display("FAILED: err_flags != err_flags_expected");
                failed = 1'b1;
            end
        end
        return failed;
    endfunction

    function void write(transmission_output_t t);
        transmission_output_t tran_output_exp;
        transmission_input_t tran_input;
        automatic bit[5:0] err_flags_expected;
        
        while(!cmd_f.try_get(tran_input));
        err_flags_expected = {2{tran_input.error}};
        
        tran_output_exp.C = get_expected_result(tran_input);
        tran_output_exp.alu_flags = tran_input.alu_flags;
        tran_output_exp.crc3b = nextCRC3_D37({tran_output_exp.C, 1'b0, tran_output_exp.alu_flags}, 3'b000);
        tran_output_exp.parity = parity_gen({1'b1, err_flags_expected});
        tran_output_exp.err_flags = err_flags_expected;

        if(check_results(t, tran_output_exp) == 1'b0) begin
        `ifdef DEBUG
            $display("%0t", $time);
            if (t.result == TRANSMISSION_CORRECT)
                $display("Test passed for A=%h B=%h op_set=%b", tran_input.A, tran_input.B, tran_input.op);
            else if (t.result == NO_TRANSMISSION)
                $display("Test passed for %s", (tran_input.op == NO_OP) ? "NO_OP" : "RST_OP");
            else if (t.result == TRANSMISSION_ERROR)
                $display("Test passed for %b error", tran_input.error);
            $display("---------------------------------------------------------\n");
        `endif
        end
        else begin
            $display("FAILED at %0t", $time);
            $display("Operation = %b", tran_input.op);
            $display("A = %h\tB = %h", tran_input.A, tran_input.B);
            $display("Expected C = %h", tran_output_exp.C);
            $display("         C = %h", t.C);
            $display("Expected flags = %b\tFlags = %b", tran_output_exp.alu_flags, t.alu_flags);
            $display("Expected errors = %b\tErrors = %b", tran_output_exp.err_flags, t.err_flags);
            $display("---------------------------------------------------------\n");
        end
    endfunction

endclass : scoreboard

`endif
