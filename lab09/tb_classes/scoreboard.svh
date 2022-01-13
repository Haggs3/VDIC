class scoreboard extends uvm_subscriber #(result_transaction);

    `uvm_component_utils(scoreboard)
    
//------------------------------------------------------------------------------
// local typedefs
//------------------------------------------------------------------------------
    
    typedef enum bit {
        TEST_PASSED,
        TEST_FAILED
    } test_result;
    
//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    
    protected virtual alu_bfm bfm;
    uvm_tlm_analysis_fifo #(sequence_item) cmd_f;
    protected test_result tr = TEST_PASSED;
    
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    
    function void build_phase(uvm_phase phase);
        cmd_f = new ("cmd_f", this);
    endfunction : build_phase
    
//------------------------------------------------------------------------------
// print the PASSED/FAILED in color
//------------------------------------------------------------------------------
    
    protected function void print_test_result();
        if(tr == TEST_PASSED) begin
            set_print_color(COLOR_BOLD_BLACK_ON_GREEN);
            $write("-----------------------------\n");
            $write("---------Test PASSED---------\n");
            $write("-----------------------------");
            set_print_color(COLOR_DEFAULT);
            $write("\n");
        end
        else begin
            set_print_color(COLOR_BOLD_BLACK_ON_RED);
            $write("-----------------------------\n");
            $write("---------Test FAILED---------\n");
            $write("-----------------------------");
            set_print_color(COLOR_DEFAULT);
            $write("\n");
        end
    endfunction 
    
//------------------------------------------------------------------------------
// functions to handle the output
//------------------------------------------------------------------------------
    
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
    
    protected function result_transaction predict_result(sequence_item cmd, transmission_result_t tran_result);
        result_transaction predicted;
        automatic bit[5:0] err_flags_expected;
        
        predicted = new("predicted");
        predicted.transmission_output.result = tran_result;
        if(tran_result == TRANSMISSION_CORRECT) begin
            predicted.transmission_output.C = get_expected_result(cmd.transmission_input);
            predicted.transmission_output.alu_flags = cmd.transmission_input.alu_flags;
            predicted.transmission_output.crc3b = nextCRC3_D37({predicted.transmission_output.C, 1'b0, predicted.transmission_output.alu_flags}, 3'b000);
        end else if(tran_result == TRANSMISSION_ERROR) begin
            err_flags_expected = {2{cmd.transmission_input.error}};
            predicted.transmission_output.parity = parity_gen({1'b1, err_flags_expected});
            predicted.transmission_output.err_flags = err_flags_expected;
        end
        
        return predicted;
        
    endfunction

//------------------------------------------------------------------------------
// subscriber write function
//------------------------------------------------------------------------------

    function void write(result_transaction t);
        string data_str;
        sequence_item cmd;
        result_transaction predicted;
        
        while(!cmd_f.try_get(cmd));
        predicted = predict_result(cmd, t.transmission_output.result);
        data_str = {cmd.convert2string(), "\nActual:    ", t.convert2string(), "\nPredicted: ", predicted.convert2string()};

        if(predicted.compare(t)) begin
            `uvm_info("SELF_CHECKER", {"PASS:\n", data_str}, UVM_HIGH);
        end
        else begin
            tr = TEST_FAILED;
            `uvm_error("SELF_CHECKER", {"FAIL:\n", data_str});
        end
    endfunction

//------------------------------------------------------------------------------
// report phase
//------------------------------------------------------------------------------

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SELF CHECKTER", "Reporting test result below", UVM_LOW)
        print_test_result();
    endfunction : report_phase

endclass : scoreboard
