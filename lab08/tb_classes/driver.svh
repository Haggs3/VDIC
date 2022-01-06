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
class driver extends uvm_component;
    `uvm_component_utils(driver)

    protected virtual alu_bfm bfm;
    uvm_get_port #(random_command) command_port;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
    function void build_phase(uvm_phase phase);
        alu_agent_config alu_agent_config_h;
        if(!uvm_config_db #(alu_agent_config)::get(this, "", "config", alu_agent_config_h))
            `uvm_fatal("DRIVER", "Failed to get config");
        bfm = alu_agent_config_h.bfm;
        command_port = new("command_port", this);
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        transmission_output_t tran_output;
        random_command command;

        forever begin : command_loop
            command_port.get(command);
            bfm.make_transaction(command.transmission_input, tran_output);
        end : command_loop
    endtask : run_phase

endclass : driver
