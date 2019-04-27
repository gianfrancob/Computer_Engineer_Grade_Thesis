Index: gf_2toN_koa_generated.v
===================================================================
--- gf_2toN_koa_generated.v	(revision 9325)
+++ gf_2toN_koa_generated.v	(working copy)
@@ -364,5 +364,7 @@
     // ) ;
     // wire comp;
     // assign comp = (exp_o_data_z == o_data_z );
+    assign  comp
+                = exp_o_data_z == o_data_z ;
 
 endmodule // gf_2to128_multiplier_booth1
