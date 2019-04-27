Index: ghash_n_blocks.v
===================================================================
--- ghash_n_blocks.v	(revision 9325)
+++ ghash_n_blocks.v	(working copy)
@@ -143,7 +143,8 @@
 
     // Output assignment.
     assign  o_data_y
-                = data_x_prev_final_d /*data_x_array[ N_BLOCKS - skip_bus_encoded ] */;
+             // = data_x_prev_final_d /*data_x_array[ N_BLOCKS - skip_bus_encoded ] */; // FIXME: Preguntar a Gian para que hizo este cambio.
+                = data_x_array[ N_BLOCKS - skip_bus_encoded ] ;                         // FIXME: Cambio revertido (ver fixme previo).
 
 
 endmodule // ghash_n_blocks
