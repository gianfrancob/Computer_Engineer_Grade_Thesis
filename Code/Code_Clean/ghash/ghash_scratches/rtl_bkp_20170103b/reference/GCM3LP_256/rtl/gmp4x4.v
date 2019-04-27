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


module gmp4x4(
   input        [3:0] x,
   input        [3:0] y,
   output wire  [7:0] z
);

   wire [7:0] Z0, Z1, Z2, Z3;

   assign Z3  = y[3 ] ? {       x,  4'h0 } : 8'h0;
   assign Z2  = y[2 ] ? { 1'h0, x,  3'h0 } : 8'h0;
   assign Z1  = y[1 ] ? { 2'h0, x,  2'h0 } : 8'h0;
   assign Z0  = y[0 ] ? { 3'h0, x,  1'h0 } : 8'h0;
   assign z = Z0 ^ Z1 ^ Z2 ^ Z3;

endmodule
