module wptr_full #(
    parameter ADDR_WIDTH = 3
) 
(
    input                           wclk,       // write clock
    input                           wrst_n,     // write reset
    input                           winc,       // write enable
    input       [ADDR_WIDTH  :0]    wq2_rptr,   // 
    output      [ADDR_WIDTH-1:0]    waddr,
    output  reg [ADDR_WIDTH  :0]    wptr,
    output  reg                     wfull       //FIFO full flag 
);

reg  [ADDR_WIDTH:0] wbin;         // 二进制写地址
wire [ADDR_WIDTH:0] wgraynext;    // 格雷码写地址
wire [ADDR_WIDTH:0] wbinnext;     // 二进制写地址

always @(posedge wclk or negedge wrst_n) begin
    if(!wrst_n) begin
        wbin  <= {ADDR_WIDTH{1'b0}};
        wptr  <= {ADDR_WIDTH{1'b0}};
    end else begin     
        wbin <= wbinnext;             // 直接作为存储实际地址
        wptr <= wgraynext;            // 输出到 sync_w2r 模块,被同步到读时钟域
    end
end

assign  waddr       = wbin[ADDR_WIDTH-1:0];           // 直接作为存储实际地址，比如连接到RAM的写地址端口
assign  wbinnext    = wbin + (winc & ~wfull);       // 二进制下 不满且有写请求时，指针加 1
assign  wgraynext   = (wbinnext>>1) ^ wbinnext;     // 二进制转格雷码
assign  wfull_val   = (wgraynext == { ~wq2_rptr[ADDR_WIDTH:ADDR_WIDTH-1],wq2_rptr[ADDR_WIDTH-2:0] }); // 写指针等于同步后的读指针时，认为FIFO满

always @(posedge wclk or negedge wrst_n) begin
    if (!wrst_n) begin
        wfull  <= 1'b0;   
    end else begin
        wfull  <= wfull_val;
    end
end
 
endmodule