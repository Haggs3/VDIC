`ifndef SQUARE_SVH
`define SQUARE_SVH

`include "rectangle.svh"

class square extends rectangle;
    
    function new(real w);
        super.new(w, w);
    endfunction
        
    function void print();
        $display("Square w=%g area=%g", width, get_area());
    endfunction

endclass : square

`endif
