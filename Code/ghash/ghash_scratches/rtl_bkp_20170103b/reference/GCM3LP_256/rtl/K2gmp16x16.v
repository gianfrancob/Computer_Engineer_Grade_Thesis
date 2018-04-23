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


module K2gmp16x16(
   input        [15:0] x,
   input        [15:0] y,
   output wire  [31:0] z
);

   wire [7:0] xL;
   wire [7:0] xH;
   wire [7:0] yL;
   wire [7:0] yH;
   wire [7:0] xM;
   wire [7:0] yM;

   wire  [15:0] zH;
   wire  [15:0] zL;
   wire  [15:0] zM;

   assign xL = x[15: 8];
   assign xH = x[ 7: 0];
   assign yL = y[15: 8];
   assign yH = y[ 7: 0];
   assign xM = xL ^ xH;
   assign yM = yL ^ yH;


   assign z = { zL, zH} ^ {8'h0, (zH ^ zL ^ zM), 8'h0 };

   Kgmp8x8 PL (
      .x ( xL   ),
      .y ( yL   ),
      .z ( zL   )
   );

   Kgmp8x8 PH (
      .x ( xH   ),
      .y ( yH   ),
      .z ( zH   )
   );

   Kgmp8x8 PM (
      .x ( xM   ),
      .y ( yM   ),
      .z ( zM   )
   );

endmodule
