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

module K4gmp64x64(
   input        [63:0] x,
   input        [63:0] y,
   output wire [127:0] z
);

   wire [31:0] xL;
   wire [31:0] xH;
   wire [31:0] yL;
   wire [31:0] yH;
   wire [31:0] xM;
   wire [31:0] yM;

   wire  [63:0] zH;
   wire  [63:0] zL;
   wire  [63:0] zM;

   assign xL = x[63:32];
   assign xH = x[31: 0];
   assign yL = y[63:32];
   assign yH = y[31: 0];
   assign xM = xL ^ xH;
   assign yM = yL ^ yH;

   assign z = { zL, zH} ^ {32'h0, (zH ^ zL ^ zM), 32'h0 };

   K3gmp32x32 PL (
      .x ( xL   ),
      .y ( yL   ),
      .z ( zL   )
   );

   K3gmp32x32 PH (
      .x ( xH   ),
      .y ( yH   ),
      .z ( zH   )
   );

   K3gmp32x32 PM (
      .x ( xM   ),
      .y ( yM   ),
      .z ( zM   )
   );

endmodule
