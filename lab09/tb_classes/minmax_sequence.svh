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
class minmax_sequence extends uvm_sequence #(sequence_item);
    `uvm_object_utils(minmax_sequence)

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name = "minmax_sequence");
        super.new(name);
    endfunction : new
    
//------------------------------------------------------------------------------
// the sequence body
//------------------------------------------------------------------------------

    task body();
        `uvm_info("SEQ_MINMAX", "", UVM_MEDIUM)
        repeat (200) begin : minmax_loop
            `uvm_do_with(req, {
                transmission_input.A dist {32'h00000000 := 1, 32'hFFFFFFFF := 1};
                transmission_input.B dist {32'h00000000 := 1, 32'hFFFFFFFF := 1};
            })
            `uvm_info("SEQ_MINMAX", $sformatf("minmax req: %s", req.convert2string), UVM_HIGH)
        end : minmax_loop
    endtask : body

endclass : minmax_sequence
