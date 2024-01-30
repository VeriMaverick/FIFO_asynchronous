module sync_w2r #(
    parameter ADDR_WIDTH = 3
)
(
    input                       rclk, 
    input                       rrst_n,
    input       [ADDR_WIDTH:0]  wptr,       // 输入写指针
    output  reg [ADDR_WIDTH:0]  rq2_wptr    // 写指针同步到读时钟域
);
 
reg [ADDR_WIDTH:0] rq1_wptr;
 
always @(posedge rclk or negedge rrst_n) begin
    if(!rrst_n) begin
        rq1_wptr <= {ADDR_WIDTH{1'b0}};
        rq2_wptr <= {ADDR_WIDTH{1'b0}};
    end else begin
        rq1_wptr <= wptr;
        rq2_wptr <= rq1_wptr;
    end
end
        
endmodule