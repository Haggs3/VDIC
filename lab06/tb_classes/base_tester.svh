/*
 Copyright 2013 Ray Salemi

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

virtual class base_tester extends uvm_component;

    `uvm_component_utils(base_tester)
    uvm_put_port #(transmission_input_t) command_port;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        command_port = new("command_port", this);
    endfunction : build_phase

    pure virtual function operation_t get_op();

    pure virtual function bit[31:0] get_data();
    
    pure virtual function error_t get_error();

    task run_phase(uvm_phase phase);
        transmission_input_t tran_input;
        
        phase.raise_objection(this);
        tran_input.op = RST_OP;
        command_port.put(tran_input);
        repeat(1000) begin
            tran_input.A = get_data();
            tran_input.B = get_data();
            tran_input.op = get_op();
            tran_input.error = get_error();
            command_port.put(tran_input);
        end
        #10000;
        phase.drop_objection(this);
    endtask : run_phase

endclass : base_tester
