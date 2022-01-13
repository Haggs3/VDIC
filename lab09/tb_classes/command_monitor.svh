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
class command_monitor extends uvm_component;
    `uvm_component_utils(command_monitor)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    virtual alu_bfm bfm;
    uvm_analysis_port #(sequence_item) ap;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
            `uvm_fatal("COMMAND MONITOR", "Failed to get BFM")
        ap = new("ap",this);
    endfunction : build_phase

//------------------------------------------------------------------------------
// connect phase
//------------------------------------------------------------------------------

    function void connect_phase(uvm_phase phase);
        bfm.command_monitor_h = this;
    endfunction : connect_phase

//------------------------------------------------------------------------------
// interface function for the BFM
//------------------------------------------------------------------------------

    function void write_to_monitor(transmission_input_t tran_input);
        sequence_item cmd;
        `uvm_info("COMMAND MONITOR", $sformatf("\nMONITOR: A: %h\tB: %h\top: %s\terr: %b",
            tran_input.A, tran_input.B, tran_input.op.name(), tran_input.error), UVM_HIGH);
        cmd = new("cmd");
        cmd.transmission_input = tran_input;
        ap.write(cmd);
    endfunction : write_to_monitor

endclass : command_monitor
