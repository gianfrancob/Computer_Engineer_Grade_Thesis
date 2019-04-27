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

module GCM3LP_256(
   input               clk,            // Core clock
   input               cen,            // Clock Enable
   input               reset,          // async reset
   input               encrypt,        // Encrypt mode if 1, Decrypt mode if 0
   input               gmac,           // GMAC mode
   input               start,          // First word of the packet
   input               last,           // Last  word of the packet
   input       [255:0] D,              // Input Data
   input        [95:0] IV,             // Init Vector
   input       [255:0] Key,            // AES Encryption Key
   output reg          Qstart,         // First word of the output packet
   output reg          Qlast,          // Last word of the output packet
   output reg  [255:0] Q,              // Output Data
   output reg          Tstrobe,        // T strobe
   output reg  [127:0] T               // GCM Tag
);


   reg [15:0] str;
   reg [16:0] lsr;
   reg [255:0] Kr;
   reg [ 95:0] IVr;
   reg [255:0] dr0;
   reg [255:0] dr1;

   wire [255:0] aesIn;
   wire [255:0] aesOut;

   wire [127:0] Min;
   wire [127:0] Lin;

   wire [127:0] pM;
   wire [127:0] pL;

   reg  [127:0] prM;
   reg  [127:0] prL;

   wire [127:0] pQ;

   reg [127:0] Hr;
   reg [127:0] Hr2;
   reg [127:0] eIV;
   reg [127:0] eIVr;
   reg [255:0] eCNT;

   reg [10:0] Lcnt;

   reg [10:0] cntr;

   assign aesIn = str[0] ? { 128'h0, IVr, 32'h1 } : { IVr, 20'h0, cntr, 1'b0, IVr, 20'h0, cntr, 1'b1 };

   assign Min = (encrypt ? dr1[255:128] ^ eCNT[255:128] : dr1[255:128] ) ^ ( str[15] ? 128'h0 : prM );
   assign Lin = (encrypt ? dr1[127:  0] ^ eCNT[127:  0] : dr1[127:  0] ) ^ ( str[15] ? 128'h0 : prL );

   always @(posedge clk or posedge reset) begin
      if ( reset ) begin
         Kr    <= 256'h0;
         IVr   <=  96'h0;
         dr0   <= 256'h0;
         dr1   <= 256'h0;

         Lcnt  <= 11'h0;
         cntr  <= 11'h0;

         Hr    <= 128'h0;
         Hr2   <= 128'h0;

         eIV   <= 128'h0;
         eIVr  <= 128'h0;
         eCNT  <= 256'h0;
         Q     <= 256'h0;
         prM   <= 128'h0;
         prL   <= 128'h0;
         T     <= 128'h0;
      end
      else if ( cen ) begin

         dr0 <= D;
         dr1 <= dr0;

         prM <= pM;
         prL <= pL;

         if ( start ) begin
            Kr    <= Key;
            IVr   <= IV;
         end

         if     ( |str[1:0] ) cntr <= 11'h1;
         else                 cntr <= cntr + 11'h1;

         if      ( str[15] ) Lcnt <= gmac ? 11'h2 : 11'h0;
         else if (~lsr[15] ) Lcnt <= Lcnt + 11'h1;

         if ( str[14] ) Hr  <= aesOut[255:128];
         if ( str[14] ) Hr2 <= sqr(aesOut[255:128]);

         if ( str[14] ) eIV <= aesOut[127:0];
         if ( lsr[15] ) eIVr<= eIV ^ pL;

         if      ( lsr[15] ) T <= Hr;
         else if ( lsr[16] ) T <= pQ ^ eIVr;

         eCNT <= (|str[15:14] | gmac ) ? 256'h0 : aesOut;

         Q <= dr1 ^ eCNT;
      end
   end

   always @(posedge clk or posedge reset) begin
      if ( reset ) begin
         str     <= 16'h0;
         lsr     <= 17'h0;
         Qstart  <= 1'b0;
         Qlast   <= 1'b0;
         Tstrobe <= 1'b0;
      end
      else if ( cen ) begin
         str <= { str[14:0], start };
         lsr <= { lsr[15:0], last  };
         Qstart <= str[15];
         Qlast  <= lsr[15];
         Tstrobe <= Qlast;
      end
   end

   AES256_256KEpl14 aes1 (
      .clk    ( clk         ),
      .cen    ( cen         ),
      .reset  ( reset       ),
      .Key    ( Kr          ),
      .Din    ( aesIn       ),
      .Dout   ( aesOut      )
   );

   K5gmp128x128 gmM(
      .x      ( Min  ),
      .y      ( Hr2  ),
      .z      ( pM   )
   );

   K5gmp128x128 gmL(
      .x      ( Lin  ),
      .y      ( Hr2  ),
      .z      ( pL   )
   );

   K5gmp128x128 gmQ(
      .x      ( prM ^ ( gmac ? {45'h0,Lcnt, 72'h0 } : { 64'h200, 45'h0, Lcnt, 8'h0 } ) ),
      .y      ( T                                                                      ),
      .z      ( pQ                                                                     )
   );


   function [127:0] sqr (input [127:0] a);

      sqr = {
              a[127] ^ a[63] ^ a[0], a[63] ^ a[2] ^ a[0], a[126] ^ a[63] ^ a[62] ^ a[2] ^ a[0],
              a[62] ^ a[2] ^ a[1], a[125] ^ a[62] ^ a[61] ^ a[1], a[61] ^ a[1] ^ a[0],
              a[124] ^ a[61] ^ a[60] ^ a[0], a[63] ^ a[60] ^ a[0] ^ a[0],
              a[123] ^ a[60] ^ a[59] ^ a[2], a[62] ^ a[59],
              a[122] ^ a[59] ^ a[58] ^ a[1], a[61] ^ a[58], a[121] ^ a[58] ^ a[57] ^ a[0], a[60] ^ a[57],
              a[120] ^ a[57] ^ a[56], a[59] ^ a[56], a[119] ^ a[56] ^ a[55], a[58] ^ a[55],
              a[118] ^ a[55] ^ a[54], a[57] ^ a[54], a[117] ^ a[54] ^ a[53], a[56] ^ a[53],
              a[116] ^ a[53] ^ a[52], a[55] ^ a[52], a[115] ^ a[52] ^ a[51], a[54] ^ a[51],
              a[114] ^ a[51] ^ a[50], a[53] ^ a[50], a[113] ^ a[50] ^ a[49], a[52] ^ a[49],
              a[112] ^ a[49] ^ a[48], a[51] ^ a[48], a[111] ^ a[48] ^ a[47], a[50] ^ a[47],
              a[110] ^ a[47] ^ a[46], a[49] ^ a[46], a[109] ^ a[46] ^ a[45], a[48] ^ a[45],
              a[108] ^ a[45] ^ a[44], a[47] ^ a[44], a[107] ^ a[44] ^ a[43], a[46] ^ a[43],
              a[106] ^ a[43] ^ a[42], a[45] ^ a[42], a[105] ^ a[42] ^ a[41], a[44] ^ a[41],
              a[104] ^ a[41] ^ a[40], a[43] ^ a[40], a[103] ^ a[40] ^ a[39], a[42] ^ a[39],
              a[102] ^ a[39] ^ a[38], a[41] ^ a[38], a[101] ^ a[38] ^ a[37], a[40] ^ a[37],
              a[100] ^ a[37] ^ a[36], a[39] ^ a[36], a[99] ^ a[36] ^ a[35], a[38] ^ a[35],
              a[98] ^ a[35] ^ a[34], a[37] ^ a[34], a[97] ^ a[34] ^ a[33], a[36] ^ a[33],
              a[96] ^ a[33] ^ a[32], a[35] ^ a[32], a[95] ^ a[32] ^ a[31], a[34] ^ a[31],
              a[94] ^ a[31] ^ a[30], a[33] ^ a[30], a[93] ^ a[30] ^ a[29], a[32] ^ a[29],
              a[92] ^ a[29] ^ a[28], a[31] ^ a[28], a[91] ^ a[28] ^ a[27], a[30] ^ a[27],
              a[90] ^ a[27] ^ a[26], a[29] ^ a[26], a[89] ^ a[26] ^ a[25], a[28] ^ a[25],
              a[88] ^ a[25] ^ a[24], a[27] ^ a[24], a[87] ^ a[24] ^ a[23], a[26] ^ a[23],
              a[86] ^ a[23] ^ a[22], a[25] ^ a[22], a[85] ^ a[22] ^ a[21], a[24] ^ a[21],
              a[84] ^ a[21] ^ a[20], a[23] ^ a[20], a[83] ^ a[20] ^ a[19], a[22] ^ a[19],
              a[82] ^ a[19] ^ a[18], a[21] ^ a[18], a[81] ^ a[18] ^ a[17], a[20] ^ a[17],
              a[80] ^ a[17] ^ a[16], a[19] ^ a[16], a[79] ^ a[16] ^ a[15], a[18] ^ a[15],
              a[78] ^ a[15] ^ a[14], a[17] ^ a[14], a[77] ^ a[14] ^ a[13], a[16] ^ a[13],
              a[76] ^ a[13] ^ a[12], a[15] ^ a[12], a[75] ^ a[12] ^ a[11], a[14] ^ a[11],
              a[74] ^ a[11] ^ a[10], a[13] ^ a[10], a[73] ^ a[10] ^ a[9], a[12] ^ a[9],
              a[72] ^ a[9] ^ a[8], a[11] ^ a[8], a[71] ^ a[8] ^ a[7], a[10] ^ a[7],
              a[70] ^ a[7] ^ a[6], a[9] ^ a[6], a[69] ^ a[6] ^ a[5], a[8] ^ a[5],
              a[68] ^ a[5] ^ a[4], a[7] ^ a[4], a[67] ^ a[4] ^ a[3], a[6] ^ a[3],
              a[66] ^ a[3] ^ a[2], a[5] ^ a[2], a[65] ^ a[2] ^ a[1], a[4] ^ a[1],
              a[64] ^ a[1] ^ a[0], a[3] ^ a[0]
             };

   endfunction

endmodule
