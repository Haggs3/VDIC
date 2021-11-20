`ifndef SHAPE_REPORTER_SVH
`define SHAPE_REPORTER_SVH

`include "shape.svh"

class shape_reporter #(type T = shape);

    protected static T shape_storage [$];

    static function void store_shape(T s);
        shape_storage.push_back(s);
    endfunction
    
    static function void report_shapes();
        real area_total;
        foreach(shape_storage[i]) begin
            area_total = area_total + shape_storage[i].get_area();
            shape_storage[i].print();
        end
        $display("Total area: %g", area_total);
    endfunction
    
endclass : shape_reporter

`endif
