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

module K5gmp128x128(
   input       [127:0] x,
   input       [127:0] y,
   output wire [127:0] z
);

   wire [63:0] xL;
   wire [63:0] xH;
   wire [63:0] yL;
   wire [63:0] yH;
   wire [63:0] xM;
   wire [63:0] yM;

   wire [127:0] zH;
   wire [127:0] zL;
   wire [127:0] zM;

   assign xL = x[127:64];
   assign xH = x[ 63: 0];
   assign yL = y[127:64];
   assign yH = y[ 63: 0];
   assign xM = xL ^ xH;
   assign yM = yL ^ yH;


   assign z = P128(zH) ^ zL ^ P64(zH ^ zL ^ zM);

   K4gmp64x64 PL (
      .x ( xL   ),
      .y ( yL   ),
      .z ( zL   )
   );

   K4gmp64x64 PH (
      .x ( xH   ),
      .y ( yH   ),
      .z ( zH   )
   );

   K4gmp64x64 PM (
      .x ( xM   ),
      .y ( yM   ),
      .z ( zM   )
   );

   function [127:0] P64 (input [127:0] a);
      P64 = {
             a[63],
             a[63] ^ a[62],
             a[63] ^ a[62] ^ a[61],
             a[62] ^ a[61] ^ a[60],
             a[61] ^ a[60] ^ a[59],
             a[60] ^ a[59] ^ a[58],
             a[59] ^ a[58] ^ a[57],
             a[63] ^ a[58] ^ a[57] ^ a[56],
             a[62] ^ a[57] ^ a[56] ^ a[55],
             a[61] ^ a[56] ^ a[55] ^ a[54],
             a[60] ^ a[55] ^ a[54] ^ a[53],
             a[59] ^ a[54] ^ a[53] ^ a[52],
             a[58] ^ a[53] ^ a[52] ^ a[51],
             a[57] ^ a[52] ^ a[51] ^ a[50],
             a[56] ^ a[51] ^ a[50] ^ a[49],
             a[55] ^ a[50] ^ a[49] ^ a[48],
             a[54] ^ a[49] ^ a[48] ^ a[47],
             a[53] ^ a[48] ^ a[47] ^ a[46],
             a[52] ^ a[47] ^ a[46] ^ a[45],
             a[51] ^ a[46] ^ a[45] ^ a[44],
             a[50] ^ a[45] ^ a[44] ^ a[43],
             a[49] ^ a[44] ^ a[43] ^ a[42],
             a[48] ^ a[43] ^ a[42] ^ a[41],
             a[47] ^ a[42] ^ a[41] ^ a[40],
             a[46] ^ a[41] ^ a[40] ^ a[39],
             a[45] ^ a[40] ^ a[39] ^ a[38],
             a[44] ^ a[39] ^ a[38] ^ a[37],
             a[43] ^ a[38] ^ a[37] ^ a[36],
             a[42] ^ a[37] ^ a[36] ^ a[35],
             a[41] ^ a[36] ^ a[35] ^ a[34],
             a[40] ^ a[35] ^ a[34] ^ a[33],
             a[39] ^ a[34] ^ a[33] ^ a[32],
             a[38] ^ a[33] ^ a[32] ^ a[31],
             a[37] ^ a[32] ^ a[31] ^ a[30],
             a[36] ^ a[31] ^ a[30] ^ a[29],
             a[35] ^ a[30] ^ a[29] ^ a[28],
             a[34] ^ a[29] ^ a[28] ^ a[27],
             a[33] ^ a[28] ^ a[27] ^ a[26],
             a[32] ^ a[27] ^ a[26] ^ a[25],
             a[31] ^ a[26] ^ a[25] ^ a[24],
             a[30] ^ a[25] ^ a[24] ^ a[23],
             a[29] ^ a[24] ^ a[23] ^ a[22],
             a[28] ^ a[23] ^ a[22] ^ a[21],
             a[27] ^ a[22] ^ a[21] ^ a[20],
             a[26] ^ a[21] ^ a[20] ^ a[19],
             a[25] ^ a[20] ^ a[19] ^ a[18],
             a[24] ^ a[19] ^ a[18] ^ a[17],
             a[23] ^ a[18] ^ a[17] ^ a[16],
             a[22] ^ a[17] ^ a[16] ^ a[15],
             a[21] ^ a[16] ^ a[15] ^ a[14],
             a[20] ^ a[15] ^ a[14] ^ a[13],
             a[19] ^ a[14] ^ a[13] ^ a[12],
             a[18] ^ a[13] ^ a[12] ^ a[11],
             a[17] ^ a[12] ^ a[11] ^ a[10],
             a[16] ^ a[11] ^ a[10] ^ a[9],
             a[15] ^ a[10] ^ a[9] ^ a[8],
             a[14] ^ a[9] ^ a[8] ^ a[7],
             a[13] ^ a[8] ^ a[7] ^ a[6],
             a[12] ^ a[7] ^ a[6] ^ a[5],
             a[11] ^ a[6] ^ a[5] ^ a[4],
             a[10] ^ a[5] ^ a[4] ^ a[3],
             a[9] ^ a[4] ^ a[3] ^ a[2],
             a[8] ^ a[3] ^ a[2] ^ a[1],
             a[7] ^ a[2] ^ a[1] ^ a[0],
             a[127] ^ a[6] ^ a[1] ^ a[0],
             a[126] ^ a[5] ^ a[0],
             a[125] ^ a[4],
             a[124] ^ a[3],
             a[123] ^ a[2],
             a[122] ^ a[1],
             a[121] ^ a[0],
             a[120],
             a[119],
             a[118],
             a[117],
             a[116],
             a[115],
             a[114],
             a[113],
             a[112],
             a[111],
             a[110],
             a[109],
             a[108],
             a[107],
             a[106],
             a[105],
             a[104],
             a[103],
             a[102],
             a[101],
             a[100],
             a[99],
             a[98],
             a[97],
             a[96],
             a[95],
             a[94],
             a[93],
             a[92],
             a[91],
             a[90],
             a[89],
             a[88],
             a[87],
             a[86],
             a[85],
             a[84],
             a[83],
             a[82],
             a[81],
             a[80],
             a[79],
             a[78],
             a[77],
             a[76],
             a[75],
             a[74],
             a[73],
             a[72],
             a[71],
             a[70],
             a[69],
             a[68],
             a[67],
             a[66],
             a[65],
             a[64]
            };
   endfunction

   function [127:0] P128 (input [127:0] a);
      P128 = {
              a[127] ^ a[6] ^ a[1] ^ a[0],
              a[127] ^ a[126] ^ a[6] ^ a[5] ^ a[1] ^ a[0] ^ a[0],
              a[127] ^ a[126] ^ a[125] ^ a[6] ^ a[5] ^ a[4] ^ a[1] ^ a[0] ^ a[0],
              a[126] ^ a[125] ^ a[124] ^ a[5] ^ a[4] ^ a[3] ^ a[0],
              a[125] ^ a[124] ^ a[123] ^ a[4] ^ a[3] ^ a[2],
              a[124] ^ a[123] ^ a[122] ^ a[3] ^ a[2] ^ a[1],
              a[123] ^ a[122] ^ a[121] ^ a[2] ^ a[1] ^ a[0],
              a[127] ^ a[122] ^ a[121] ^ a[120] ^ a[6] ^ a[1] ^ a[1] ^ a[0] ^ a[0],
              a[126] ^ a[121] ^ a[120] ^ a[119] ^ a[5] ^ a[0] ^ a[0],
              a[125] ^ a[120] ^ a[119] ^ a[118] ^ a[4],
              a[124] ^ a[119] ^ a[118] ^ a[117] ^ a[3],
              a[123] ^ a[118] ^ a[117] ^ a[116] ^ a[2],
              a[122] ^ a[117] ^ a[116] ^ a[115] ^ a[1],
              a[121] ^ a[116] ^ a[115] ^ a[114] ^ a[0],
              a[120] ^ a[115] ^ a[114] ^ a[113],
              a[119] ^ a[114] ^ a[113] ^ a[112],
              a[118] ^ a[113] ^ a[112] ^ a[111],
              a[117] ^ a[112] ^ a[111] ^ a[110],
              a[116] ^ a[111] ^ a[110] ^ a[109],
              a[115] ^ a[110] ^ a[109] ^ a[108],
              a[114] ^ a[109] ^ a[108] ^ a[107],
              a[113] ^ a[108] ^ a[107] ^ a[106],
              a[112] ^ a[107] ^ a[106] ^ a[105],
              a[111] ^ a[106] ^ a[105] ^ a[104],
              a[110] ^ a[105] ^ a[104] ^ a[103],
              a[109] ^ a[104] ^ a[103] ^ a[102],
              a[108] ^ a[103] ^ a[102] ^ a[101],
              a[107] ^ a[102] ^ a[101] ^ a[100],
              a[106] ^ a[101] ^ a[100] ^ a[99],
              a[105] ^ a[100] ^ a[99] ^ a[98],
              a[104] ^ a[99] ^ a[98] ^ a[97],
              a[103] ^ a[98] ^ a[97] ^ a[96],
              a[102] ^ a[97] ^ a[96] ^ a[95],
              a[101] ^ a[96] ^ a[95] ^ a[94],
              a[100] ^ a[95] ^ a[94] ^ a[93],
              a[99] ^ a[94] ^ a[93] ^ a[92],
              a[98] ^ a[93] ^ a[92] ^ a[91],
              a[97] ^ a[92] ^ a[91] ^ a[90],
              a[96] ^ a[91] ^ a[90] ^ a[89],
              a[95] ^ a[90] ^ a[89] ^ a[88],
              a[94] ^ a[89] ^ a[88] ^ a[87],
              a[93] ^ a[88] ^ a[87] ^ a[86],
              a[92] ^ a[87] ^ a[86] ^ a[85],
              a[91] ^ a[86] ^ a[85] ^ a[84],
              a[90] ^ a[85] ^ a[84] ^ a[83],
              a[89] ^ a[84] ^ a[83] ^ a[82],
              a[88] ^ a[83] ^ a[82] ^ a[81],
              a[87] ^ a[82] ^ a[81] ^ a[80],
              a[86] ^ a[81] ^ a[80] ^ a[79],
              a[85] ^ a[80] ^ a[79] ^ a[78],
              a[84] ^ a[79] ^ a[78] ^ a[77],
              a[83] ^ a[78] ^ a[77] ^ a[76],
              a[82] ^ a[77] ^ a[76] ^ a[75],
              a[81] ^ a[76] ^ a[75] ^ a[74],
              a[80] ^ a[75] ^ a[74] ^ a[73],
              a[79] ^ a[74] ^ a[73] ^ a[72],
              a[78] ^ a[73] ^ a[72] ^ a[71],
              a[77] ^ a[72] ^ a[71] ^ a[70],
              a[76] ^ a[71] ^ a[70] ^ a[69],
              a[75] ^ a[70] ^ a[69] ^ a[68],
              a[74] ^ a[69] ^ a[68] ^ a[67],
              a[73] ^ a[68] ^ a[67] ^ a[66],
              a[72] ^ a[67] ^ a[66] ^ a[65],
              a[71] ^ a[66] ^ a[65] ^ a[64],
              a[70] ^ a[65] ^ a[64] ^ a[63],
              a[69] ^ a[64] ^ a[63] ^ a[62],
              a[68] ^ a[63] ^ a[62] ^ a[61],
              a[67] ^ a[62] ^ a[61] ^ a[60],
              a[66] ^ a[61] ^ a[60] ^ a[59],
              a[65] ^ a[60] ^ a[59] ^ a[58],
              a[64] ^ a[59] ^ a[58] ^ a[57],
              a[63] ^ a[58] ^ a[57] ^ a[56],
              a[62] ^ a[57] ^ a[56] ^ a[55],
              a[61] ^ a[56] ^ a[55] ^ a[54],
              a[60] ^ a[55] ^ a[54] ^ a[53],
              a[59] ^ a[54] ^ a[53] ^ a[52],
              a[58] ^ a[53] ^ a[52] ^ a[51],
              a[57] ^ a[52] ^ a[51] ^ a[50],
              a[56] ^ a[51] ^ a[50] ^ a[49],
              a[55] ^ a[50] ^ a[49] ^ a[48],
              a[54] ^ a[49] ^ a[48] ^ a[47],
              a[53] ^ a[48] ^ a[47] ^ a[46],
              a[52] ^ a[47] ^ a[46] ^ a[45],
              a[51] ^ a[46] ^ a[45] ^ a[44],
              a[50] ^ a[45] ^ a[44] ^ a[43],
              a[49] ^ a[44] ^ a[43] ^ a[42],
              a[48] ^ a[43] ^ a[42] ^ a[41],
              a[47] ^ a[42] ^ a[41] ^ a[40],
              a[46] ^ a[41] ^ a[40] ^ a[39],
              a[45] ^ a[40] ^ a[39] ^ a[38],
              a[44] ^ a[39] ^ a[38] ^ a[37],
              a[43] ^ a[38] ^ a[37] ^ a[36],
              a[42] ^ a[37] ^ a[36] ^ a[35],
              a[41] ^ a[36] ^ a[35] ^ a[34],
              a[40] ^ a[35] ^ a[34] ^ a[33],
              a[39] ^ a[34] ^ a[33] ^ a[32],
              a[38] ^ a[33] ^ a[32] ^ a[31],
              a[37] ^ a[32] ^ a[31] ^ a[30],
              a[36] ^ a[31] ^ a[30] ^ a[29],
              a[35] ^ a[30] ^ a[29] ^ a[28],
              a[34] ^ a[29] ^ a[28] ^ a[27],
              a[33] ^ a[28] ^ a[27] ^ a[26],
              a[32] ^ a[27] ^ a[26] ^ a[25],
              a[31] ^ a[26] ^ a[25] ^ a[24],
              a[30] ^ a[25] ^ a[24] ^ a[23],
              a[29] ^ a[24] ^ a[23] ^ a[22],
              a[28] ^ a[23] ^ a[22] ^ a[21],
              a[27] ^ a[22] ^ a[21] ^ a[20],
              a[26] ^ a[21] ^ a[20] ^ a[19],
              a[25] ^ a[20] ^ a[19] ^ a[18],
              a[24] ^ a[19] ^ a[18] ^ a[17],
              a[23] ^ a[18] ^ a[17] ^ a[16],
              a[22] ^ a[17] ^ a[16] ^ a[15],
              a[21] ^ a[16] ^ a[15] ^ a[14],
              a[20] ^ a[15] ^ a[14] ^ a[13],
              a[19] ^ a[14] ^ a[13] ^ a[12],
              a[18] ^ a[13] ^ a[12] ^ a[11],
              a[17] ^ a[12] ^ a[11] ^ a[10],
              a[16] ^ a[11] ^ a[10] ^ a[9],
              a[15] ^ a[10] ^ a[9] ^ a[8],
              a[14] ^ a[9] ^ a[8] ^ a[7],
              a[13] ^ a[8] ^ a[7] ^ a[6],
              a[12] ^ a[7] ^ a[6] ^ a[5],
              a[11] ^ a[6] ^ a[5] ^ a[4],
              a[10] ^ a[5] ^ a[4] ^ a[3],
              a[9] ^ a[4] ^ a[3] ^ a[2],
              a[8] ^ a[3] ^ a[2] ^ a[1],
              a[7] ^ a[2] ^ a[1] ^ a[0]
             };
   endfunction

endmodule
