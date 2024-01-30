module Asynchronous_FIFO #(
    parameter DATA_WIDTH = 8,        
    parameter ADDR_WIDTH = 3
) 
(
    input                       wclk,       // write clock
    input                       wrst_n,     // write reset
    input                       winc,       // write enable
    input   [DATA_WIDTH-1:0]    wdata,      // write data
    input                       rclk,       // read clock
    input                       rrst_n,     // read reset
    input                       rinc,       // read enable
    output  [DATA_WIDTH-1:0]    rdata,      // read data
    output                      wfull,      // FIFO full flag
    output                      rempty      // FIFO empty flag
 );

wire [DATA_WIDTH-1:0]    waddr;      // write address
wire [DATA_WIDTH-1:0]    raddr;      // read address
wire [ADDR_WIDTH:0]      wptr;       // write pointer
wire [ADDR_WIDTH:0]      rptr;       // read pointer
wire [ADDR_WIDTH:0]      wq2_rptr;   // write pointer in read clock domain
wire [ADDR_WIDTH:0]      rq2_wptr;   // read pointer in write clock domain

sync_r2w #(ADDR_WIDTH) sync_r2w (
    .wq2_rptr    (wq2_rptr  ),
    .rptr        (rptr      ),                          
    .wclk        (wclk      ), 
    .wrst_n      (wrst_n    )  
 );

sync_w2r #(ADDR_WIDTH) sync_w2r (
    .rq2_wptr   (rq2_wptr   ), 
    .wptr       (wptr       ),                          
    .rclk       (rclk       ),
    .rrst_n     (rrst_n     )
);
 
FIFO_RAM #(DATA_WIDTH, ADDR_WIDTH) FIFO_RAM                        
(
    .rdata(rdata), 
    .wdata(wdata),                           
    .waddr(waddr),
    .raddr(raddr),                           
    .wclken(winc),
    .wfull(wfull),                           
    .wclk(wclk)
);

rptr_empty #(ADDR_WIDTH) rptr_empty                          
(
    .rempty(rempty),                          
    .raddr(raddr),                          
    .rptr(rptr),
    .rq2_wptr(rq2_wptr),                          
    .rinc(rinc),
    .rclk(rclk),                          
    .rrst_n(rrst_n)
);

wptr_full #(ADDR_WIDTH) wptr_full                         
(
    .wfull(wfull),
    .waddr(waddr),  
    .wptr(wptr),
    .wq2_rptr(wq2_rptr),    
    .winc(winc),
    .wclk(wclk),        
    .wrst_n(wrst_n)
);

endmodule