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

module encoder128PL2S(

   input                clk,
   input                cen,

   input [127:0]        RoundKey,
   input [127:0]        Din,
   output wire [127:0]  Q,         // output for the next stage
   output wire [127:0]  Dout       // final stage output
);

   wire [127:0] m, MCin, s;
   wire [127:0] SbxR;

   assign Q    =    m ^ RoundKey;
   assign Dout = SbxR ^ RoundKey;

   assign MCin =  SbxR;

   assign s = ShiftRows( Din );


   Sbox2R sb7 ( .clk(clk), .cen(cen), .Din0(s[127: 120]), .Din1(s[119: 112]), .S0(SbxR[127: 120]), .S1(SbxR[119: 112]));
   Sbox2R sb6 ( .clk(clk), .cen(cen), .Din0(s[111: 104]), .Din1(s[103:  96]), .S0(SbxR[111: 104]), .S1(SbxR[103:  96]));
   Sbox2R sb5 ( .clk(clk), .cen(cen), .Din0(s[ 95:  88]), .Din1(s[ 87:  80]), .S0(SbxR[ 95:  88]), .S1(SbxR[ 87:  80]));
   Sbox2R sb4 ( .clk(clk), .cen(cen), .Din0(s[ 79:  72]), .Din1(s[ 71:  64]), .S0(SbxR[ 79:  72]), .S1(SbxR[ 71:  64]));
   Sbox2R sb3 ( .clk(clk), .cen(cen), .Din0(s[ 63:  56]), .Din1(s[ 55:  48]), .S0(SbxR[ 63:  56]), .S1(SbxR[ 55:  48]));
   Sbox2R sb2 ( .clk(clk), .cen(cen), .Din0(s[ 47:  40]), .Din1(s[ 39:  32]), .S0(SbxR[ 47:  40]), .S1(SbxR[ 39:  32]));
   Sbox2R sb1 ( .clk(clk), .cen(cen), .Din0(s[ 31:  24]), .Din1(s[ 23:  16]), .S0(SbxR[ 31:  24]), .S1(SbxR[ 23:  16]));
   Sbox2R sb0 ( .clk(clk), .cen(cen), .Din0(s[ 15:   8]), .Din1(s[  7:   0]), .S0(SbxR[ 15:   8]), .S1(SbxR[  7:   0]));

   MixCol mcc0(

      .a0( MCin[127: 120]),
      .a1( MCin[119: 112]),
      .a2( MCin[111: 104]),
      .a3( MCin[103:  96]),

      .m0( m[127: 120]),
      .m1( m[119: 112]),
      .m2( m[111: 104]),
      .m3( m[103:  96])
   );

   MixCol mcc1(

      .a0( MCin[ 95:  88]),
      .a1( MCin[ 87:  80]),
      .a2( MCin[ 79:  72]),
      .a3( MCin[ 71:  64]),

      .m0( m[ 95:  88]),
      .m1( m[ 87:  80]),
      .m2( m[ 79:  72]),
      .m3( m[ 71:  64])
   );

   MixCol mcc2(

      .a0( MCin[ 63:  56]),
      .a1( MCin[ 55:  48]),
      .a2( MCin[ 47:  40]),
      .a3( MCin[ 39:  32]),

      .m0( m[ 63:  56]),
      .m1( m[ 55:  48]),
      .m2( m[ 47:  40]),
      .m3( m[ 39:  32])
   );

   MixCol mcc3(

      .a0( MCin[ 31:  24]),
      .a1( MCin[ 23:  16]),
      .a2( MCin[ 15:   8]),
      .a3( MCin[  7:   0]),

      .m0( m[ 31:  24]),
      .m1( m[ 23:  16]),
      .m2( m[ 15:   8]),
      .m3( m[  7:   0])
   );

   function [127:0] ShiftRows(input [127:0] a );

                 ShiftRows = {
                               a[127: 120],
                               a[ 87:  80],
                               a[ 47:  40],
                               a[  7:   0],
                               a[ 95:  88],
                               a[ 55:  48],
                               a[ 15:   8],
                               a[103:  96],
                               a[ 63:  56],
                               a[ 23:  16],
                               a[111: 104],
                               a[ 71:  64],
                               a[ 31:  24],
                               a[119: 112],
                               a[ 79:  72],
                               a[ 39:  32]
                             };

    endfunction

endmodule
