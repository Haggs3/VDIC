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
class sequence_item extends uvm_sequence_item;

//  This macro is moved below the variables definition and expanded.
//    `uvm_object_utils(sequence_item)

//------------------------------------------------------------------------------
// sequence item variables
//------------------------------------------------------------------------------

    rand transmission_input_t transmission_input;
    transmission_output_t result;

//------------------------------------------------------------------------------
// Macros providing copy, compare, pack, record, print functions.
// Individual functions can be enabled/disabled with the last
// `uvm_field_*() macro argument.
// Note: this is an expanded version of the `uvm_object_utils with additional
//       fields added. DVT has a dedicated editor for this (ctrl-space).
//------------------------------------------------------------------------------

    `uvm_object_utils_begin(sequence_item)
        `uvm_field_int(transmission_input, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(result.C, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(result.alu_flags, UVM_ALL_ON | UVM_DEC)
    `uvm_object_utils_end

//------------------------------------------------------------------------------
// constraints
//------------------------------------------------------------------------------

    constraint op_err {
        transmission_input.op dist {AND_OP := 1, OR_OP := 1, ADD_OP := 1, SUB_OP := 1, NO_OP := 2, RST_OP := 2};
        if(transmission_input.op != RST_OP && transmission_input.op != NO_OP){
            transmission_input.error dist {ERR_DATA := 1, ERR_OP := 1, ERR_CRC := 1, ERR_NONE := 5};
        } else {
            transmission_input.error == ERR_NONE;
        }
        transmission_input.alu_flags == '0;
    }

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name = "sequence_item");
        super.new(name);
    endfunction : new

//------------------------------------------------------------------------------
// convert2string 
//------------------------------------------------------------------------------

    function string convert2string();
        return {super.convert2string(),
            $sformatf("A: %h\tB: %h\top: %s\terr: %b\nC: %h\talu_flags: %b",
            transmission_input.A, transmission_input.B, transmission_input.op.name(), transmission_input.error,
            result.C, result.alu_flags)
        };
    endfunction : convert2string

endclass : sequence_item
