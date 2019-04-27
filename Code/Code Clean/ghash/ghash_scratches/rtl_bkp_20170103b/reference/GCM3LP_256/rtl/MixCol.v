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


module MixCol(

   input       [7:0] a3,
   input       [7:0] a2,
   input       [7:0] a1,
   input       [7:0] a0,

   output wire [7:0] m3,
   output wire [7:0] m2,
   output wire [7:0] m1,
   output wire [7:0] m0

);

   wire [7:0] X0, X1, X2, X3;

   assign X3 = a3 ^ a0;
   assign X2 = a2 ^ a3;
   assign X1 = a1 ^ a2;
   assign X0 = a0 ^ a1;

   assign m3 = xtime(X3) ^ a0 ^ a1 ^ a2 ;
   assign m2 = xtime(X2) ^ a3 ^ a0 ^ a1 ;
   assign m1 = xtime(X1) ^ a2 ^ a3 ^ a0 ;
   assign m0 = xtime(X0) ^ a1 ^ a2 ^ a3 ;

   function [7:0] xtime;   // multiplication by 02 in GF(2^8)
      input [7:0] x;

      begin

         xtime =  {x[6:0], 1'b0} ^ (8'h1B & { 8 {x[7]}});

      end

   endfunction

endmodule
