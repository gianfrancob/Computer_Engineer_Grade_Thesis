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

module gmp2x16(
   input        [1:0] x,
   input       [15:0] y,
   output wire [17:0] z
);

   wire [17:0] Z0, Z1;

   assign Z1  = x[1] ? {       y,  2'h0 } : 18'h0;
   assign Z0  = x[0] ? { 1'h0, y,  1'h0 } : 18'h0;
   assign z = Z0 ^ Z1;

endmodule
