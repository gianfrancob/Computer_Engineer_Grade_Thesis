`timescale 1 ns / 1 ps
//
// Copyright (c) 2016 by IP Cores, Inc.   All rights reserved.  This text
// contains proprietary, confidential information of IP Cores, Inc.,  and
// may be used, copied,  and/or disclosed only pursuant to the terms of a
// valid license agreement with IP Cores, Inc. This copyright notice must
// be retained as part of this text at all times.
//
// Rev. 1.0
// Rev. 2.0 - added GMAC mode per customer request
//


module K3gmp32x32(
   input        [31:0] x,
   input        [31:0] y,
   output wire  [63:0] z
);

   wire [15:0] xL;
   wire [15:0] xH;
   wire [15:0] yL;
   wire [15:0] yH;
   wire [15:0] xM;
   wire [15:0] yM;

   wire  [31:0] zH;
   wire  [31:0] zL;
   wire  [31:0] zM;

   assign xL = x[31:16];
   assign xH = x[15: 0];
   assign yL = y[31:16];
   assign yH = y[15: 0];
   assign xM = xL ^ xH;
   assign yM = yL ^ yH;


   assign z = { zL, zH} ^ {16'h0, (zH ^ zL ^ zM), 16'h0 };

   K2gmp16x16 PL (
      .x ( xL   ),
      .y ( yL   ),
      .z ( zL   )
   );

   K2gmp16x16 PH (
      .x ( xH   ),
      .y ( yH   ),
      .z ( zH   )
   );

   K2gmp16x16 PM (
      .x ( xM   ),
      .y ( yM   ),
      .z ( zM   )
   );

endmodule
