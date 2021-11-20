`ifndef TRIANGLE_SVH
`define TRIANGLE_SVH

`include "shape.svh"

class triangle extends shape;
    
    function new(real w, real h);
        super.new(w, h);
    endfunction

    function real get_area();
        return (width * height)/2;
    endfunction
        
    function void print();
        $display("Triangle w=%g h=%g area=%g", width, height, get_area());
    endfunction

endclass : triangle

`endif
