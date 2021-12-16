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
class random_command extends uvm_transaction;
    `uvm_object_utils(random_command)

    rand transmission_input_t transmission_input;

    constraint op_err_aluf {
        transmission_input.op dist {AND_OP := 1, OR_OP := 1, ADD_OP := 1, SUB_OP := 1, NO_OP := 2, RST_OP := 2};
        if(transmission_input.op != RST_OP && transmission_input.op != NO_OP){
            transmission_input.error dist {ERR_DATA := 1, ERR_OP := 1, ERR_CRC := 1, ERR_NONE := 5};
        } else {
            transmission_input.error == ERR_NONE;
        }
        transmission_input.alu_flags == '0;
    }
    
    function new (string name = "");
        super.new(name);
    endfunction : new

    function void do_copy(uvm_object rhs);
        random_command copied_transaction_h;

        if(rhs == null)
            `uvm_fatal("COMMAND TRANSACTION", "Tried to copy from a null pointer")

        super.do_copy(rhs); // copy all parent class data

        if(!$cast(copied_transaction_h,rhs))
            `uvm_fatal("COMMAND TRANSACTION", "Tried to copy wrong type.")

        transmission_input  = copied_transaction_h.transmission_input;

    endfunction : do_copy

    function random_command clone_me();
        
        random_command clone;
        uvm_object tmp;

        tmp = this.clone();
        $cast(clone, tmp);
        return clone;
        
    endfunction : clone_me

    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        random_command compared_transaction_h;
        bit same;
        if (rhs==null) `uvm_fatal("RANDOM TRANSACTION",
                "Tried to do comparison to a null pointer");
        if (!$cast(compared_transaction_h,rhs))
            same = 0;
        else
            same = super.do_compare(rhs, comparer) &&
            (compared_transaction_h.transmission_input == transmission_input);
        
        return same;
        
    endfunction : do_compare

    function string convert2string();
        string s;
        s = $sformatf("A: %h\tB: %h\top: %s\terr: %b",
            transmission_input.A, transmission_input.B, transmission_input.op.name(), transmission_input.error);
        return s;
    endfunction : convert2string

endclass : random_command
