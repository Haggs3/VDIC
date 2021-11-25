`ifndef SCOREBOARD_SVH
`define SCOREBOARD_SVH

class scoreboard;

    protected virtual alu_bfm bfm;
    protected string test_result;
    
    function new(virtual alu_bfm b);
        bfm = b;
        test_result = "PASSED";
    endfunction
    
    protected function [2:0] nextCRC3_D37;
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
    
    protected function bit parity_gen;
        input [6:0] d;
        return (d[6] ^ d[5] ^ d[4] ^ d[3] ^ d[2] ^ d[1] ^ d[0]);
    endfunction
    
    protected function bit[31:0] get_expected_result;
        input bit [31:0] B;
        input bit [31:0] A;
        input operation_t op_set;
    
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
        input transmission_data_t tran_data;
        input transmission_data_t tran_data_exp;
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

    task execute();
        transmission_data_t transmission_data_exp;
    
        forever begin:verify_result
            @(posedge bfm.transmission_finished);
            bfm.transmission_finished = 0;
            transmission_data_exp.C = get_expected_result(bfm.B, bfm.A, bfm.op_set);
            transmission_data_exp.alu_flags = bfm.alu_flags_expected;
            transmission_data_exp.crc3b = nextCRC3_D37({transmission_data_exp.C, 1'b0, transmission_data_exp.alu_flags}, 3'b000);
            transmission_data_exp.parity = parity_gen({1'b1, {2{bfm.err_flags_expected}}});
            transmission_data_exp.err_flags = {2{bfm.err_flags_expected}};
    
            if(check_results(bfm.transmission_data, transmission_data_exp) == 1'b0) begin
            `ifdef DEBUG
                $display("%0t", $time);
                if (transmission_result == TRANSMISSION_CORRECT)
                    $display("Test passed for A=%h B=%h op_set=%b", A, B, op_set);
                else if (transmission_result == NO_TRANSMISSION)
                    $display("Test passed for %s", (op_set == NO_OP) ? "NO_OP" : "RST_OP");
                else if (transmission_result == TRANSMISSION_ERROR)
                    $display("Test passed for %b error", bfm.err_flags_expected);
                $display("---------------------------------------------------------\n");
            `endif
            end
            else begin
                $error("FAILED at %0t", $time);
                $error("Operation = %b", bfm.op_set);
                $error("A = %h\tB = %h", bfm.A, bfm.B);
                $error("Expected C = %h", transmission_data_exp.C);
                $error("         C = %h", bfm.transmission_data.C);
                $error("Expected flags = %b\tFlags = %b", transmission_data_exp.alu_flags, bfm.transmission_data.alu_flags);
                $error("Expected errors = %b\tErrors = %b", transmission_data_exp.err_flags, bfm.transmission_data.err_flags);
                $error("---------------------------------------------------------\n");
                test_result = "FAILED";
            end
        end
    endtask

endclass : scoreboard

`endif
