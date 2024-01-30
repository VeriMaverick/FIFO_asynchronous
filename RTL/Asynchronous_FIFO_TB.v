`timescale 1ns / 1ns
module Asynchronous_FIFO_TB();

parameter DATA_WIDTH = 8;
parameter ADDR_WIDTH = 3;

reg                         wclk;
reg                         wrst_n;
reg                         winc;
reg     [DATA_WIDTH-1:0]    wdata;
reg                         rclk;
reg                         rrst_n;
reg                         rinc;
wire    [DATA_WIDTH-1:0]    rdata;  
wire                        wfull;  
wire                        rempty;  

Asynchronous_FIFO #(DATA_WIDTH , ADDR_WIDTH) FIFO(
    .wclk  (wclk), 
    .wrst_n(wrst_n), 
    .winc  (winc), 
    .wdata (wdata),
    .rclk  (rclk),
    .rrst_n(rrst_n),
    .rinc  (rinc),
    .rdata (rdata),
    .wfull (wfull),
    .rempty(rempty)
);

//Clock cycle 
localparam CYCLE_W = 20;    // write clock cycle
localparam CYCLE_R = 10;    // read clock cycle

// generate write clock
initial begin
    wclk = 0;
    forever
    #(CYCLE_W/2)
    wclk=~wclk;
end

// generate read clock
initial begin
    rclk = 0;
    forever
    #(CYCLE_R/2)
    rclk=~rclk;
end

// generate write reset signal
initial begin
    wrst_n = 0;
    #(CYCLE_W*2);
    wrst_n = 1;
end

// generate read reset signal
initial begin
    rrst_n = 0;
    #(CYCLE_R*2);
    rrst_n = 1;
end

integer i;

initial begin
    winc = 0;
    rinc = 0;
    #(CYCLE_W*10);

    winc = 1;
    wdata = {DATA_WIDTH{1'b0}};
    for(i=0;i< 8;i=i+1) begin
        wdata = wdata + 1'b1;
        #(CYCLE_W*1);
    end
    winc = 0;
    rinc = 1;

    // finish simulation
    #(CYCLE_R * 10);
    $stop;
end

endmodule