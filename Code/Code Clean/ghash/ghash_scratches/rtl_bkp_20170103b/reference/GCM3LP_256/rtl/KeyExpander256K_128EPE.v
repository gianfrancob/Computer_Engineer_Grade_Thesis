`timescale 1 ns / 1 ps
//
// Copyright (c) 2016 by IP Cores, Inc.   All rights reserved.  This text
// contains proprietary, confidential information of IP Cores, Inc.,  and
// may be used, copied,  and/or disclosed only pursuant to the terms of a
// valid license agreement with IP Cores, Inc. This copyright notice must
// be retained as part of this text at all times.
//
// Rev. 1.0
// Rev. 1.01 - some lint clean-up, fully compatible with 1.0
// Rev. 2.0 - added GMAC mode per customer request
//

module KeyExpander256K_128Epe(

   input               clk,
   input               cen,
   input               reset,

   input               rotate,
   input         [7:0] RconIn,

   input       [255:0] Key,

   output reg    [7:0] RconOut,
   output reg  [127:0] Qx,
   output wire [127:0] RK

);

   reg  [127:0] r;

   wire [31:0] rot;
   wire [31:0] Sbx;

   assign RK = r;

   always @(posedge clk or posedge reset) begin
      if ( reset ) begin
         Qx      <= 128'h0;
         r       <= 128'h0;
         RconOut <= 8'h0;
      end
      else if ( cen ) begin
         r <= Key[127:0];

         RconOut <= rotate ? RC ( RconIn ) : RconIn;

         Qx[127: 96] <= Key[ 255: 224] ^ rot;
         Qx[ 95: 64] <= Key[ 223: 192] ^ Key[ 255: 224] ^ rot;
         Qx[ 63: 32] <= Key[ 191: 160] ^ Key[ 223: 192] ^ Key[ 255: 224] ^ rot;
         Qx[ 31:  0] <= Key[ 159: 128] ^ Key[ 191: 160] ^ Key[ 223: 192] ^ Key[ 255: 224] ^ rot;

      end
   end

   assign rot = rotate ? { Sbx[23:16] ^ RconIn, Sbx[15: 8], Sbx[7:0], Sbx[31:24] } : Sbx;

   Sbox sb3 ( .Din( Key[31: 24] ), .S(Sbx[ 31:  24]) );
   Sbox sb2 ( .Din( Key[23: 16] ), .S(Sbx[ 23:  16]) );
   Sbox sb1 ( .Din( Key[15:  8] ), .S(Sbx[ 15:   8]) );
   Sbox sb0 ( .Din( Key[ 7:  0] ), .S(Sbx[  7:   0]) );

   function [7:0] RC (input [7:0] a);

      RC = {a[6:4], a[3:0] ^ {a[7], a[7], 1'b0, a[7]}, a[7]};

   endfunction

endmodule
