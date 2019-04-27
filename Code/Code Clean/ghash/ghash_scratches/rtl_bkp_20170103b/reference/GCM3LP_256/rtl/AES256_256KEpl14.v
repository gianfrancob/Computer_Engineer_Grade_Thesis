`timescale 1 ns / 1 ps
//
// Copyright (c) 2016 by IP Cores, Inc.   All rights reserved.  This text
// contains proprietary, confidential information of IP Cores, Inc.,  and
// may be used, copied,  and/or disclosed only pursuant to the terms of a
// valid license agreement with IP Cores, Inc. This copyright notice must
// be retained as part of this text at all times.
//
// Rev. 1.0
// Rev. 1.01 - some lint clean-up, fully compatible with 1.0
// Rev. 2.0 - added GMAC mode per customer request
//

module AES256_256KEpl14(

   input               clk,
   input               cen,
   input               reset,

   input       [255:0] Key,
   input       [255:0] Din,
   output wire [255:0] Dout

);

   wire [127:0] pxM  [0:13];
   wire [127:0] pxL  [0:13];

   wire [127:0] RKx  [0:12];
   wire   [7:0] rcon [0:12];

   wire [127:0] RoundKey0;
   wire [127:0] RoundKey1;
   wire [127:0] RoundKey2;
   wire [127:0] RoundKey3;
   wire [127:0] RoundKey4;
   wire [127:0] RoundKey5;
   wire [127:0] RoundKey6;
   wire [127:0] RoundKey7;
   wire [127:0] RoundKey8;
   wire [127:0] RoundKey9;
   wire [127:0] RoundKey10;
   wire [127:0] RoundKey11;
   wire [127:0] RoundKey12;
   wire [127:0] RoundKey13;

   wire [127:0] Q256M;
   wire [127:0] Q256L;

   assign Dout = { Q256M, Q256L };

   assign pxM[0] = Din[255:128] ^ Key[255:128];
   assign pxL[0] = Din[127:  0] ^ Key[255:128];

   encoder128PL2S eM0  ( .clk(clk), .cen(cen), .RoundKey(RoundKey0 ), .Din(pxM[ 0]), .Q(pxM[ 1]), .Dout());
   encoder128PL2S eM1  ( .clk(clk), .cen(cen), .RoundKey(RoundKey1 ), .Din(pxM[ 1]), .Q(pxM[ 2]), .Dout());
   encoder128PL2S eM2  ( .clk(clk), .cen(cen), .RoundKey(RoundKey2 ), .Din(pxM[ 2]), .Q(pxM[ 3]), .Dout());
   encoder128PL2S eM3  ( .clk(clk), .cen(cen), .RoundKey(RoundKey3 ), .Din(pxM[ 3]), .Q(pxM[ 4]), .Dout());
   encoder128PL2S eM4  ( .clk(clk), .cen(cen), .RoundKey(RoundKey4 ), .Din(pxM[ 4]), .Q(pxM[ 5]), .Dout());
   encoder128PL2S eM5  ( .clk(clk), .cen(cen), .RoundKey(RoundKey5 ), .Din(pxM[ 5]), .Q(pxM[ 6]), .Dout());
   encoder128PL2S eM6  ( .clk(clk), .cen(cen), .RoundKey(RoundKey6 ), .Din(pxM[ 6]), .Q(pxM[ 7]), .Dout());
   encoder128PL2S eM7  ( .clk(clk), .cen(cen), .RoundKey(RoundKey7 ), .Din(pxM[ 7]), .Q(pxM[ 8]), .Dout());
   encoder128PL2S eM8  ( .clk(clk), .cen(cen), .RoundKey(RoundKey8 ), .Din(pxM[ 8]), .Q(pxM[ 9]), .Dout());
   encoder128PL2S eM9  ( .clk(clk), .cen(cen), .RoundKey(RoundKey9 ), .Din(pxM[ 9]), .Q(pxM[10]), .Dout());
   encoder128PL2S eM10 ( .clk(clk), .cen(cen), .RoundKey(RoundKey10), .Din(pxM[10]), .Q(pxM[11]), .Dout());
   encoder128PL2S eM11 ( .clk(clk), .cen(cen), .RoundKey(RoundKey11), .Din(pxM[11]), .Q(pxM[12]), .Dout());
   encoder128PL2S eM12 ( .clk(clk), .cen(cen), .RoundKey(RoundKey12), .Din(pxM[12]), .Q(pxM[13]), .Dout());
   encoder128PL2S eM13 ( .clk(clk), .cen(cen), .RoundKey(RoundKey13), .Din(pxM[13]), .Q(),        .Dout(Q256M));

   encoder128PL2S eL0  ( .clk(clk), .cen(cen), .RoundKey(RoundKey0 ), .Din(pxL[ 0]), .Q(pxL[ 1]), .Dout());
   encoder128PL2S eL1  ( .clk(clk), .cen(cen), .RoundKey(RoundKey1 ), .Din(pxL[ 1]), .Q(pxL[ 2]), .Dout());
   encoder128PL2S eL2  ( .clk(clk), .cen(cen), .RoundKey(RoundKey2 ), .Din(pxL[ 2]), .Q(pxL[ 3]), .Dout());
   encoder128PL2S eL3  ( .clk(clk), .cen(cen), .RoundKey(RoundKey3 ), .Din(pxL[ 3]), .Q(pxL[ 4]), .Dout());
   encoder128PL2S eL4  ( .clk(clk), .cen(cen), .RoundKey(RoundKey4 ), .Din(pxL[ 4]), .Q(pxL[ 5]), .Dout());
   encoder128PL2S eL5  ( .clk(clk), .cen(cen), .RoundKey(RoundKey5 ), .Din(pxL[ 5]), .Q(pxL[ 6]), .Dout());
   encoder128PL2S eL6  ( .clk(clk), .cen(cen), .RoundKey(RoundKey6 ), .Din(pxL[ 6]), .Q(pxL[ 7]), .Dout());
   encoder128PL2S eL7  ( .clk(clk), .cen(cen), .RoundKey(RoundKey7 ), .Din(pxL[ 7]), .Q(pxL[ 8]), .Dout());
   encoder128PL2S eL8  ( .clk(clk), .cen(cen), .RoundKey(RoundKey8 ), .Din(pxL[ 8]), .Q(pxL[ 9]), .Dout());
   encoder128PL2S eL9  ( .clk(clk), .cen(cen), .RoundKey(RoundKey9 ), .Din(pxL[ 9]), .Q(pxL[10]), .Dout());
   encoder128PL2S eL10 ( .clk(clk), .cen(cen), .RoundKey(RoundKey10), .Din(pxL[10]), .Q(pxL[11]), .Dout());
   encoder128PL2S eL11 ( .clk(clk), .cen(cen), .RoundKey(RoundKey11), .Din(pxL[11]), .Q(pxL[12]), .Dout());
   encoder128PL2S eL12 ( .clk(clk), .cen(cen), .RoundKey(RoundKey12), .Din(pxL[12]), .Q(pxL[13]), .Dout());
   encoder128PL2S eL13 ( .clk(clk), .cen(cen), .RoundKey(RoundKey13), .Din(pxL[13]), .Q(),        .Dout(Q256L));

   KeyExpander256K_128Epe k0  ( .clk(clk), .cen(cen), .reset(reset), .rotate(1'b1), .RconIn( 8'h01  ), .Key(Key                  ), .RconOut(rcon[ 0]), .Qx(RKx[ 0]), .RK(RoundKey0 ));
   KeyExpander256K_128Epe k1  ( .clk(clk), .cen(cen), .reset(reset), .rotate(1'b0), .RconIn(rcon[ 0]), .Key({RoundKey0 , RKx[ 0]}), .RconOut(rcon[ 1]), .Qx(RKx[ 1]), .RK(RoundKey1 ));
   KeyExpander256K_128Epe k2  ( .clk(clk), .cen(cen), .reset(reset), .rotate(1'b1), .RconIn(rcon[ 1]), .Key({RoundKey1 , RKx[ 1]}), .RconOut(rcon[ 2]), .Qx(RKx[ 2]), .RK(RoundKey2 ));
   KeyExpander256K_128Epe k3  ( .clk(clk), .cen(cen), .reset(reset), .rotate(1'b0), .RconIn(rcon[ 2]), .Key({RoundKey2 , RKx[ 2]}), .RconOut(rcon[ 3]), .Qx(RKx[ 3]), .RK(RoundKey3 ));
   KeyExpander256K_128Epe k4  ( .clk(clk), .cen(cen), .reset(reset), .rotate(1'b1), .RconIn(rcon[ 3]), .Key({RoundKey3 , RKx[ 3]}), .RconOut(rcon[ 4]), .Qx(RKx[ 4]), .RK(RoundKey4 ));
   KeyExpander256K_128Epe k5  ( .clk(clk), .cen(cen), .reset(reset), .rotate(1'b0), .RconIn(rcon[ 4]), .Key({RoundKey4 , RKx[ 4]}), .RconOut(rcon[ 5]), .Qx(RKx[ 5]), .RK(RoundKey5 ));
   KeyExpander256K_128Epe k6  ( .clk(clk), .cen(cen), .reset(reset), .rotate(1'b1), .RconIn(rcon[ 5]), .Key({RoundKey5 , RKx[ 5]}), .RconOut(rcon[ 6]), .Qx(RKx[ 6]), .RK(RoundKey6 ));
   KeyExpander256K_128Epe k7  ( .clk(clk), .cen(cen), .reset(reset), .rotate(1'b0), .RconIn(rcon[ 6]), .Key({RoundKey6 , RKx[ 6]}), .RconOut(rcon[ 7]), .Qx(RKx[ 7]), .RK(RoundKey7 ));
   KeyExpander256K_128Epe k8  ( .clk(clk), .cen(cen), .reset(reset), .rotate(1'b1), .RconIn(rcon[ 7]), .Key({RoundKey7 , RKx[ 7]}), .RconOut(rcon[ 8]), .Qx(RKx[ 8]), .RK(RoundKey8 ));
   KeyExpander256K_128Epe k9  ( .clk(clk), .cen(cen), .reset(reset), .rotate(1'b0), .RconIn(rcon[ 8]), .Key({RoundKey8 , RKx[ 8]}), .RconOut(rcon[ 9]), .Qx(RKx[ 9]), .RK(RoundKey9 ));
   KeyExpander256K_128Epe k10 ( .clk(clk), .cen(cen), .reset(reset), .rotate(1'b1), .RconIn(rcon[ 9]), .Key({RoundKey9 , RKx[ 9]}), .RconOut(rcon[10]), .Qx(RKx[10]), .RK(RoundKey10));
   KeyExpander256K_128Epe k11 ( .clk(clk), .cen(cen), .reset(reset), .rotate(1'b0), .RconIn(rcon[10]), .Key({RoundKey10, RKx[10]}), .RconOut(rcon[11]), .Qx(RKx[11]), .RK(RoundKey11));
   KeyExpander256K_128Epe k12 ( .clk(clk), .cen(cen), .reset(reset), .rotate(1'b1), .RconIn(rcon[11]), .Key({RoundKey11, RKx[11]}), .RconOut(rcon[12]), .Qx(RKx[12]), .RK(RoundKey12));
   KeyExpander256K_128Epe k13 ( .clk(clk), .cen(cen), .reset(reset), .rotate(1'b0), .RconIn(rcon[12]), .Key({RoundKey12, RKx[12]}), .RconOut(        ), .Qx(       ), .RK(RoundKey13));

endmodule
