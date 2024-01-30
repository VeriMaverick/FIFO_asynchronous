module FIFO_RAM #(
    parameter  DATASIZE = 32, // Memory data word width               
    parameter  ADDRSIZE = 6  // 指针地址位宽设定为6，地址宽度则为5(定义为6是为进位)，fifo深度则为2^5
) // Number of mem address bits
(
    input  wclk, 
    input  wclken,
    input  wfull,
    input  [DATASIZE-1:0] wdata, 
    input  [ADDRSIZE-1:0] waddr,
    input  [ADDRSIZE-1:0] raddr,
    output [DATASIZE-1:0] rdata
);

 // RTL Verilog memory model
localparam DEPTH = 1<<ADDRSIZE;   // 左移相当于乘法，2^6

reg [DATASIZE-1:0] mem [0:DEPTH-1]; //fifo深度+位宽定义

assign rdata = mem[raddr];

always @(posedge wclk) begin//当写使能有效且还未写满的时候将数据写入存储实体中，注意这里是与wclk同步的
    if (wclken && !wfull) begin
        mem[waddr] <= wdata;
    end else begin
        mem[waddr] <= mem[waddr];
    end
end

endmodule 