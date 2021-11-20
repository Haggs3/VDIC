`ifndef SHAPE_SVH
`define SHAPE_SVH

virtual class shape;

    protected real width;
    protected real height;
    
    function new(real w, real h);
        width = w;
        height = h;
    endfunction

    pure virtual function real get_area();
    pure virtual function void print();

endclass : shape

`endif
