Index: gcm_aes_core_1gctr.v
===================================================================
--- gcm_aes_core_1gctr.v	(revision 9325)
+++ gcm_aes_core_1gctr.v	(working copy)
@@ -35,7 +35,7 @@
     output  wire                                        o_sop ,
     output  wire                                        o_valid_text ,
     output  wire    [NB_BLOCK-1:0]                      o_tag ,
-    output  wire                                        o_tag_ready ,
+    output  reg                                         o_tag_ready ,
     output  wire                                        o_fault_sop_and_keyupdate ,
     input   wire    [NB_DATA-1:0]                       i_plaintext_words_x ,       // Plaintext words
     input   wire    [NB_BLOCK-1:0]                      i_tag ,
@@ -123,7 +123,7 @@
     reg             [NB_BLOCK*(N_ROUNDS+1)-1:0]         round_key_vector_locked ;
     wire            [NB_BLOCK-1:0]                      j0 ;
     wire            [NB_BLOCK-1:0]                      initial_counter_block ;
-    wire            [NB_BLOCK-1:0]                      hash_subkey_h ;
+ // wire            [NB_BLOCK-1:0]                      hash_subkey_h ;
     reg             [NB_BLOCK-1:0]                      hash_subkey_h_new ;
     reg             [NB_BLOCK-1:0]                      hash_subkey_h_new_d ;
     wire            [NB_BLOCK-1:0]                      hash_subkey_h_locked ;
@@ -152,7 +152,7 @@
     wire                                                valid_ghash_length ;
     wire                                                valid_ghash_data ;
     wire                                                valid_ghash_data_d ;
-    wire            [NB_BLOCK-1:0]                      j0_tag ;
+ // wire            [NB_BLOCK-1:0]                      j0_tag ;
     reg             [NB_BLOCK-1:0]                      ghash_ciphertext_locked ;
     reg             [NB_BLOCK-1:0]                      j0_tag_new ;
     reg                                                 sop_o_x ;
@@ -642,5 +642,14 @@
     end // l_fail_flag
 
 
+    always @( posedge i_clock )
+    begin : l_tag_ready_update
+        if ( i_reset )
+            o_tag_ready
+                <= 1'b0 ;
+        else if ( i_valid )
+            o_tag_ready
+                <= valid_tag ;
+    end // l_tag_ready_update
 
 endmodule // aes_round_ladder
