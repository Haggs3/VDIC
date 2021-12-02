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
class random_tester extends base_tester;
    
    `uvm_component_utils (random_tester)

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function operation_t get_op;
        bit [2:0] op_choice;
        op_choice = 3'($random);
        case (op_choice)
            3'b000 : return AND_OP;
            3'b001 : return OR_OP;
            3'b010 : return ADD_OP;
            3'b011 : return SUB_OP;
            default :
                if(op_choice[1])
                    return NO_OP;
                else
                    return RST_OP;     
        endcase
    endfunction : get_op

    function bit[31:0] get_data;
        return 32'($random);
    endfunction : get_data
    
    function bit[2:0] get_error;
        automatic bit[2:0] error_type = 3'b0;
    
        if (3'($random()) == 3'b000) begin
            error_type[$random() % 3] = 1'b1;
        end
        return error_type;
    endfunction

endclass : random_tester






