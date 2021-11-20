`include "shape.svh"
`include "rectangle.svh"
`include "square.svh"
`include "triangle.svh"
`include "shape_factory.svh"
`include "shape_reporter.svh"

module top;
    
    initial begin
        shape shape_i;
        int fd;
        string shape_type;
        real w, h;
        
        fd = $fopen("lab04part1_shapes.txt", "r");
        
        while($fscanf(fd, "%s %f %f", shape_type, w, h) == 3) begin
            shape_i = shape_factory::make_shape(shape_type, w, h);
        end
        
        $display();
        shape_reporter#(rectangle)::report_shapes();
        $display();
        shape_reporter#(square)::report_shapes();
        $display();
        shape_reporter#(triangle)::report_shapes();
        $display();
    end
    
endmodule
