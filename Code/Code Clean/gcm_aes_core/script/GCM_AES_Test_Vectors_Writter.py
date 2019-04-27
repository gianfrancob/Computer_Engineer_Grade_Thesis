def gcm_aes_algorithm( i_iv, i_key, i_plaintext_len, i_aad_len, i_gmac_mode, i_use_std_vectors ):
    import os
    from cryptography.hazmat.backends import default_backend
    from cryptography.hazmat.primitives.ciphers import ( Cipher, algorithms, modes )

    # Inputs definition logic
    # ==============================================================================================
    iv                  = 0
    key                 = 0
    aad_len             = 0
    aad                 = 0
    plaintext_len       = 0
    plaintext           = 0

    if i_use_std_vectors:
        # IV
        iv_str          = "cafebabefacedbaddecaf888"
        iv              = iv_str.decode("hex")

        # KEY
        key_str         = "feffe9928665731c6d6a8f9467308308feffe9928665731c6d6a8f9467308308"
        key             = key_str.decode("hex")

        # PLAINTEXT
        plaintext_len   = 512
        plaintext_str   = "d9313225f88406e5a55909c5aff5269a"
        plaintext_str  += "86a7a9531534f7da2e4c303d8a318a72"
        plaintext_str  += "1c3c0c95956809532fcf0e2449a6b525"
        plaintext_str  += "b16aedf5aa0de657ba637b391aafd255"
        plaintext       = plaintext_str.decode("hex")

        # AAD
        aad_len         = 0
        aad_str         = ""
        aad             = aad_str.decode("hex")
    else:
        iv              = i_iv

        key             = i_key

        aad_len         = i_aad_len
        aad             = os.urandom(aad_len)

        plaintext_len   = i_plaintext_len
        plaintext       = os.urandom(plaintext_len)

    if i_gmac_mode:
        encryptor = Cipher(
            algorithms.AES(key),
            modes.GCM(iv),
            backend=default_backend()
        ).encryptor()

        # associated_data will be authenticated but not encrypted,
        # it must also be passed in on decryption.
        encryptor.authenticate_additional_data(aad)

        # Encrypt the plaintext and get the associated ciphertext.
        # GCM does not require padding.
        plaintext = encryptor.update(plaintext) + encryptor.finalize()

    # Main GCM AES Execution
    # ==============================================================================================
    encryptor = Cipher(
        algorithms.AES(key),
        modes.GCM(iv),
        backend=default_backend()
    ).encryptor()

    # associated_data will be authenticated but not encrypted,
    # it must also be passed in on decryption.
    encryptor.authenticate_additional_data(aad)

    # Encrypt the plaintext and get the associated ciphertext.
    # GCM does not require padding.
    ciphertext = encryptor.update(plaintext) + encryptor.finalize()

    # Tag
    tag = encryptor.tag

    # Output
    # ==============================================================================================
    return iv, key, aad, plaintext, ciphertext, tag;


def frame_sequence_generator( i_n_frames, i_iv_case, i_pLen_case, i_aLen_case, i_gmac_case, i_key_case, i_keyUp_case, i_sop_case, i_use_std_vectors):
    import os
    iv_const            = 0
    iv_incr             = 1
    iv_rand             = 2

    pLen_const          = 0
    pLen_incr           = 1
    pLen_rand           = 2

    aLen_const          = 0
    aLen_incr           = 1
    aLen_rand           = 2

    gmac_off            = 0
    gmac_on             = 1

    key_conts_std       = 0
    key_const_rand      = 1
    key_change_FrToFr   = 2

    keyUp_single        = 0
    keyUp_consec_OK     = 1
    keyUp_consec_BAD    = 2
    keyUp_consec_OTN    = 3

    sop_period_const    = 0
    sop_period_rand     = 1
    sop_extra_bef_gctr  = 2
    sop_extra_aft_gctr  = 3
    sop_extra_bef_ghash = 4


    iv_cases        = { iv_const        , iv_incr           , iv_rand           }
    pLen_cases      = { pLen_const      , pLen_incr         , pLen_rand         }
    aLen_cases      = { aLen_const      , aLen_incr         , aLen_rand         }
    gmac_cases      = { gmac_off        , gmac_on           }
    key_cases       = { key_conts_std   , key_const_rand    , key_change_FrToFr }
    keyUp_cases     = { keyUp_single    , keyUp_consec_OK   , keyUp_consec_BAD  , keyUp_consec_OTN  }
    sop_cases       = { sop_period_const, sop_period_rand   , sop_extra_bef_gctr, sop_extra_aft_gctr, sop_extra_bef_ghash   }



    for frame in range(0, i_n_frames, 1):
        # IV
        iv_ctr  = 000000000000000000000000
        iv_str  = str(iv_ctr)
        i_iv    = iv_str.decode("hex")

        if      i_iv_case == 0:
            iv_str          = "cafebabefacedbaddecaf888"    # Standart vector
            i_iv            = iv_str.decode("hex")
        elif    i_iv_case == 1:
            iv_ctr  = iv_ctr + 1
            iv_str  = str(iv_ctr)
            i_iv    = iv_str.decode("hex")
        elif    i_iv_case == 2:
            i_iv    = os.urandom(12)
        else
            print "ERROR: Invalid iv_case"
            break;


        i_key               = 
        i_plaintext_len     = 
        i_aad_len           = 
        i_gmac_mode         = 
        i_use_std_vectors   = 

        o_i_iv[frame], o_i_key[frame], o_i_aad[frame], o_i_plaintext[frame], o_o_ciphertext[frame], o_o_tag[frame] = gcm_aes_algorithm( i_iv, i_key, i_plaintext_len, i_aad_len, i_gmac_mode, i_use_std_vectors )
        o_i_gmac[frame] = i_gmac_mode



    print "IV           : " + o_i_iv.encode("hex")
    print "Key          : " + o_i_key.encode("hex")
    print "AAD          : " + o_i_aad.encode("hex")
    print "Plaintext    : " + o_i_plaintext.encode("hex")
    print "Ciphertext   : " + o_o_ciphertext.encode("hex")
    print "Tag          : " + o_o_tag.encode("hex")

    return;


import os
import argparse
import math

parser  = argparse.ArgumentParser(fromfile_prefix_chars='@')
parser.add_argument("-frames"      , help="specifies how many frames will be generated", default=1)
args    = parser.parse_args()

frames              = int(args.frames)
log2_frames         = frames.bit_length()

iv_const            = 0
iv_incr             = 1
iv_rand             = 2

pLen_const          = 0
pLen_incr           = 1
pLen_rand           = 2

aLen_const          = 0
aLen_incr           = 1
aLen_rand           = 2

gmac_off            = 0
gmac_on             = 1

key_conts_std       = 0
key_const_rand      = 1
key_change_FrToFr   = 2

keyUp_single        = 0
keyUp_consec_OK     = 1
keyUp_consec_BAD    = 2
keyUp_consec_OTN    = 3

sop_period_const    = 0
sop_period_rand     = 1
sop_extra_bef_gctr  = 2
sop_extra_aft_gctr  = 3
sop_extra_bef_ghash = 4

valid_const_OK      = 0
valid_rand_OK       = 1
valid_const_BAD     = 2
valid_rand_BAD      = 3


iv_cases        = { iv_const        , iv_incr           , iv_rand           }
pLen_cases      = { pLen_const      , pLen_incr         , pLen_rand         }
aLen_cases      = { aLen_const      , aLen_incr         , aLen_rand         }
gmac_cases      = { gmac_off        , gmac_on           }
key_cases       = { key_conts_std   , key_const_rand    , key_change_FrToFr }
keyUp_cases     = { keyUp_single    , keyUp_consec_OK   , keyUp_consec_BAD  , keyUp_consec_OTN  }
sop_cases       = { sop_period_const, sop_period_rand   , sop_extra_bef_gctr, sop_extra_aft_gctr, sop_extra_bef_ghash   }
valid_cases     = { valid_const_OK  , valid_rand_OK     , valid_const_BAD   , valid_rand_BAD    }


f = open('gcm_aes_test_vectors.v', 'w')

f.close()





# # CODE WRITTING BEGIN:
# # =============================================================================================================
# f.write( "module gcm_aes_test_vector" )
# f.write( "\n#(" )
# f.write( "\n     //PARAMETERS." )
# f.write( "\n     parameter       NB_BLOCK      =   128                      ," )
# f.write( "\n     parameter       N_BLOCKS      =   2                        ," )
# f.write( "\n     parameter       NB_DATA       =   N_BLOCKS*NB_BLOCK        ," )
# f.write( "\n     parameter       NB_CLK_CTR    =   10                       ," )
# f.write( "\n     parameter       LOG2_FRAMES   =   %d" %   log2_frames )
# f.write( "\n)" )
# f.write( "\n(" )
# f.write( "\n     // OUTPUTS." )
# f.write( "\n     output  wire    [ NB_DATA-1:0       ]       o_key          ," )
# f.write( "\n     output  wire    [ NB_BLOCK-1:0      ]       o_iv           ," )
# f.write( "\n     output  wire    [ NB_DATA-1:0       ]       o_aad          ," )
# f.write( "\n     output  wire    [ NB_DATA-1:0       ]       o_plaintext    ," )
# f.write( "\n     output  wire    [ NB_DATA-1:0       ]       o_reset    ," )
# f.write( "\n     output  wire    [ NB_DATA-1:0       ]       o_ciphertext   ," )
# f.write( "\n     output  wire    [ NB_BLOCK-1:0      ]       o_tag          ," )
# f.write( "\n     // INPUTS." )
# f.write( "\n     input   wire    [ NB_CLK_CTR-1:0    ]       i_clk_ctr      ," )
# f.write( "\n     input   wire    [ LOG2_FRAMES-1:0   ]       i_frame_ctr" )
# f.write( "\n);" )
# f.write( "\n" )

#     output  wire    [ NB_DATA-1:0       ]               o_o_ciphertext                    ,
#     output  wire                                        o_o_fail                          ,
#     output  wire                                        o_o_sop                           ,
#     output  wire                                        o_o_valid                         ,
#     output  wire    [ NB_BLOCK-1:0      ]               o_o_tag                           ,
#     output  wire                                        o_o_tag_ready                     ,
#     output  wire                                        o_o_fault_sop_and_keyupdate       ,   // FIXME: Rename. Check other possible pathologically timed input controls.
#     input   wire    [ NB_DATA-1:0       ]               o_i_plaintext                     ,   // Plaintext words
#     input   wire    [ NB_BLOCK-1:0      ]               o_i_tag                           ,
#     input   wire                                        o_i_tag_ready                     ,
#     input   wire    [ NB_KEY-1:0        ]               o_i_rf_static_key                 ,   // [HINT]: This is semy static. FIXME. Renombrar y resintetizar
#     input   wire    [ NB_DATA-1:0       ]               o_i_rf_static_aad                 ,   // [HINT]: This is semy static. FIXME. Renombrar y resintetizar
#     input   wire    [ NB_IV-1:0         ]               o_i_rf_static_iv                  ,   // [HINT]: This is semy static. FIXME. Renombrar y resintetizar
#     input   wire    [ NB_BLOCK/2-1:0    ]               o_i_rf_static_length_aad          ,   // [HINT]: This is semy static. FIXME. Renombrar y resintetizar
#     input   wire    [ NB_BLOCK/2-1:0    ]               o_i_rf_static_length_plaintext    ,   // [HINT]: This is semy static. FIXME. Renombrar y resintetizar
#     input   wire                                        o_i_sop                           ,   // Start of plaintext
#     input   wire                                        o_i_valid                         ,
#     input   wire                                        o_i_enable                        ,
#     input   wire                                        o_i_update_key                    ,   // [NOTE] This signal can be double flop synced outside before used.
#     input   wire    [ NB_INC_MODE-1:0   ]               o_i_rf_static_inc_mode            ,   // [FIXME] Revisar si el modo MAC-SEC requiere algo de esto. Si no, eliminar esta entrada.
#     input   wire                                        o_i_rf_mode_gmac                  ,
#     input   wire                                        o_i_rf_static_encrypt             ,
#     input   wire                                        o_i_clear_fault_flags             ,
#     input   wire                                        o_i_reset                         ,

# f.write( "\n// LOCALPARAMETERS." )
# f.write( "\n// ----------------------------------------------------------------------------------------------------" )
# f.write( "\n// none so far" )
# f.write( "\n" )

# f.write( "\n// INTERNAL SIGNALS." )
# f.write( "\n// ----------------------------------------------------------------------------------------------------" )
# f.write( "\nwire     [ NB_BLOCK-1:0  ]           key         [ LOG2_FRAMES-1:0 ] ;" )
# f.write( "\nwire     [ NB_BLOCK-1:0  ]           iv          [ LOG2_FRAMES-1:0 ] ;" )
# f.write( "\nwire     [ NB_BLOCK-1:0  ]           aad         [ LOG2_FRAMES-1:0 ] ;" )
# f.write( "\nwire     [ NB_BLOCK-1:0  ]           plaintext   [ LOG2_FRAMES-1:0 ] ;" )
# f.write( "\nwire     [ NB_BLOCK-1:0  ]           ciphertext  [ LOG2_FRAMES-1:0 ] ;" )
# f.write( "\nwire     [ NB_BLOCK-1:0  ]           tag         [ LOG2_FRAMES-1:0 ] ;" )
# f.write( "\n" )

# key_str = "feffe9928665731c6d6a8f9467308308feffe9928665731c6d6a8f9467308308"  # Standart key
# key     = key_str.decode("hex")

# for frame in range(frames):
#     # GCM AES ALGORITHM
#     # ==============================================================================================================
#     iv                  = os.urandom(12)

#     update_key          = (frame%10 == 0) & (frame != 0)
#     if update_key:
#         key             = os.urandom(32)

#     associated_data     = os.urandom(32)

#     ptext_lenght        = frame*16

#     plaintext           = os.urandom(ptext_lenght)

#     encryptor = Cipher(
#         algorithms.AES(key),
#         modes.GCM(iv),
#         backend=default_backend()
#     ).encryptor()

#     # associated_data will be authenticated but not encrypted,
#     # it must also be passed in on decryption.
#     encryptor.authenticate_additional_data(associated_data)

#     # Encrypt the plaintext and get the associated ciphertext.
#     # GCM does not require padding.
#     ciphertext = encryptor.update(plaintext) + encryptor.finalize()

#     # FILE WRITTING CONTINUATION
#     # ==============================================================================================================
#     f.write( "\n// FRAME No. " + str(frame) )
#     f.write( "\n// ===================================================================================================" )

#     f.write(     "\nassign   key[%d]             =   256'h%s;"   % ( frame, key[0:32].encode("hex") ) )

#     f.write(     "\nassign   iv[%d]              =   96'h%s;"    % ( frame, iv[0:12].encode("hex") ) )

#     for i in range(0, len(associated_data)/32, 1):
#         f.write( "\nassign   aad[%d][%d]          =   256'h%s;"  % ( frame, i, associated_data[i*32:(i+1)*32].encode("hex") ) )

#     for i in range(0, ptext_lenght/16, 1):
#         f.write( "\nassign   plaintext[%d][%d]    =   128'h%s;"  % ( frame, i, plaintext[i*16:(i+1)*16].encode("hex") ) )

#     for i in range(0, ptext_lenght/16, 1):
#         f.write( "\nassign   ciphertext[%d][%d]   =   128'h%s;"  % ( frame, i, ciphertext[i*16:(i+1)*16].encode("hex") ) )

#     f.write(     "\nassign   tag[%d]             =   128'h%s;"   % ( frame, encryptor.tag[0:16].encode("hex") ) )

#     f.write( "\n" )
#     f.write( "\n" )

# f.write( "\nassign   o_key          = key[i_frame_ctr]                      ;" )
# f.write( "\nassign   o_iv           = iv[i_frame_ctr]                       ;" )
# f.write( "\nassign   o_aad          = aad[i_frame_ctr][i_clk_ctr]           ;" )
# f.write( "\nassign   o_plaintext    = plaintext[i_frame_ctr][i_clk_ctr]     ;" )
# f.write( "\nassign   o_ciphertext   = ciphertext[i_frame_ctr][i_clk_ctr]    ;" )
# f.write( "\nassign   o_tag          = tag[i_frame_ctr]                      ;" )

# f.write( "\n" )
# f.write( "\nendmodule    //gcm_aes_test_vector" )

# f.close()
























# iv_str  = "cafebabefacedbaddecaf888"
# # iv_str  = "012345670123456789abcdef"
# iv      = iv_str.decode("hex")
# f.write( "\nlen(iv) = " +  str(len(iv)) + " -> 'd" + str(len(iv)*8)
# key_str = "feffe9928665731c6d6a8f9467308308feffe9928665731c6d6a8f9467308308"  # Standart key
# # key_str =   "88889999aaaabbbbccccddddeeeeffff88889999aaaabbbbccccddddeeeeffff"
# key = key_str.decode("hex")
# f.write( "\nlen(key) = " +  str(len(key)) + " -> 'd" + str(len(key)*8)
# associated_data_str  = ""
# associated_data_str  = "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
# associated_data_str += "00000000000000000000000000000000"
# associated_data_str += "00000000000000000000000000000000"
# associated_data_str += "00000000000000000000000000000000"
# associated_data_str += "00000000000000000000000000000000"
# associated_data_str += "00000000000000000000000000000000"

# # associated_data_str = "00000000000000001111111111111111222222222222222233333333333333334444444444444444555555555555555566666666666666667777777777777777"
# # associated_data_str   = "11111111111111112222222222222222333333333333333344444444444444440000000000000000000000000000000000000000000000000000000000000000"

# # associated_data_str =  "1111111111111111222222222222222233333333333333334444444444444444"
# # associated_data_str+=  "5555555555555555666666666666666677777777777777778888888888888888"

# # associated_data_str +=  "0000000000000000000000000000000000000000000000000000000000000000"
# # associated_data_str     = "11111111111111112222222222222222333333333333333344444444444444440000000000000000000000000000000000000000000000000000000000000000"
# # associated_data_str = ""
# associated_data      = associated_data_str.decode("hex")
# f.write( "\nlen(associated_data) = " +  str(len(associated_data)) + " -> 'd" + str(len(associated_data)*8)

# plaintext_str        = "d9313225f88406e5a55909c5aff5269a86a7a9531534f7da2e4c303d8a318a721c3c0c95956809532fcf0e2449a6b525b16aedf5aa0de657ba637b391aafd255"
# plaintext_str       += "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
# plaintext_str       += "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
# plaintext_str       += "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
# plaintext_str       += "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
# plaintext_str       += "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
# plaintext_str       += "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
# # plaintext_str       += "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
# # plaintext_str       += "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
# # plaintext_str     += "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc"
# # plaintext_str     +=                                                                 "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc"

# # plaintext_str     = ""

# plaintext            = plaintext_str.decode("hex")

# gmac = 0

# if ( bool(gmac) ):
#     # Construct an AES-GCM Cipher object with the given key and a
#     # randomly generated IV.

#     encryptor = Cipher(
#         algorithms.AES(key),
#         modes.GCM(iv),
#         backend=default_backend()
#     ).encryptor()

#     # associated_data will be authenticated but not encrypted,
#     # it must also be passed in on decryption.
#     encryptor.authenticate_additional_data(associated_data)

#     # Encrypt the plaintext and get the associated ciphertext.
#     # GCM does not require padding.
#     plaintext = encryptor.update(plaintext) + encryptor.finalize()


# f.write( "\nlen(plaintext) = " +  str(len(plaintext)) + " -> 'd" + str(len(plaintext)*8)

# for x in range(int(args.vectors)):
#     # iv                 = os.urandom(12)
#     # key                = os.urandom(32)
#     # associated_data    = os.urandom(64)
#     # plaintext          = os.urandom(int(args.ptext_lenght))
#     n_word = int(args.ptext_lenght) / 32

#     encryptor = Cipher(
#         algorithms.AES(key),
#         modes.GCM(iv),
#         backend=default_backend()
#     ).encryptor()

#     # associated_data will be authenticated but not encrypted,
#     # it must also be passed in on decryption.
#     encryptor.authenticate_additional_data(associated_data)

#     # Encrypt the plaintext and get the associated ciphertext.
#     # GCM does not require padding.
#     ciphertext = encryptor.update(plaintext) + encryptor.finalize()

#     f.write( "\n########  Vector " + str(x) + " ########"
#     if(bool(args.f.write(_test)):

#         for i in range(0, len(key), 8):
#             f.write( "\nsc_key[%d] = 0x%s;" % ((i/8),key[i:i+8].encode("hex"))

#         f.write( "\nsc_iv[1] = 0x%s0000;" % iv[0:4].encode("hex")
#         f.write( "\nsc_iv[0] = 0x%s;" % iv[4:12].encode("hex")

#         for i in range(0, len(associated_data), 8):
#             f.write( "\nsc_aad[%d] = 0x%s;" % (len(associated_data)/8-1-(i/8),associated_data[i:i+8].encode("hex"))

#         for i in range(0, int(args.ptext_lenght), 32):
#             for j in range (3,-1,-1):
#                 f.write( "\nsc_plaintext[%d] = 0x%s;" % (int(args.ptext_lenght)/8-1-(j+4*i/32), plaintext[i+(3-j)*8:i+(3-j+1)*8].encode("hex"))

#         for i in range(0, int(args.ptext_lenght), 32):
#             for j in range (3,-1,-1):
#                 f.write( "\nEXPECT_EQ(data[%d], 0x%s)" % (int(args.ptext_lenght)/8-1-(j+4*i/32), ciphertext[i+(3-j)*8:i+(3-j+1)*8].encode("hex"))

#         for i in range(0, len(encryptor.tag), 8):
#             f.write( "\nEXPECT_EQ(tag[%d] , 0x%s)" % (len(encryptor.tag)/8-1-(i/8),encryptor.tag[i:i+8].encode("hex"))

#     else:
#         f.write( "\nKey: " + key.encode("hex")
#         f.write( "\nIV: " + iv.encode("hex")
#         f.write( "\nAAD: " + associated_data.encode("hex")
#         f.write( "\nPTEXT: " + plaintext.encode("hex")
#         f.write( "\nD: " + ciphertext.encode("hex")
#         f.write( "\nT: " + encryptor.tag.encode("hex")
