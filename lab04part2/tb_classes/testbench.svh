`ifndef TESTBENCH_SVH
`define TESTBENCH_SVH

`include "coverage.svh"
`include "scoreboard.svh"
`include "tester.svh"

class testbench;

    protected virtual alu_bfm bfm;

    function new(virtual alu_bfm b);
        bfm = b;
    endfunction
    
    protected coverage coverage_h;
    protected scoreboard scoreboard_h;
    protected tester tester_h;

    task execute();
        coverage_h = new(bfm);
        scoreboard_h = new(bfm);
        tester_h = new(bfm);
        fork
            coverage_h.execute();
            scoreboard_h.execute();
            tester_h.execute();
        join_none
    endtask

endclass : testbench

`endif
