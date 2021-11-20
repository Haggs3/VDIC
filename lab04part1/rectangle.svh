`ifndef RECTANGLE_SVH
`define RECTANGLE_SVH

`include "shape.svh"

class rectangle extends shape;
    
    function new(real w, real h);
        super.new(w, h);
    endfunction

    function real get_area();
        return width * height;
    endfunction
        
    function void print();
        $display("Rectangle w=%g h=%g area=%g", width, height, get_area());
    endfunction

endclass : rectangle

`endif
