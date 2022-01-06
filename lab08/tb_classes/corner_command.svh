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
class corner_transaction extends random_command;
    `uvm_object_utils(corner_transaction)

    constraint data {
        transmission_input.op dist {AND_OP := 1, OR_OP := 1, ADD_OP := 1, SUB_OP := 1, NO_OP := 2, RST_OP := 2};
        if(transmission_input.op != RST_OP && transmission_input.op != NO_OP){
            transmission_input.error dist {ERR_DATA := 1, ERR_OP := 1, ERR_CRC := 1, ERR_NONE := 5};
            transmission_input.A dist {32'h00000000 := 1, 32'hFFFFFFFF := 1};
            transmission_input.B dist {32'h00000000 := 1, 32'hFFFFFFFF := 1};
        } else {
            transmission_input.error == ERR_NONE;
            transmission_input.A == '0;
            transmission_input.B == '0;
        }
        transmission_input.alu_flags == '0;
    }

    function new(string name="");
        super.new(name);
    endfunction
    
endclass : corner_transaction
