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


module Kgmp8x8(
   input        [ 7:0] x,
   input        [ 7:0] y,
   output wire  [15:0] z
);

   wire [3:0] xL;
   wire [3:0] xH;
   wire [3:0] yL;
   wire [3:0] yH;
   wire [3:0] xM;
   wire [3:0] yM;

   wire  [ 7:0] zH;
   wire  [ 7:0] zL;
   wire  [ 7:0] zM;

   assign xL = x[ 7: 4];
   assign xH = x[ 3: 0];
   assign yL = y[ 7: 4];
   assign yH = y[ 3: 0];
   assign xM = xL ^ xH;
   assign yM = yL ^ yH;


   assign z = { zL, zH} ^ {4'h0, (zH ^ zL ^ zM), 4'h0 };

   gmp4x4 PL (
      .x ( xL   ),
      .y ( yL   ),
      .z ( zL   )
   );

   gmp4x4 PH (
      .x ( xH   ),
      .y ( yH   ),
      .z ( zH   )
   );

   gmp4x4 PM (
      .x ( xM   ),
      .y ( yM   ),
      .z ( zM   )
   );

endmodule
