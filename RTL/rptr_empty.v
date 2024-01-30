module rptr_empty #(
    parameter ADDR_WIDTH = 3
)
(
    input                           rclk,           // read clock
    input                           rrst_n,         // read reset
    input                           rinc,           // read enable
    input       [ADDR_WIDTH  :0]    rq2_wptr,       // read clock domain write pointer
    output      [ADDR_WIDTH-1:0]    raddr,          // read address
    output  reg [ADDR_WIDTH  :0]    rptr,           // read pointer     gray read address
    output  reg                     rempty          // fifo empty flag
);

reg  [ADDR_WIDTH:0] rbin;         // binary read address
wire [ADDR_WIDTH:0] rgraynext;    // gray read address
wire [ADDR_WIDTH:0] rbinnext;     // next binary read address

assign raddr     = rbin[ADDR_WIDTH-1:0];        // practical read address
assign rbinnext  = rbin + (rinc & ~rempty);     // 
assign rgraynext = (rbinnext>>1) ^ rbinnext;    // binary to gray

// 指针同步到读时钟域
always @(posedge rclk or negedge rrst_n) begin
    if (!rrst_n) begin
        rbin <= {ADDR_WIDTH{1'b0}};
        rptr <= {ADDR_WIDTH{1'b0}};
    end else begin        
        rbin <= rbinnext;
        rptr <= rgraynext;            // 输出到 sync_w2r 模块,被同步到写时钟域
    end
end

// FIFO empty when the next rptr == synchronized wptr or on reset 
assign rempty_val = (rgraynext == rq2_wptr);    // 读指针等于同步后的写指针时，认为FIFO空

always @(posedge rclk or negedge rrst_n) begin
    if (!rrst_n) begin
        rempty <= 1'b1; 
    end else begin
        rempty <= rempty_val;
    end
end

endmodule 