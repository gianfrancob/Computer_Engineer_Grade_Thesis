`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2016 04:45:38 PM
// Design Name: 
// Module Name: top_instancia
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_microblaze
    (
        input           	 CLK100MHZ,
        input 	[3:0]        sw,
        input 	[3:0]        btn,
        output 	[3:0]        led,
        output          	 uart_rxd_out,
        input           	 uart_txd_in 
    );

        reg [3:0] copydata;
        reg       uart_txd_in_d;
        wire reset;
        wire sys_clock;

        assign  reset           = sw[0];
        assign  sys_clock       = CLK100MHZ;

//        assign  uart_rxd_out    = !uart_txd_in;
        assign  uart_rxd_out    = uart_txd_in;

        always@(posedge CLK100MHZ) begin
            uart_txd_in_d <= uart_txd_in;
            if(uart_txd_in_d!=uart_txd_in)
                copydata <= {copydata[2:0],uart_txd_in};
            else
                copydata <= copydata;
        end
        
        assign led = copydata;
        
        
    
endmodule

