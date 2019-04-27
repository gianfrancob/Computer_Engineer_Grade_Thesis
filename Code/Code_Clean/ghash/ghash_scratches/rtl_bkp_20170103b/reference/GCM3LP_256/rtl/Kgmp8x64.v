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

module Kgmp8x64(
   input        [ 7:0] x,
   input        [63:0] y,
   output wire  [71:0] z
);

   wire [ 3:0] Xo;
   wire [ 3:0] Xe;
   wire [31:0] Yo;
   wire [31:0] Ye;
   wire [35:0] Zo;
   wire [35:0] Ze;
   wire [35:0] Zeo;
   wire [35:0] z0;
   wire [35:0] z1;

   assign Xo = odd8(x);
   assign Xe = even8(x);

   assign Yo = odd64(y);
   assign Ye = even64(y);

   assign z0 = Ze ^ (Zo >> 1);
   assign z1 = Zeo ^ Ze ^ Zo;

   assign z = comb72(z0, z1);

   Kgmp4x32 Pe (
      .x     ( Xe     ),
      .y     ( Ye     ),
      .z     ( Ze     )
   );

   Kgmp4x32 Po (
      .x     ( Xo     ),
      .y     ( Yo     ),
      .z     ( Zo     )
   );

   Kgmp4x32 Peo (
      .x     ( Xo ^ Xe   ),
      .y     ( Yo ^ Ye   ),
      .z     ( Zeo       )
   );

   function [31:0] odd64 (input [63:0] a);
      odd64  = { 
                 a[62], a[60], a[58], a[56], a[54], a[52], a[50], a[48], a[46], a[44], a[42], a[40], a[38], a[36], a[34], a[32],
                 a[30], a[28], a[26], a[24], a[22], a[20], a[18], a[16], a[14], a[12], a[10], a[8], a[6], a[4], a[2], a[0]
               };
   endfunction

   function [31:0] even64 (input [63:0] a);
      even64  = {
                 a[63], a[61], a[59], a[57], a[55], a[53], a[51], a[49], a[47], a[45], a[43], a[41], a[39], a[37], a[35], a[33],
                 a[31], a[29], a[27], a[25], a[23], a[21], a[19], a[17], a[15], a[13], a[11], a[9], a[7], a[5], a[3], a[1]
                };
   endfunction

   function [3:0] odd8 (input [7:0] a);
      odd8   = { 
                 a[6], a[4], a[2], a[0]
               };
   endfunction

   function [3:0] even8 (input [7:0] a);
      even8  = {
                 a[7], a[5], a[3], a[1]
                };
   endfunction

   function [71:0] comb72 ( input [35:0] z0, input [35:0] z1 );
      comb72   = {
                   z0[35], z1[35], z0[34], z1[34], z0[33], z1[33], z0[32], z1[32],
                   z0[31], z1[31], z0[30], z1[30], z0[29], z1[29], z0[28], z1[28],
                   z0[27], z1[27], z0[26], z1[26], z0[25], z1[25], z0[24], z1[24],
                   z0[23], z1[23], z0[22], z1[22], z0[21], z1[21], z0[20], z1[20],
                   z0[19], z1[19], z0[18], z1[18], z0[17], z1[17], z0[16], z1[16],
                   z0[15], z1[15], z0[14], z1[14], z0[13], z1[13], z0[12], z1[12],
                   z0[11], z1[11], z0[10], z1[10], z0[ 9], z1[ 9], z0[ 8], z1[ 8],
                   z0[ 7], z1[ 7], z0[ 6], z1[ 6], z0[ 5], z1[ 5], z0[ 4], z1[ 4],
                   z0[ 3], z1[ 3], z0[ 2], z1[ 2], z0[ 1], z1[ 1], z0[ 0], z1[ 0]
                };
   endfunction

endmodule
