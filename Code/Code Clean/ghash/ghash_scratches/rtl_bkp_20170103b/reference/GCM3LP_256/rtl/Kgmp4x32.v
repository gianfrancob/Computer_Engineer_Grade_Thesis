`timescale 1 ns / 1 ps
//
// Copyright (c) 2016 by IP Cores, Inc.   All rights reserved.  This text
// contains proprietary, confidential information of IP Cores, Inc.,  and
// may be used, copied,  and/or disclosed only pursuant to the terms of a
// valid license agreement with IP Cores, Inc. This copyright notice must
// be retained as part of this text at all times.
//
// Rev. 1.0
//

module Kgmp4x32(
   input        [ 3:0] x,
   input        [31:0] y,
   output wire  [35:0] z
);

   wire [ 1:0] Xo;
   wire [ 1:0] Xe;
   wire [15:0] Yo;
   wire [15:0] Ye;
   wire [17:0] Zo;
   wire [17:0] Ze;
   wire [17:0] Zeo;
   wire [17:0] z0;
   wire [17:0] z1;

   assign Xo = odd4(x);
   assign Xe = even4(x);

   assign Yo = odd32(y);
   assign Ye = even32(y);

   assign z0 = Ze ^ (Zo >> 1);
   assign z1 = Zeo ^ Ze ^ Zo;

   assign z = comb36(z0, z1);

   gmp2x16 Pe (
      .x     ( Xe     ),
      .y     ( Ye     ),
      .z     ( Ze     )
   );

   gmp2x16 Po (
      .x     ( Xo     ),
      .y     ( Yo     ),
      .z     ( Zo     )
   );

   gmp2x16 Peo (
      .x     ( Xo ^ Xe   ),
      .y     ( Yo ^ Ye   ),
      .z     ( Zeo       )
   );

   function [15:0] odd32 (input [31:0] a);
      odd32  = { 
                 a[30], a[28], a[26], a[24], a[22], a[20], a[18], a[16], a[14], a[12], a[10], a[8], a[6], a[4], a[2], a[0]
               };
   endfunction

   function [15:0] even32 (input [31:0] a);
      even32  = {
                 a[31], a[29], a[27], a[25], a[23], a[21], a[19], a[17], a[15], a[13], a[11], a[9], a[7], a[5], a[3], a[1]
                };
   endfunction

   function [1:0] odd4 (input [3:0] a);
      odd4   = { 
                 a[2], a[0]
               };
   endfunction

   function [1:0] even4 (input [3:0] a);
      even4  = {
                 a[3], a[1]
                };
   endfunction


   function [35:0] comb36 ( input [17:0] z0, input [17:0] z1 );
      comb36  = {
                   z0[17], z1[17], z0[16], z1[16],
                   z0[15], z1[15], z0[14], z1[14], z0[13], z1[13], z0[12], z1[12],
                   z0[11], z1[11], z0[10], z1[10], z0[ 9], z1[ 9], z0[ 8], z1[ 8],
                   z0[ 7], z1[ 7], z0[ 6], z1[ 6], z0[ 5], z1[ 5], z0[ 4], z1[ 4],
                   z0[ 3], z1[ 3], z0[ 2], z1[ 2], z0[ 1], z1[ 1], z0[ 0], z1[ 0]
                };
   endfunction

endmodule
