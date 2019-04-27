`timescale 1 ns / 1 ps
//
// Copyright (c) 2016 by IP Cores, Inc.   All rights reserved.  This text
// contains proprietary, confidential information of IP Cores, Inc.,  and
// may be used, copied,  and/or disclosed only pursuant to the terms of a
// valid license agreement with IP Cores, Inc. This copyright notice must
// be retained as part of this text at all times.
//
// Rev. 1.0
// Rev. 1.01 - fixed simulation compatibility issue
// Rev. 2.0 - added GMAC mode per customer request
//

`define CE_ALWAYS

module GCM3LP_256stest ();

   parameter MAXTEXT = 65536;   // Max number of input data words
   parameter MAXHDR = 9;

   integer r_seed;
   reg [31:0] randd;

   reg NoMoreVectors;

   reg clk, cen, reset;

   reg TestVectorOpened;

   reg  run, stoped;

   reg  start;
   reg  next;
   reg  last;

   wire start_in;
   wire last_in;

   reg [256*14-1:0] ibuf;

   reg [255:0] K  ;          // Encryption Key from Test Vector File
   reg [255:0] D  ;          // Plain Text from Test Vector File
   reg [255:0] Q  ;          // Cipher Text from Test Vector File
   reg [ 95:0] IV ;          // IV from Test Vector File

   reg       encrypt;
   reg       gmac;
   reg [127:0] Tag;

   reg  write;
   wire Qstart;
   wire Qlast;
   wire Tstrobe;

   reg [255:0] DataIn  [0:MAXTEXT-1]; // Input data buffer
   reg [255:0] DataRef [0:MAXTEXT-1]; // Reference data buffer
   reg [127:0] TagRef  [0:MAXTEXT-1]; // Reference Tag buffer

   reg [255:0] KeyIn1  [0:MAXTEXT-1]; // Input Key1  buffer
   reg [ 95:0] IVIn    [0:MAXTEXT-1]; // Input IV  buffer
   reg [0:MAXTEXT-1] startIn;         // Input start buffer
   reg [0:MAXTEXT-1] lastIn;          // Input last  buffer

   wire [255:0] GCMin;        // Input Data for GCM3LP
   wire [255:0] GCMout;       // Output Data from GCM3LP
   wire [127:0] TagOut;       // Output Tag  from GCM3LP
   wire [255:0] KEY1in;        // Input Key for GCM3LP
   wire [ 95:0] IV_in;        // Input IV  for GCM3LP

   reg  [127:0] Tag_ref;
// wire [127:0] Tag_ref;
   wire [255:0] Q_ref;

   reg [128*8-1:0] s;        // Input string
   reg [MAXHDR*8-1:0] shdr;  // Input string header
   reg [128*8-1:0] sbody;    // Input string body
   reg [128*8-1:0]     TestFileName;
   reg [128*8-1:0]     bline;

   integer iD;           // D and Q input vector  indexes
   integer iQ;           // D and Q input vector  indexes
   integer iDin;         // DataIn index
   integer iQout;    // DataRef index

   integer slen;             // Input string length
   integer TestList;         // List of Test Vector Files Handle
   integer TestVector;       // Test Vector File Handle
   integer TestVector1;      // Test Vector File Handle
   integer Results;          // Results File Handle
   integer TestLog;          // Log File Handle
   reg newVec;                  // New vector obtained
   integer failed;           // number of vectors failed
   integer errors;           // number of errors in single vector
   integer unused;

   wire errorT;


   initial begin   // Main sequence ============================================================

   $display("START");
   Results    = $fopen("testout.txt");
   TestLog    = $fopen("TestLog.txt");
   TestList   = $fopen("TestList.txt","r" );

   NoMoreVectors = 0;

   r_seed = 16;

   clk = 1;
   reset = 1;

   cen = 1;

   slen = 0;

   TestVectorOpened = 0;

   failed = 0;

   newVec = 0;
   run = 0;
   stoped = 1;
   iDin = 0;

   #1 reset = 0;

   GEtNewVector;


   end    // End of main sequence ============================================================

   GCM3LP_256 gcm1 (
      .clk      ( clk                                             ),
      .cen      ( cen                                             ),
      .reset    ( reset                                           ),
      .encrypt  ( encrypt                                         ),
      .gmac     ( gmac                                            ),
      .start    ( start_in                                        ),
      .last     ( last_in                                         ),
//    .D        ( GCMin                                           ),
      .D        ( ibuf[256*14-1:256*13]                           ),
      .IV       ( start_in ? IV_in  : {96{1'bx}}                  ),
      .Key      ( start_in ? KEY1in : {256{1'bx}}                  ),
      .Qstart   ( Qstart                                          ),
      .Qlast    ( Qlast                                           ),
      .Q        ( GCMout                                          ),
      .Tstrobe  ( Tstrobe                                         ),
      .T        ( TagOut                                          )
   );

   assign GCMin    = (iDin >= iD ) ? 128'h0          :  DataIn  [ iDin ];
   assign KEY1in   = (iDin >= iD ) ? KeyIn1 [ iD-1 ] :  KeyIn1  [ iDin ];
   assign IV_in    = (iDin >= iD ) ?  96'h0          :  IVIn    [ iDin ];
   assign start_in = (iDin >= iD ) ?   1'h0          :  startIn [ iDin ] & run;
   assign last_in  = (iDin >= iD ) ?   1'h0          :  lastIn  [ iDin ] | ( iDin == iD );

// assign Tag_ref  = TagRef  [ iQout ];
   assign Q_ref    = DataRef [ iQout ];

   always #5 clk <= ~clk;                      // Clock generation

   `ifdef CE_ALWAYS                            // Clock Enable generation
       always @(posedge clk) cen <= 1;
   `else
       always @(posedge clk) begin
          randd <= $random(r_seed);
          cen <= |randd[2:0];
       end
   `endif

   always @(posedge clk) begin
      if (!newVec) #1 run <= 0;
      else if (cen) begin
           stoped <= ! run;
           if (stoped) #1 run <= newVec;
      end
   end

   always @(posedge clk) begin
      if (!run) begin
         iDin   <= 0;
         iQout  <= 0;
         errors <= 0;
         write  <= 0;

         ibuf <= { (256*14) {1'b0}};


         if (!newVec) #1 GEtNewVector;

      end
      else if (cen) begin

         ibuf <= { ibuf[256*13-1:0], GCMin };


         if      ( Qstart ) write <= 1'b1;
         else if ( Qlast  ) write <= 1'b0;

         iDin  <= iDin + 1;

         if ( write | Qstart ) begin
            if ( Qlast ) begin

               Tag_ref  <= TagRef  [ iQout ];

               $fdisplay(Results,"   Ref Q =%h", Q_ref  );
               $fdisplay(Results,"GCM3LP Q =%h", GCMout );

               if (GCMout !== Q_ref ) begin
                  $fdisplay(Results,"Failed !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
                  errors <= errors + 1;
               end

            end
            else begin
               $fdisplay(Results,"   Ref Q =%h", Q_ref  );
               $fdisplay(Results,"GCM3LP Q =%h", GCMout );

               if (GCMout !== Q_ref ) begin
                  $fdisplay(Results,"Failed !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
                  errors <= errors + 1;
               end
            end

            iQout <= iQout + 1;

         end

         if ( Tstrobe ) begin
            $fdisplay(Results,"   Ref T =%h", Tag_ref  );
            $fdisplay(Results,"GCM3LP T =%h", TagOut );

            if (TagOut !== Tag_ref ) begin
               $fdisplay(Results,"Failed !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
               errors <= errors + 1;
            end
         end

         if ( iQout >= iQ  ) begin

            if ( (errors > 0) || errorT ) begin
                 failed <= failed + 1;
                 $fdisplay(Results,"Vector Failed with %d errors\n", errors + errorT );
                 $display (        "Vector Failed with %d errors\n", errors + errorT );
                 $fwrite(TestLog,"%0s): !!!!!!!!!!!!!!!! Failed with %d errors\n", bline, errors + errorT );
            end
            else $fwrite(TestLog,"%0s): Passed\n", bline );

            errors <= 0;
            newVec <= 0;
            run <= 0;
         end
      end
   end

   assign errorT = Tstrobe && (TagOut !== Tag_ref );

//=======================================

task GEtNewVector;   // Get new vector from vector file

begin

   while (!newVec & ~NoMoreVectors ) begin

        if ( TestVectorOpened ) slen = $fgets(s, TestVector);                     // get new line
        else slen = 0;

        if (!slen) begin

             if ( TestVectorOpened ) $fclose ( TestVector );

             slen = $fgets(s, TestList);                     // get new file name

             if (!slen) begin
                  NoMoreVectors = 1;
                  newVec = 0;
                  $display("No more vectors");

                  if ( failed || errors ) $display("%d Test failed", (failed + (errors? 1 : 0 )));
                  else                    $display("Test passed");

                  $fclose ( Results );
                  $fclose ( TestList );
                  $fclose ( TestLog );
                  $fclose ( TestVector );

                  $stop;
             end
             else begin

                unused = $sscanf(s, "%s", TestFileName);

                while (s[1023:1016] == 8'h00) s = s << 8;

                if ( s[1023:1016] != "#" ) begin

                   while ((s[1023:1016] != 8'h00) && (s[1023:1016] != " ") ) s = s << 8;

                   TestVector = $fopen( TestFileName ,"r" );

                   TestVectorOpened = 1;
                   $write (         "Opened %0s %0s", TestFileName, s );
                   $fwrite(Results, "Opened %0s %0s", TestFileName, s );  // and output

                end
                else begin
                   TestVectorOpened = 0;
                   slen = 0;
                   $write (         "Skipped %0s", s);
                   $fwrite(Results, "Skipped %0s", s);  // and output
                end
             end

        end
        else begin


           while (s[1023:1016] == 8'h00) s = s << 8;

           shdr = s[1023:1024 - MAXHDR*8];      // select 7 letter header

           if      (isHeader(shdr, "begin____", 5)) begin

              $write (         "%0s", s);  // Copy "begin" line to console
              $fwrite(Results, "%0s", s);  // and output

              bline = TestFileName;
              bline = { bline[1007:0],  " (" };

              s =  s << (5 * 8);
              while((s[1023:1016] != 8'h0a) && (s[1023:1016] != 8'h00) ) begin
                 bline = { bline[1015:0],  s[1023:1016] };
                 s =  s << 8;
              end

              iD = 0;
              iQ = 0;
              start = 1'b0;
              last  = 1'b0;
              encrypt = 1'b1;
              gmac  = 1'b0;

           end
           else if (isHeader(shdr, "start____", 5)) begin
              start = 1'b1;
           end
           else if (isHeader(shdr, "last_____", 4)) begin
              last = 1'b1;
           end
           else if (isHeader(shdr, "enc______", 3)) begin
              encrypt = 1'b1;
           end
           else if (isHeader(shdr, "dec______", 3)) begin
              encrypt = 1'b0;
           end
           else if (isHeader(shdr, "gmac=____", 5)) begin
                 s =  s << (5 * 8);
                 unused = $sscanf(s, "%b", gmac);
           end
           else if (isHeader(shdr, "T=_______", 2)) begin
                 s =  s << (2 * 8);
                 unused = $sscanf(s, "%h", Tag );
           end
           else if (isHeader(shdr, "K256=____", 5)) begin
                 s =  s << (5 * 8);
                 unused = $sscanf(s, "%h", K);       // copy KEY from vector to K
           end
           else if (isHeader(shdr, "IV=______", 3)) begin
                 s =  s << (3 * 8);
                 unused = $sscanf(s, "%h", IV);       // copy IV from vector to IV
           end
           else if (isHeader(shdr, "D=_______", 2)) begin
                 s =  s << (2 * 8);
                 unused = $sscanf(s, "%h", D);
                 DataIn  [iD] = D;
                 KeyIn1  [iD] = K;
                 IVIn    [iD] = IV;

                 startIn [iD] = start;
                 start = 1'b0;

                 lastIn  [iD] = last;
                 last  = 1'b0;

                 iD = iD + 1;
                 if ( iD > MAXTEXT ) begin
                    $display ("Vector too big, more than %d", MAXTEXT );
                    $fclose ( Results );
                    $fclose ( TestLog );
                    $fclose ( TestVector );
                    $fclose ( TestList );
                    $stop;
                 end
           end

           else if (isHeader(shdr, "Q=_______", 2)) begin
                 s =  s << (2 * 8);
                 unused = $sscanf(s, "%h", Q);
                 DataRef [iQ] = Q;
                 TagRef  [iQ] = Tag;

                 iQ = iQ + 1;
                 if ( iQ > MAXTEXT ) begin
                    $display ("Vector too big, more than %d", MAXTEXT );
                    $fclose ( Results );
                    $fclose ( TestLog );
                    $fclose ( TestVector );
                    $fclose ( TestList );
                    $stop;
                 end
           end

           else if (isHeader(shdr, "end______", 3)) begin
              newVec = 1;
           end
           else if (slen > 1) begin
              $fwrite(Results, "%0s", s);  // copy comments to console and output
           end
        end
   end
end
endtask

function isHeader(input [MAXHDR*8-1:0] hdr, ref, input integer size);

    isHeader = ~|((hdr ^ ref) >> (MAXHDR - size)*8 );

endfunction

endmodule
