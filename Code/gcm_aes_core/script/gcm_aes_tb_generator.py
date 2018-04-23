#!/usr/bin/env python

# IMPORT LIBRARIES
# ==========================================================================================================================
import  os
import  sys
import  math
import  random
from    random                                  import  randint, choice
from    cryptography.hazmat.backends            import  default_backend
from    cryptography.hazmat.primitives.ciphers  import  ( Cipher, algorithms, modes )


# GLOBAL VARIABLES
# ==========================================================================================================================
key_str     = 'feffe9928665731c6d6a8f9467308308feffe9928665731c6d6a8f9467308308'  # Standart Key
key_std     = key_str.decode("hex")

key_str     = 'fafafa928665731c6d6a8f9467308308feffe9928665731c6d6a8f9467308308'  # Standart Key2
key_std2     = key_str.decode("hex")

iv_str      = 'cafebabefacedbaddecaf888'    # Standart IV
iv_std      = iv_str.decode("hex")

debug       = 0

stab_time   = 1
gctr_time   = 45
ghash_time  = 8

x_128       = 'x'*(128/4)
x_256       = 'x'*(256/4)
zero_128    = ('0'*(128/4)).decode("hex")


# CLASS DEFINITION
# ==========================================================================================================================

# Frame Class
# --------------------------------------------------------------------------------------------------------------------------
# This class construct the basic frame. It supports different types of frames.
# --------------------------------------------------------------------------------------------------------------------------
class Frame( object ):
    # Constructor
    # **********************************************************************************************************************
    def __init__(   self                    ,
                    frame_type  = 'random'  ,
                    valid_mode  = 'random'  ,   # Must be setted every time. Posible values = random, pat_low_valid, pat_high_valid, pat_always_valid
                    gmac_mode   = 0         ,   # Must be setted every time. Posible values = 0, 1
                    ptx_len     = 4         ,
                    ptx_mode    = 'random'  ,
                    aad_len     = 2         ,
                    aad_mode    = 'random'  ,
                    iv          = iv_std    ,
                    key_mode    = 'random'  ,
                    key         = key_std   ,
                    new_key     = key_std   ,
                    key_up_mode = 'null'    ,
                    n_key_ups   = 0         ,
                    reset_mode  = 'null'    ,
                    n_resets    = 0         ,
                    sop_mode    = 'single'  ,
                    n_sops      = 1

                ):

        if (1): print ""
        if (1): print "==================================================================================================="
        if (1): print "New Frame instance.Type -> ", frame_type.upper()

        # Initialize variables
        # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        self.frame_type     = frame_type
        self.valid_mode     = ''
        self.gmac_mode      = ''
        self.aad_mode       = ''
        self.aad_len        = 0
        self.aad            = []
        self.ptx_mode       = ''
        self.ptx_len        = 0
        self.plaintext      = []
        self.iv             = []
        self.ciphertext     = []
        self.tag            = []
        self.key            = []
        self.new_key        = []
        self.key_mode       = ''
        self.ku_mode        = ''
        self.n_key_ups      = 0
        self.key_up         = []
        self.sop_mode       = ''
        self.sop            = []
        self.n_sops         = 0
        self.reset_mode     = ''
        self.reset          = []
        self.n_resets       = 0


        # Type Cases
        # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

        # RANDOM CUSTOM SOP MODE
        ########################################################################################
        # This Frame Type has the following characteristics:
        # - SOP Mode        = SINGLE
        # - RESET Mode      = NULL
        # - VALID Mode      = CUSTOM < max_valid, random >
        # - GMAC Mode       = CUSTOM < on, off >
        # - IV              = RANDOM
        # - KEY Mode        = CUSTOM < argument key >
        # - KEY UP Mode     = NULL
        # - N KEY UPs       = NULL
        # - PTX Mode        = RANDOM
        # - PTX Len         = RANDOM
        # - AAD Mode        = RANDOM
        # - PTX Len         = RANDOM
        ########################################################################################
        if ( self.frame_type == 'custom_sop_mode'):
            # SOP
            self.sop_mode       = sop_mode


            # RESET
            self.reset_mode     = 'null'


            # VALID
            self.valid_mode     = valid_mode


            # GMAC
            self.gmac_mode      = gmac_mode


            # IV
            self.iv             = [ os.urandom(12) ]
            print     "IV                       = ", (self.iv[0]).encode("hex")


            # KEY/KEY_UPDATE
            self.key_mode       = key_mode
            if  ( self.key_mode  == 'custom' ):
                self.key            = [ key ]
            elif( self.key_mode  == 'random' ):
                self.key            = [ os.urandom(32) ]
            else:
                sys.error( "ERROR: Invalid key_mode" )
            self.kup_mode       = 'null'
            self.n_key_ups      = 0
            print     "KEY                      = ", (self.key[0]).encode("hex")


            # PLAINTEXT
            self.ptx_len        = randint( 0, 8 )           #random len < 1024
            print     "PLAINTEXT LEN            = ", self.ptx_len
            self.ptx_mode       = 'random'
            # if ( self.ptx_len > 0 ):
            #     for i in range( 0, self.ptx_len ):
            #         (self.plaintext).append( os.urandom(16) )
            #         print "PLAINTEXT    [", i, "]       = ", (self.plaintext[i]).encode("hex")


            # AAD
            msg_limit       = 2**10 - 1 - 1 - self.ptx_len
            # self.aad_len    = randint( 0, msg_limit )     # USE THIS LATER!
            self.aad_len    = randint( 0, 4 )               # AND DELETE THIS
            print     "AAD LEN                  = ", self.aad_len
            self.aad_mode   = 'random'
            if ( self.aad_len > 0):
                for i in range( 0, self.aad_len ):
                    (self.aad).append( os.urandom(32) )
                    print "AAD          [", i, "]       = ", (self.aad[i]).encode("hex")



        # RANDOM
        ########################################################################################
        # This Frame Type has the following characteristics:
        # - SOP Mode        = SINGLE
        # - RESET Mode      = NULL
        # - VALID Mode      = CUSTOM < max_valid, random >
        # - GMAC Mode       = CUSTOM < on, off >
        # - IV              = RANDOM
        # - KEY Mode        = CUSTOM < argument key >
        # - KEY UP Mode     = NULL
        # - N KEY UPs       = NULL
        # - PTX Mode        = RANDOM
        # - PTX Len         = RANDOM
        # - AAD Mode        = RANDOM
        # - PTX Len         = RANDOM
        ########################################################################################
        elif ( self.frame_type == 'random'):
            # SOP
            self.sop_mode       = 'single'


            # RESET
            self.reset_mode     = 'null'


            # VALID
            self.valid_mode     = valid_mode


            # GMAC
            self.gmac_mode      = gmac_mode


            # IV
            self.iv             = [ os.urandom(12) ]
            if (1): print     "IV                       = ", (self.iv[0]).encode("hex")


            # KEY/KEY_UPDATE
            self.key_mode       = key_mode
            if  ( self.key_mode  == 'custom' ):
                self.key            = [ key ]
            elif( self.key_mode  == 'random' ):
                self.key            = [ os.urandom(32) ]
            else:
                sys.error( "ERROR: Invalid key_mode" )
            self.kup_mode       = 'null'
            self.n_key_ups      = 0
            if (1): print     "KEY                      = ", (self.key[0]).encode("hex")


            # PLAINTEXT
            # self.ptx_len        = (choice(range(0, (2**7))))
            self.ptx_len        = randint( 0, 15 )           #random len < 1024
            if (1): print     "PLAINTEXT LEN            = ", self.ptx_len
            self.ptx_mode       = 'random'


            # AAD
            # msg_limit       = 2**10 - 1 - 1 - self.ptx_len
            # self.aad_len    = (choice(range(0, (2**7)))) #randint( 0, msg_limit )     # USE THIS LATER!
            self.aad_len    = randint( 0, 15 )               # AND DELETE THIS
            if (1): print     "AAD LEN                  = ", self.aad_len
            self.aad_mode   = 'random'
            if ( self.aad_len > 0):
                for i in range( 0, self.aad_len ):
                    (self.aad).append( os.urandom(32) )
                    if (1): print "AAD          [", i, "]       = ", (self.aad[i]).encode("hex")


        # N KEY UPDATES
        ########################################################################################
        # This Frame Type has the following characteristics:
        # - SOP Mode        = SINGLE
        # - RESET Mode      = NULL
        # - VALID Mode      = CUSTOM < max_valid, random >
        # - GMAC Mode       = CUSTOM < on, off >
        # - IV              = RANDOM
        # - KEY Mode        = CUSTOM < argument key >
        # - KEY UP Mode     = MULTIPLE
        # - N KEY UPs       = CUSTOM < argument n_key_ups >
        # - PTX Mode        = RANDOM
        # - PTX Len         = RANDOM
        # - AAD Mode        = RANDOM
        # - PTX Len         = RANDOM
        ########################################################################################
        elif ( self.frame_type == 'n_key_ups'):
            # SOP
            self.sop_mode       = 'single'


            # RESET
            self.reset_mode     = 'null'


            # VALID
            self.valid_mode     = valid_mode


            # GMAC
            self.gmac_mode      = gmac_mode


            # IV
            self.iv             = [ os.urandom(12) ]
            print     "IV                       = ", (self.iv[0]).encode("hex")


            # KEY/KEY_UPDATE
            self.key_mode       = 'custom'
            self.key            = [ key ]
            self.new_key        = [ new_key ]
            self.kup_mode       = 'multiple'
            self.n_key_ups      = n_key_ups
            print     "KEY                      = ", (self.key[0]).encode("hex")
            print     "NEW KEY                  = ", (self.new_key[0]).encode("hex")


            # PLAINTEXT
            self.ptx_len        = randint( 0, 4 )           #random len < 1024
            print     "PLAINTEXT LEN            = ", self.ptx_len
            self.ptx_mode       = 'random'


            # AAD
            msg_limit           = 2**10 - 1 - 1 - self.ptx_len
            # self.aad_len    = randint( 0, msg_limit )   # USE THIS LATER!
            self.aad_len        = randint( 0, 4 )         # AND DELETE THIS
            print     "AAD LEN                  = ", self.aad_len
            self.aad_mode       = 'random'
            if ( self.aad_len > 0):
                for i in range( 0, self.aad_len ):
                    (self.aad).append( os.urandom(32) )
                    print "AAD          [", i, "]       = ", (self.aad[i]).encode("hex")



        # RESET INITIAL
        ########################################################################################
        # This Frame Type has the following characteristics:
        # - SOP Mode        = SINGLE
        # - RESET Mode      = SINGLE
        # - VALID Mode      = CUSTOM < max_valid, random >
        # - GMAC Mode       = CUSTOM < on, off >
        # - IV              = CUSTOM < argument iv >
        # - KEY Mode        = CUSTOM < argument key >
        # - KEY UP Mode     = NULL
        # - N KEY UPs       = NULL
        # - PTX Mode        = CUSTOM < argument ptx_len >
        # - PTX Len         = RANDOM
        # - AAD Mode        = CUSTOM < argument aad_len >
        # - AAD Len         = RANDOM
        ########################################################################################
        elif ( self.frame_type == 'reset_init'):
            # SOP
            self.sop_mode       = 'single'


            # RESET
            self.reset_mode     = 'single'


            # VALID
            self.valid_mode     = valid_mode


            # GMAC
            self.gmac_mode      = gmac_mode


            # IV
            self.iv             = [ iv ]
            print     "IV                       = ", (self.iv[0]).encode("hex")


            # KEY/KEY_UPDATE
            self.key_mode       = 'custom'
            self.key            = [ key ]
            self.kup_mode       = 'null'
            self.n_key_ups      = 0
            print     "KEY                      = ", (self.key[0]).encode("hex")


            # PLAINTEXT
            self.ptx_len        = ptx_len
            print     "PLAINTEXT LEN            = ", self.ptx_len
            self.ptx_mode       = 'random'


            # AAD
            msg_limit           = 2**10 - 1 - 1 - self.ptx_len
            if ( aad_len <= msg_limit ):
                self.aad_len    = aad_len
                print     "AAD LEN                  = ", self.aad_len
                self.aad_mode   = 'random'
                if ( self.aad_len > 0):
                    for i in range( 0, self.aad_len ):
                        (self.aad).append( os.urandom(32) )
                        print "AAD          [", i, "]       = ", (self.aad[i]).encode("hex")
            else:
                sys.exit( "ERROR: Plaintext Length + AAD Lenght is too big" )



        # N RESETS
        ########################################################################################
        # This Frame Type has the following characteristics:
        # - SOP Mode        = SINGLE
        # - RESET Mode      = MULTIPLE
        # - VALID Mode      = CUSTOM < max_valid, random >
        # - GMAC Mode       = CUSTOM < on, off >
        # - IV              = CUSTOM < argument iv >
        # - KEY Mode        = CUSTOM < argument key >
        # - KEY UP Mode     = NULL
        # - N KEY UPs       = NULL
        # - PTX Mode        = CUSTOM < argument ptx_len >
        # - PTX Len         = RANDOM
        # - AAD Mode        = CUSTOM < argument aad_len >
        # - AAD Len         = RANDOM
        ########################################################################################
        elif ( self.frame_type == 'n_resets'):
            # SOP
            self.sop_mode       = 'single'


            # RESET
            self.reset_mode     = 'multiple'
            self.n_resets       = n_resets


            # VALID
            self.valid_mode     = valid_mode


            # GMAC
            self.gmac_mode      = gmac_mode


            # IV
            self.iv             = [ iv ]
            print     "IV                       = ", (self.iv[0]).encode("hex")


            # KEY/KEY_UPDATE
            self.key_mode       = 'custom'
            self.key            = [ key ]
            self.kup_mode       = 'null'
            self.n_key_ups      = 0
            print     "KEY                      = ", (self.key[0]).encode("hex")


            # PLAINTEXT
            self.ptx_len        = ptx_len
            print     "PLAINTEXT LEN            = ", self.ptx_len
            self.ptx_mode       = 'random'


            # AAD
            msg_limit           = 2**10 - 1 - 1 - self.ptx_len
            if ( aad_len <= msg_limit ):
                self.aad_len    = aad_len
                print     "AAD LEN                  = ", self.aad_len
                self.aad_mode   = 'random'
                if ( self.aad_len > 0):
                    for i in range( 0, self.aad_len ):
                        (self.aad).append( os.urandom(32) )
                        print "AAD          [", i, "]       = ", (self.aad[i]).encode("hex")
            else:
                sys.exit( "ERROR: Plaintext Length + AAD Lenght is too big" )


        # INITIAL
        ########################################################################################
        # This Frame Type has the following characteristics:
        # - SOP Mode        = SINGLE
        # - RESET Mode      = SINGLE
        # - VALID Mode      = CUSTOM < max_valid, random >
        # - GMAC Mode       = CUSTOM < on, off >
        # - IV              = CUSTOM < argument iv >
        # - KEY Mode        = CUSTOM < argument key >
        # - KEY UP Mode     = SINGLE
        # - N KEY UPs       = 1
        # - PTX Mode        = CUSTOM < argument ptx_len >
        # - PTX Len         = RANDOM
        # - AAD Mode        = CUSTOM < argument aad_len >
        # - AAD Len         = RANDOM
        ########################################################################################
        elif ( self.frame_type == 'init'):
            # SOP
            self.sop_mode       = 'single'


            # RESET
            self.reset_mode     = 'single'


            # VALID
            self.valid_mode     = valid_mode


            # GMAC
            self.gmac_mode      = gmac_mode


            # IV
            self.iv             = [ iv ]
            if (1): print     "IV                       = ", (self.iv[0]).encode("hex")


            # KEY/KEY_UPDATE
            self.key_mode       = 'custom'
            self.key            = [ key ]
            self.kup_mode       = 'single'
            self.n_key_ups      = 1
            if (debug): print     "KEY                      = ", (self.key[0]).encode("hex")


            # PLAINTEXT
            self.ptx_len        = ptx_len
            if (1): print     "PLAINTEXT LEN            = ", self.ptx_len
            self.ptx_mode       = 'random'


            # AAD
            msg_limit           = 2**10 - 1 - 1 - self.ptx_len
            if ( aad_len <= msg_limit ):
                self.aad_len    = aad_len
                if (1): print     "AAD LEN                  = ", self.aad_len
                self.aad_mode   = 'random'
                if ( self.aad_len > 0):
                    for i in range( 0, self.aad_len ):
                        (self.aad).append( os.urandom(32) )
                        if (1): print "AAD          [", i, "]       = ", (self.aad[i]).encode("hex")
            else:
                sys.exit( "ERROR: Plaintext Length + AAD Lenght is too big" )


        # CUSTOM LENGTH ( AAD, Plaintext)
        ########################################################################################
        # This Frame Type has the following characteristics:
        # - SOP Mode        = SINGLE
        # - RESET Mode      = NULL
        # - VALID Mode      = CUSTOM < max_valid, random >
        # - GMAC Mode       = CUSTOM < on, off >
        # - IV              = RANDOM
        # - KEY Mode        = CUSTOM < argument key >
        # - KEY UP Mode     = NULL
        # - N KEY UPs       = NULL
        # - PTX Mode        = CUSTOM < argument ptx_len >
        # - PTX Len         = RANDOM
        # - AAD Mode        = CUSTOM < argument aad_len >
        # - AAD Len         = RANDOM
        ########################################################################################
        elif ( self.frame_type == 'custom_len'):
            # SOP
            self.sop_mode       = 'single'


            # RESET
            self.reset_mode     = 'null'


            # VALID
            self.valid_mode     = valid_mode


            # GMAC
            self.gmac_mode      = gmac_mode


            # IV
            self.iv             = [ os.urandom(12) ]
            print     "IV                       = ", (self.iv[0]).encode("hex")


            # KEY/KEY_UPDATE
            self.key_mode       = 'custom'
            self.key            = [ key ]
            self.kup_mode       = 'null'
            self.n_key_ups      = 0
            print     "KEY                      = ", (self.key[0]).encode("hex")


            # PLAINTEXT
            self.ptx_len        = ptx_len
            print     "PLAINTEXT LEN            = ", self.ptx_len
            self.ptx_mode       = 'random'


            # AAD
            msg_limit           = 2**10 - 1 - 1 - self.ptx_len
            if ( aad_len <= msg_limit ):
                self.aad_len    = aad_len
                print     "AAD LEN                  = ", self.aad_len
                self.aad_mode   = 'random'
                if ( self.aad_len > 0):
                    for i in range( 0, self.aad_len ):
                        (self.aad).append( os.urandom(32) )
                        print "AAD          [", i, "]       = ", (self.aad[i]).encode("hex")
            else:
                sys.exit( "ERROR: Plaintext Length + AAD Lenght is too big" )


        # CUSTOM LENGTH+IV ( AAD, Plaintext + IV)
        ########################################################################################
        # This Frame Type has the following characteristics:
        # - SOP Mode        = SINGLE
        # - RESET Mode      = NULL
        # - VALID Mode      = CUSTOM < max_valid, random >
        # - GMAC Mode       = CUSTOM < on, off >
        # - IV              = CUSTOM < argument iv >
        # - KEY Mode        = CUSTOM < argument key >
        # - KEY UP Mode     = NULL
        # - N KEY UPs       = NULL
        # - PTX Mode        = CUSTOM < argument ptx_len >
        # - PTX Len         = RANDOM
        # - AAD Mode        = CUSTOM < argument aad_len >
        # - AAD Len         = RANDOM
        ########################################################################################
        elif ( self.frame_type == 'custom_len+iv'):
            # SOP
            self.sop_mode       = 'single'


            # RESET
            self.reset_mode     = 'null'


            # VALID
            self.valid_mode     = valid_mode


            # GMAC
            self.gmac_mode      = gmac_mode


            # IV
            self.iv             = [ iv ]
            print     "IV                       = ", (self.iv[0]).encode("hex")


            # KEY/KEY_UPDATE
            self.key_mode       = 'custom'
            self.key            = [ key ]
            self.kup_mode       = 'null'
            self.n_key_ups      = 0
            print     "KEY                      = ", (self.key[0]).encode("hex")


            # PLAINTEXT
            self.ptx_len        = ptx_len
            print     "PLAINTEXT LEN            = ", self.ptx_len
            self.ptx_mode       = 'random'


            # AAD
            msg_limit           = 2**10 - 1 - 1 - self.ptx_len
            if ( aad_len <= msg_limit ):
                self.aad_len    = aad_len
                print     "AAD LEN                  = ", self.aad_len
                self.aad_mode   = 'random'
                if ( self.aad_len > 0):
                    for i in range( 0, self.aad_len ):
                        (self.aad).append( os.urandom(32) )
                        print "AAD          [", i, "]       = ", (self.aad[i]).encode("hex")
            else:
                sys.exit( "ERROR: Plaintext Length + AAD Lenght is too big" )


        # CUSTOM IV
        ########################################################################################
        # This Frame Type has the following characteristics:
        # - SOP Mode        = SINGLE
        # - RESET Mode      = NULL
        # - VALID Mode      = CUSTOM < max_valid, random >
        # - GMAC Mode       = CUSTOM < on, off >
        # - IV              = CUSTOM < argument iv >
        # - KEY Mode        = CUSTOM < argument key >
        # - KEY UP Mode     = NULL
        # - N KEY UPs       = NULL
        # - PTX Mode        = RANDOM
        # - PTX Len         = RANDOM
        # - AAD Mode        = RANDOM
        # - AAD Len         = RANDOM
        ########################################################################################
        elif ( self.frame_type == 'custom_iv'):
            # SOP
            self.sop_mode       = 'single'


            # RESET
            self.reset_mode     = 'null'


            # VALID
            self.valid_mode     = valid_mode


            # GMAC
            self.gmac_mode      = gmac_mode


            # IV
            self.iv             = [ iv ]
            print     "IV                       = ", (self.iv[0]).encode("hex")


            # KEY/KEY_UPDATE
            self.key_mode       = 'custom'
            self.key            = [ key ]
            self.kup_mode       = 'null'
            self.n_key_ups      = 0
            print     "KEY                      = ", (self.key[0]).encode("hex")


            # PLAINTEXT
            self.ptx_len        = randint( 0, 8 )           #random len < 1024
            print     "PLAINTEXT LEN            = ", self.ptx_len
            self.ptx_mode       = 'random'


            # AAD
            msg_limit           = 2**10 - 1 - 1 - self.ptx_len
            # self.aad_len    = randint( 0, msg_limit ) # USE THIS LATER!
            self.aad_len        = randint( 0, 8 )           # AND DELETE THIS
            print     "AAD LEN                  = ", self.aad_len
            self.aad_mode       = 'random'
            if ( self.aad_len > 0):
                for i in range( 0, self.aad_len ):
                    (self.aad).append( os.urandom(32) )
                    print "AAD          [", i, "]       = ", (self.aad[i]).encode("hex")


        # PLAINTEXT
        # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

        # ptx             = []
        # plaintext_str   = '1111111111111111111111111111111122222222222222222222222222222222' #"d9313225f88406e5a55909c5aff5269a86a7a9531534f7da2e4c303d8a318a72"
        # (self.plaintext).append(plaintext_str.decode("hex"))
        # plaintext_str   = '3333333333333333333333333333333344444444444444444444444444444444'
        # (self.plaintext).append(plaintext_str.decode("hex"))
        # # plaintext_str   = '5555555555555555555555555555555566666666666666666666666666666666'
        # # (self.plaintext).append(plaintext_str.decode("hex"))
        # # plaintext_str   = '7777777777777777777777777777777788888888888888888888888888888888' #'1c3c0c95956809532fcf0e2449a6b525'
        # # # plaintext_str+= "b16aedf5aa0de657ba637b391aafd255"
        # # (self.plaintext).append(plaintext_str.decode("hex"))
        # # plaintext_str   = '99999999999999999999999999999999aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' #"d9313225f88406e5a55909c5aff5269a86a7a9531534f7da2e4c303d8a318a72"
        # # (self.plaintext).append(plaintext_str.decode("hex"))
        # # plaintext_str   = 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbcccccccccccccccccccccccccccccccc'
        # # (self.plaintext).append(plaintext_str.decode("hex"))
        # # plaintext_str   = 'ddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee'
        # # (self.plaintext).append(plaintext_str.decode("hex"))
        # plaintext_str   = 'ffffffffffffffffffffffffffffffff' #'1c3c0c95956809532fcf0e2449a6b525'
        # # plaintext_str+= "b16aedf5aa0de657ba637b391aafd255"
        # (self.plaintext).append(plaintext_str.decode("hex"))
        # for i in range( 0, len(self.plaintext) ):
        #     if (1): print "PLAINTEXT    [", i, "]       = ", (self.plaintext[i]).encode("hex")

        if ( self.ptx_len > 0 ):
            v = 0
            i = 0
            if (debug): print "self.ptx_len ", self.ptx_len
            while ( v < self.ptx_len ):
                if (debug): print "v ", v
                if ( self.ptx_len%2 == 0 ):
                    if (debug): print "========================            EVEN            ========================"
                    (self.plaintext).append( os.urandom(32) )
                    v = v + 2
                else:
                    if (debug): print "========================            ODD            ========================"
                    if ( v == self.ptx_len-1 ):
                        if (debug): print "========================            ULTIMO            ========================"
                        (self.plaintext).append( os.urandom(16) )
                        v = v + 1
                    else:
                        if (debug): print "========================            ELSE_ULTIMO            ========================"
                        (self.plaintext).append( os.urandom(32) )
                        v = v + 2
                if (1): print "PLAINTEXT    [", i, "]       = ", (self.plaintext[i]).encode("hex")
                i = i + 1

        # ENCRIPTION
        # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        if (debug): print "-------------------------------------------------------------"
        self.c, self.t  = self.gcm_aes_algorithm()


        # CIPHERTEXT
        if (debug): print "self.c           = ", (self.c).encode("hex")
        if ( self.ptx_len > 0 ):
            v = 0
            i = 0
            while ( v < self.ptx_len ):
                if ( self.ptx_len%2 == 0 ):
                    if (debug): print "========================            EVEN            ========================"
                    (self.ciphertext).append(self.c[i*32:(i+1)*32])
                    v = v + 2
                else:
                    if (debug): print "========================            ODD            ========================"
                    if ( v == self.ptx_len-1 ):
                        if (debug): print "========================            ULTIMO            ========================"
                        (self.ciphertext).append(self.c[i*32:])
                        v = v + 1
                    else:
                        if (debug): print "========================            ELSE_ULTIMO            ========================"
                        (self.ciphertext).append(self.c[i*32:(i+1)*32])
                        v = v+ 2
                if (1): print "CIPHERTEXT   [", i, "]       = ", (self.ciphertext[i]).encode("hex")
                i = i + 1

        # TAG
        if (debug): print "self.t           = ", (self.t).encode("hex")
        self.tag                = [ self.t ]

        if (1): print     "TAG                      = ", (self.tag[0]).encode("hex")

        # FUNCTION CALLING
        # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        if ( self.ptx_len%2 == 0 ):
            self.ptx_valid = self.ptx_len/2
        else:
            self.ptx_valid = self.ptx_len/2 + 1

        self.data_time          = self.ptx_valid + self.aad_len

        self.valid_generator()
        if (debug): print     "VALID                    = ", self.valid
        self.sop_generator()
        if (debug): print     "SOP                      = ", self.sop
        self.reset_generator()
        if (debug): print     "RESET                    = ", self.reset
        self.key_up_generator()
        if (debug): print     "KEY UPDATE               = ", self.key_up

        self.time_wizard()


    # Methods
    # **********************************************************************************************************************
    # VALID GENERATOR
    # This method generates the "valid" list according the type of valid selected and the length of the processed data.
    def valid_generator( self ):
        if (debug): print "Valid mode   = ", self.valid_mode
        valid_count = 0

        if( self.valid_mode == 'max_valid'          ):
            if ( self.reset_mode == 'null' ):
                self.valid      = [ 0 ]*1
            else:
                self.valid      = [ 0 ]*2
            while( valid_count <= self.data_time + randint( 0, self.data_time/3) ):
                valid_count = valid_count + 1
                if ( valid_count <= self.data_time ):
                    (self.valid).append( 1 )
                else:
                    (self.valid).append( 0 )

        if  ( self.valid_mode == 'random'         ):
            if ( self.reset_mode == 'null' ):
                self.valid      = [ 0 ]*1
            else:
                self.valid      = [ 0 ]*2
            while( valid_count <= self.data_time ):
                x = randint( 0, 1 )
                if x:
                    valid_count = valid_count + 1
                if ( valid_count <= self.data_time ):
                    (self.valid).append( x )
                else:
                    (self.valid).append( 0 )

        if( self.valid_mode == 'pat_low_valid'    ):
            if ( self.reset_mode == 'null' ):
                self.valid      = [ 0 ]*1
            else:
                self.valid      = [ 0 ]*2
            while( valid_count <= self.data_time  ):
                valid_count = valid_count + 1
                (self.valid).append( 0 )

        elif( self.valid_mode == 'pat_high_valid'   ):
            if ( self.reset_mode == 'null' ):
                self.valid      = [ 0 ]*1
            else:
                self.valid      = [ 0 ]*2
            while( valid_count <= self.data_time + randint( 0, self.data_time/3) ):
                valid_count = valid_count + 1
                (self.valid).append( 1 )

        elif( self.valid_mode == 'pat_always_valid' ):  # OJO con este. Se van a leer los ultimos 2 valids?
            if ( self.reset_mode == 'null' ):
                self.valid      = [ 1 ]*1
            else:
                self.valid      = [ 1 ]*2
            while( valid_count <= self.data_time + randint( 0, self.data_time/3) ):
                valid_count = valid_count + 1
                (self.valid).append( 1 )

    # SOP GENERATOR
    # This method generates the "sop" list according to the type selected and the length of the "valid" list
    def sop_generator( self ):
        if (debug): print "Sop mode     = ", self.sop_mode
        clk         = 0
        valid_clk   = 0
        n_sops      = 0
        if ( self.sop_mode == 'single'                              ):
            self.sop      = [ 0 ]*len(self.valid)
            if ( self.reset_mode == 'null'):
                self.sop[0]   = 1
            else:
                self.sop[1]   = 1

        # elif( self.sop_mode == 'pat_sop_b4_gctr'                ):
            # while ( clk < len(self.valid)                       ):
        #     if ( (clk == 0) | (valid_clk == self.gctr_end-1) ):
        #         (self.sop).append( 1 )
        #     else:
        #         (self.sop).append( 0 )

                # # LOOP LOGIC
                # if self.valid[clk]:
                #     valid_clk     = valid_clk + 1

                # clk = clk + 1

        # elif( self.sop_mode == 'pat_sop_b4_ghash'               ):
            # while ( clk < len(self.valid)                       ):
        #     if ( (clk == 0) | (valid_clk == self.ghash_done-1) ):
        #         (self.sop).append( 1 )
        #     else:
        #         (self.sop).append( 0 )

                # # LOOP LOGIC
                # if self.valid[clk]:
                #     valid_clk     = valid_clk + 1

                # clk = clk + 1

        # elif( self.sop_mode == 'pat_sop_pos_ghash'              ):
            # while ( clk < len(self.valid)                       ):
        #     if ( (clk == 0) | (valid_clk == self.ghash_done+1) ):
        #         (self.sop).append( 1 )
        #     else:
        #         (self.sop).append( 0 )

                # # LOOP LOGIC
                # if self.valid[clk]:
                #     valid_clk     = valid_clk + 1

                # clk = clk + 1

        # elif( self.sop_mode == 'pat_rand_sops'                  ):
            # while ( clk < len(self.valid)                       ):
        #     x = randint( 0, 1 )
        #     if ( n_sops < self.n_sops ):
        #         (self.sop).append( x )
        #     else:
        #         (self.sop).append( 0 )
        #     if x:
        #         n_sops = n_sops + 1

                # # LOOP LOGIC
                # if self.valid[clk]:
                #     valid_clk     = valid_clk + 1

                # clk = clk + 1

        elif( self.sop_mode == 'pat_n_sops'                     ):
            while ( clk < len(self.valid)                       ):
                x = randint( 0, 1 )
                (self.sop).append( x )

                # LOOP LOGIC
                if self.valid[clk]:
                    valid_clk     = valid_clk + 1

                clk = clk + 1

        else:
            sys.exit( "Invalid sop_mode" )


    # RESET GENERATOR
    # This method generates the "reset" list according to the type selected and the length of the "valid" list
    def reset_generator( self ):
        if (debug): print "Reset mode   = ", self.reset_mode
        clk         = 0
        valid_clk   = 0
        n_resets    = 0

        if ( self.reset_mode == 'null'                          ):
            self.reset = [ 0 ]*len(self.valid)

        elif( self.reset_mode == 'single'                       ):
            self.reset      = [ 0 ]*len(self.valid)
            self.reset[0]   = 1

        elif( self.reset_mode == 'multiple'                     ):
            self.reset = [ 0 ]*len(self.valid)
            deck = list( range( 0, len(self.valid ) ) )
            random.shuffle(deck)
            x   = []
            for i in range( 0, self.n_resets ):
                x.append( deck.pop() )
            for i in x:
                self.reset[i] = 1

        else:
            sys.exit( "Invalid sop_mode" )


    # KEY UPDATE GENERATOR
    # This method generates the "key update" list according to the type selected, the number of key updates and the length of the "valid" list
    def key_up_generator( self ):
        if (debug): print "Key up mode  = ", self.kup_mode
        clk         = 0
        valid_clk   = 0
        n_key_ups   = 0

        if ( self.kup_mode == 'null'                            ):
            self.key_up = [ 0 ]*len(self.valid)

        elif( self.kup_mode == 'single'                         ):
            self.key_up = [ 0 ]*len(self.valid)
            if ( self.reset_mode != 'null'):
                self.key_up[1] = 1

        elif( self.kup_mode == 'multiple'                       ):
            if (debug): print "================================================================================ ", self.n_key_ups
            self.key_up = [ 0 ]*len(self.valid)
            deck = list( range( 0, len(self.valid ) ) )
            random.shuffle(deck)
            x   = []
            for i in range( 0, self.n_key_ups ):
                x.append( deck.pop() )
            for i in x:
                self.key_up[i] = 1
                if (1): print "i = ", i
            self.last_kup = i
            if (debug): print "self.key_up = ", self.key_up
        else:
            sys.exit( "Invalid kup_mode" )


    # GCM AES ALGORITHM
    # This method aplies the GCM AES algorithm to a frame.
    def gcm_aes_algorithm( self ):
        # print "GCM AES ALGORITHM=============================================================="
        # Inputs definition logic
        # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        iv                  = 0
        key                 = 0
        aad_len             = 0
        aad                 = 0
        plaintext_len       = 0
        plaintext           = 0


        iv                  = self.iv[0]

        key                 = self.key[0]

        plaintext_len       = self.ptx_len
        # print "plaintext len        = ", len(self.plaintext)
        if ( self.ptx_len > 0):
            plaintext       = "".join(self.plaintext)
            # if (1): print "plaintext           = ", (plaintext).encode("hex")
        else:
            plaintext       = ("").decode("hex")

        aad_len             = self.aad_len
        if ( self.aad_len > 0):
            aad      = "".join(self.aad)
            if (debug): print "aad           = ", (aad).encode("hex")
        else:
            aad      = ("").decode("hex")


        if self.gmac_mode:
            if (debug): print "GMAC Mode ON"
            gmac_encryptor = Cipher(
                                        algorithms.AES( key )  ,
                                        modes.GCM( iv )        ,
                                        backend=default_backend()
                                    ).encryptor()

            # associated_data will be authenticated but not encrypted,
            # it must also be passed in on decryption.
            gmac_encryptor.authenticate_additional_data( aad )

            # Encrypt the plaintext and get the associated ciphertext.
            # GCM does not require padding.
            plaintext = gmac_encryptor.update( plaintext ) + gmac_encryptor.finalize()

        # Main GCM AES Execution
        # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        encryptor = Cipher  (
                                algorithms.AES(key),
                                modes.GCM(iv),
                                backend=default_backend()
                            ).encryptor()

        # associated_data will be authenticated but not encrypted,
        # it must also be passed in on decryption.
        encryptor.authenticate_additional_data( aad )

        # Ciphertext
        # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        # Encrypt the plaintext and get the associated ciphertext.
        # GCM does not require padding.
        # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        ciphertext = encryptor.update( plaintext ) + encryptor.finalize()

        # Tag
        # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        tag    = encryptor.tag

        # Output
        # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        return ciphertext, tag

    # TIME WIZARD
    # This method calculates several time-related values needed by other methods based on the data and the characteristics of a frame.
    def time_wizard( self ):
        self.ones_ctr           = 0
        self.aad_init           = 0
        self.aad_end            = 0
        self.started_aad        = 0
        self.finished_aad       = 0
        self.ptx_init           = 0
        self.ptx_end            = 0
        self.started_ptx        = 0
        self.finished_ptx       = 0
        self.gctr_init          = 0
        self.gctr_end           = 0
        self.bubbles            = 0
        self.skip_bus           = 0
        self.ghash_done         = 0
        self.run_time           = 0

        for h in range( 0, len( self.valid ) ):
            if ( h >= stab_time ):
                # Valid Ctr
                if ( self.valid_mode == 'pat_low_valid' ):
                    value   = 1
                else:
                    value   = self.valid[h]
                if value:
                    if (debug): print "h ", h
                    self.ones_ctr = self.ones_ctr + 1
                    if (debug): print "ones_ctr ", self.ones_ctr


                # AAD Start/End Logic
                if ( self.aad_len > 0 ):
                    if ( ( self.ones_ctr == 1 ) & ~self.started_aad ):
                        self.aad_init       = h
                        self.started_aad    = 1
                    if ( ( self.ones_ctr == self.aad_len ) & ~self.finished_aad ):
                        self.aad_end        = h
                        self.finished_aad   = 1
                else:
                    self.aad_init           = 0
                    self.aad_end            = 0
                    self.started_aad        = 1
                    self.finished_aad       = 1


                # Plaintext Start/End Logic
                if ( self.ptx_valid > 0 ):
                    if ( ( self.ones_ctr == self.aad_len + 1 ) & self.finished_aad & ~self.started_ptx ):
                        self.ptx_init       = h
                        self.started_ptx    = 1
                    if ( ( self.ones_ctr == self.aad_len + self.ptx_valid ) & ~self.finished_ptx ):
                        self.ptx_end        = h
                        self.finished_ptx   = 1
                else:
                    self.ptx_init           = 0
                    self.ptx_end            = 0
                    self.started_ptx        = 1
                    self.finished_ptx       = 1


        # GCTR & GHASH Logic
        if ( self.ptx_valid == 0 ):
            self.skip_bus       = 1
            self.gctr_init      = 0
            self.gctr_end       = 0
            if ( ( self.aad_len + self.skip_bus )%4  == 0 ):
                self.bubbles    = 4
            else:
                self.bubbles    = ( self.aad_len + self.skip_bus )%4
            self.ghash_done     = max( [ (self.aad_end + gctr_time), (self.aad_end  + 4-self.bubbles + 2 + ghash_time) ] )
        else:
            self.skip_bus       = int(not((self.ptx_len%2)))
            self.gctr_init      = self.ptx_init  + gctr_time
            self.gctr_end       = self.ptx_end  + gctr_time
            if ( ( self.aad_len + self.ptx_valid + self.skip_bus )%4  == 0 ):
                self.bubbles    = 4
            else:
                self.bubbles    = ( self.aad_len + self.ptx_valid + self.skip_bus )%4
            self.ghash_done     = self.gctr_end  + 4-self.bubbles + self.skip_bus + ghash_time

        # Frame Runtime
        self.run_time           = self.ghash_done + randint( 2, ghash_time/3 )



# CLASS DEFINITION
# ==========================================================================================================================

# Basic Frame Sequencer Class
# --------------------------------------------------------------------------------------------------------------------------
# This class put together 2 or more basic frames and creates a basic sequence of them based on the type selected.
# --------------------------------------------------------------------------------------------------------------------------
class Basic_Frame_Sequencer( object ):
    # Constructor
    # **********************************************************************************************************************
    def __init__(   self                        ,
                    frame_seq_type  = 'start1'  ,
                    valid_mode      = 'random'  ,   # Must be setted every time. Posible values = random, max
                    gmac_mode       = 0         ,   # Must be setted every time. Posible values = 0, 1
                    m1_frames       = 1         ,
                    m2_frames       = 7         ,
                    m3_frames       = 7         ,
                    n_key_ups       = 2         ,
                    n_resets        = 3
                ):


        if (debug): print ""
        if (debug): print "==================================================================================================="
        if (debug): print "New Basic Frame Sequence instance.Type -> ", frame_seq_type.upper()

        # Initialize Variables
        # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        self.frame_seq_type     = frame_seq_type
        self.valid_mode         = valid_mode
        self.gmac_mode          = gmac_mode
        self.m1_frames          = m1_frames
        self.m2_frames          = m2_frames
        self.m3_frames          = m3_frames
        self.frame_seq          = []

        # Frame Sequence Types
        # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++                  # RECORDAR CAMBIAR LAS CUSTOM KEY ( por defecto en std_key ) Y PONER LA PASADA POR LOS PARAMETROS
        if  ( self.frame_seq_type == 'start1'):
            # INITIAL
            ########################################################################################
            # This Frame Type has the following characteristics:
            # - SOP Mode                        = SINGLE
            # - RESET Mode                      = SINGLE
            # - VALID Mode                      = CUSTOM < max_valid, random >
            # - GMAC Mode                       = CUSTOM < on, off >
            # - IV                              = CUSTOM < argument iv >
            # - KEY Mode                        = CUSTOM < argument key >
            # - KEY UP Mode                     = SINGLE
            # - N KEY UPs                       = 1
            # - PTX Mode                        = CUSTOM < argument ptx_len >
            # - PTX Len                         = RANDOM
            # - AAD Mode                        = CUSTOM < argument aad_len >
            # - AAD Len                         = RANDOM
            ########################################################################################
            self.initial_frame                  = []
            for i in range( 0, self.m1_frames ):
                print "Creating frame %d/%d..." % (i+1, self.m1_frames)
                (self.initial_frame).append( Frame( frame_type='init', valid_mode=self.valid_mode, gmac_mode=self.gmac_mode, key_mode='custom', key=key_std, iv=os.urandom(12), ptx_len=5, aad_len=4 ) )

            # RANDOM
            ########################################################################################
            # This Frame Type has the following characteristics:
            # - SOP Mode                        = SINGLE
            # - RESET Mode                      = NULL
            # - VALID Mode                      = CUSTOM < max_valid, random >
            # - GMAC Mode                       = CUSTOM < on, off >
            # - IV                              = RANDOM
            # - KEY Mode                        = CUSTOM < argument key >
            # - KEY UP Mode                     = NULL
            # - N KEY UPs                       = NULL
            # - PTX Mode                        = RANDOM
            # - PTX Len                         = RANDOM
            # - AAD Mode                        = RANDOM
            # - PTX Len                         = RANDOM
            ########################################################################################
            self.random_frames                  = []
            for i in range( 0, self.m2_frames ):
                print "Creating frame %d/%d..." % (i+1, self.m2_frames)
                (self.random_frames).append( Frame( frame_type='random', valid_mode=self.valid_mode, gmac_mode=self.gmac_mode, key_mode='custom', key=key_std ) )

            self.frame_seq      = [ self.initial_frame, self.random_frames ]

        elif( self.frame_seq_type == 'start2'):
            # RESET INITIAL
            ########################################################################################
            # This Frame Type has the following characteristics:
            # - SOP Mode                        = SINGLE
            # - RESET Mode                      = SINGLE
            # - VALID Mode                      = CUSTOM < max_valid, random >
            # - GMAC Mode                       = CUSTOM < on, off >
            # - IV                              = CUSTOM < argument iv >
            # - KEY Mode                        = CUSTOM < argument key >
            # - KEY UP Mode                     = NULL
            # - N KEY UPs                       = NULL
            # - PTX Mode                        = CUSTOM < argument ptx_len >
            # - PTX Len                         = RANDOM
            # - AAD Mode                        = CUSTOM < argument aad_len >
            # - AAD Len                         = RANDOM
            ########################################################################################
            self.reset_init_frame               = []
            for i in range( 0, self.m1_frames ):
                print "Creating frame %d/%d..." % (i+1, self.m1_frames)
                (self.reset_init_frame).append( Frame( frame_type='reset_init', valid_mode=self.valid_mode, gmac_mode=self.gmac_mode, key_mode='custom', key=key_std, iv=os.urandom(12), ptx_len=5, aad_len=2 ) )


            # N KEY UPDATES
            ########################################################################################
            # This Frame Type has the following characteristics:
            # - SOP Mode                        = SINGLE
            # - RESET Mode                      = NULL
            # - VALID Mode                      = CUSTOM < max_valid, random >
            # - GMAC Mode                       = CUSTOM < on, off >
            # - IV                              = RANDOM
            # - KEY Mode                        = CUSTOM < argument key >
            # - KEY UP Mode                     = MULTIPLE
            # - N KEY UPs                       = CUSTOM < argument n_key_ups >
            # - PTX Mode                        = RANDOM
            # - PTX Len                         = RANDOM
            # - AAD Mode                        = RANDOM
            # - PTX Len                         = RANDOM
            ########################################################################################
            self.n_key_ups_frame                = []
            for i in range( 0, self.m2_frames ):
                print "Creating frame %d/%d..." % (i+1, self.m2_frames)
                (self.n_key_ups_frame).append( Frame( frame_type='n_key_ups', valid_mode=self.valid_mode, gmac_mode=self.gmac_mode, key_mode='custom', key=key_std, n_key_ups=n_key_ups ) )


            # RANDOM
            ########################################################################################
            # This Frame Type has the following characteristics:
            # - SOP Mode                        = SINGLE
            # - RESET Mode                      = NULL
            # - VALID Mode                      = CUSTOM < max_valid, random >
            # - GMAC Mode                       = CUSTOM < on, off >
            # - IV                              = RANDOM
            # - KEY Mode                        = CUSTOM < argument key >
            # - KEY UP Mode                     = NULL
            # - N KEY UPs                       = NULL
            # - PTX Mode                        = RANDOM
            # - PTX Len                         = RANDOM
            # - AAD Mode                        = RANDOM
            # - PTX Len                         = RANDOM
            ########################################################################################
            self.random_frames                  = []
            for i in range( 0, self.m3_frames ):
                print "Creating frame %d/%d..." % (i+1, self.m3_frames)
                (self.random_frames).append( Frame( frame_type='random', valid_mode=self.valid_mode, gmac_mode=self.gmac_mode, key_mode='custom', key=key_std ) )

            self.frame_seq      = [ self.reset_init_frame, self.n_key_ups_frame, self.random_frames ]

        elif( self.frame_seq_type == 'reset1'):
            # RESET INITIAL
            ########################################################################################
            # This Frame Type has the following characteristics:
            # - SOP Mode                        = SINGLE
            # - RESET Mode                      = SINGLE
            # - VALID Mode                      = CUSTOM < max_valid, random >
            # - GMAC Mode                       = CUSTOM < on, off >
            # - IV                              = CUSTOM < argument iv >
            # - KEY Mode                        = CUSTOM < argument key >
            # - KEY UP Mode                     = NULL
            # - N KEY UPs                       = NULL
            # - PTX Mode                        = CUSTOM < argument ptx_len >
            # - PTX Len                         = RANDOM
            # - AAD Mode                        = CUSTOM < argument aad_len >
            # - AAD Len                         = RANDOM
            ########################################################################################
            self.reset_init_frame               = []
            for i in range( 0, self.m1_frames ):
                print "Creating frame %d/%d..." % (i+1, self.m1_frames)
                (self.reset_init_frame).append( Frame( frame_type='reset_init', valid_mode=self.valid_mode, gmac_mode=self.gmac_mode, key_mode='custom', key=key_std, iv=os.urandom(12), ptx_len=5, aad_len=2 ) )


            # RANDOM
            ########################################################################################
            # This Frame Type has the following characteristics:
            # - SOP Mode                        = SINGLE
            # - RESET Mode                      = NULL
            # - VALID Mode                      = CUSTOM < max_valid, random >
            # - GMAC Mode                       = CUSTOM < on, off >
            # - IV                              = RANDOM
            # - KEY Mode                        = CUSTOM < argument key >
            # - KEY UP Mode                     = NULL
            # - N KEY UPs                       = NULL
            # - PTX Mode                        = RANDOM
            # - PTX Len                         = RANDOM
            # - AAD Mode                        = RANDOM
            # - PTX Len                         = RANDOM
            ########################################################################################
            self.random_frames                  = []
            for i in range( 0, self.m2_frames ):
                print "Creating frame %d/%d..." % (i+1, self.m2_frames)
                (self.random_frames).append( Frame( frame_type='random', valid_mode=self.valid_mode, gmac_mode=self.gmac_mode, key_mode='custom', key=key_std ) )

            self.frame_seq      = [ self.reset_init_frame, self.random_frames ]

        elif( self.frame_seq_type == 'reset2'):
            # N RESETS
            ########################################################################################
            # This Frame Type has the following characteristics:
            # - SOP Mode                        = SINGLE
            # - RESET Mode                      = MULTIPLE
            # - VALID Mode                      = CUSTOM < max_valid, random >
            # - GMAC Mode                       = CUSTOM < on, off >
            # - IV                              = CUSTOM < argument iv >
            # - KEY Mode                        = CUSTOM < argument key >
            # - KEY UP Mode                     = NULL
            # - N KEY UPs                       = NULL
            # - PTX Mode                        = CUSTOM < argument ptx_len >
            # - PTX Len                         = RANDOM
            # - AAD Mode                        = CUSTOM < argument aad_len >
            # - AAD Len                         = RANDOM
            ########################################################################################
            self.n_resets_frame                 = []
            for i in range( 0, self.m1_frames ):
                print "Creating frame %d/%d..." % (i+1, self.m1_frames)
                (self.n_resets_frame).append( Frame( frame_type='n_resets', valid_mode=self.valid_mode, gmac_mode=self.gmac_mode, key_mode='custom', key=key_std, iv=os.urandom(12), ptx_len=5, aad_len=3, n_resets=n_resets ) )


            # RANDOM
            ########################################################################################
            # This Frame Type has the following characteristics:
            # - SOP Mode                        = SINGLE
            # - RESET Mode                      = NULL
            # - VALID Mode                      = CUSTOM < max_valid, random >
            # - GMAC Mode                       = CUSTOM < on, off >
            # - IV                              = RANDOM
            # - KEY Mode                        = CUSTOM < argument key >
            # - KEY UP Mode                     = NULL
            # - N KEY UPs                       = NULL
            # - PTX Mode                        = RANDOM
            # - PTX Len                         = RANDOM
            # - AAD Mode                        = RANDOM
            # - PTX Len                         = RANDOM
            ########################################################################################
            self.random_frames                  = []
            for i in range( 0, self.m2_frames ):
                print "Creating frame %d/%d..." % (i+1, self.m2_frames)
                (self.random_frames).append( Frame( frame_type='random', valid_mode=self.valid_mode, gmac_mode=self.gmac_mode, key_mode='custom', key=key_std ) )

            self.frame_seq      = [ self.n_resets_frame, self.random_frames ]

        elif( self.frame_seq_type == 'kup' ):
            kup_time        = 130*8# + 44
            run_time_sum    = 0

            # INITIAL
            ########################################################################################
            # This Frame Type has the following characteristics:
            # - SOP Mode                        = SINGLE
            # - RESET Mode                      = SINGLE
            # - VALID Mode                      = CUSTOM < max_valid, random >
            # - GMAC Mode                       = CUSTOM < on, off >
            # - IV                              = CUSTOM < argument iv >
            # - KEY Mode                        = CUSTOM < argument key >
            # - KEY UP Mode                     = SINGLE
            # - N KEY UPs                       = 1
            # - PTX Mode                        = CUSTOM < argument ptx_len >
            # - PTX Len                         = RANDOM
            # - AAD Mode                        = CUSTOM < argument aad_len >
            # - AAD Len                         = RANDOM
            ########################################################################################
            self.initial_frame                  = []
            for i in range( 0, self.m1_frames ):
                print "Creating frame %d/%d..." % (i+1, self.m1_frames)
                (self.initial_frame).append( Frame( frame_type='init', valid_mode=self.valid_mode, gmac_mode=self.gmac_mode, key_mode='custom', key=key_std, iv=os.urandom(12), ptx_len=5, aad_len=4 ) )

            # RANDOM
            ########################################################################################
            # This Frame Type has the following characteristics:
            # - SOP Mode                        = SINGLE
            # - RESET Mode                      = NULL
            # - VALID Mode                      = CUSTOM < max_valid, random >
            # - GMAC Mode                       = CUSTOM < on, off >
            # - IV                              = RANDOM
            # - KEY Mode                        = CUSTOM < argument key >
            # - KEY UP Mode                     = NULL
            # - N KEY UPs                       = NULL
            # - PTX Mode                        = RANDOM
            # - PTX Len                         = RANDOM
            # - AAD Mode                        = RANDOM
            # - PTX Len                         = RANDOM
            ########################################################################################
            self.random_frames1                  = []
            for i in range( 0, self.m2_frames ):
                print "Creating frame %d/%d..." % (i+1, self.m2_frames/3)
                (self.random_frames1).append( Frame( frame_type='random', valid_mode=self.valid_mode, gmac_mode=self.gmac_mode, key_mode='custom', key=key_std ) )


            # N KEY UPDATES
            ########################################################################################
            # This Frame Type has the following characteristics:
            # - SOP Mode                        = SINGLE
            # - RESET Mode                      = NULL
            # - VALID Mode                      = CUSTOM < max_valid, random >
            # - GMAC Mode                       = CUSTOM < on, off >
            # - IV                              = RANDOM
            # - KEY Mode                        = CUSTOM < argument key >
            # - KEY UP Mode                     = MULTIPLE
            # - N KEY UPs                       = CUSTOM < argument n_key_ups >
            # - PTX Mode                        = RANDOM
            # - PTX Len                         = RANDOM
            # - AAD Mode                        = RANDOM
            # - PTX Len                         = RANDOM
            ########################################################################################
            self.n_key_ups_frame                = []
            for i in range( 0, self.m1_frames ):
                print "Creating KUP frame %d/%d..." % (i+1, self.m1_frames)                                                                                 #os.urandom(32)
                frame   =   Frame( frame_type='n_key_ups', valid_mode=self.valid_mode, gmac_mode=self.gmac_mode, key_mode='custom', key=key_std, new_key=key_std2, n_key_ups=n_key_ups )
                (self.n_key_ups_frame).append( frame )

            # if (debug): print "frame.last_kup ", frame.last_kup
            run_time_sum    += frame.run_time - frame.last_kup


            # RANDOM
            ########################################################################################
            # This Frame Type has the following characteristics:
            # - SOP Mode                        = SINGLE
            # - RESET Mode                      = NULL
            # - VALID Mode                      = CUSTOM < max_valid, random >
            # - GMAC Mode                       = CUSTOM < on, off >
            # - IV                              = RANDOM
            # - KEY Mode                        = CUSTOM < argument key >
            # - KEY UP Mode                     = NULL
            # - N KEY UPs                       = NULL
            # - PTX Mode                        = RANDOM
            # - PTX Len                         = RANDOM
            # - AAD Mode                        = RANDOM
            # - PTX Len                         = RANDOM
            ########################################################################################
            self.random_frames                  = []
            for i in range( 0, self.m2_frames ):
                print "Creating frame %d/%d..." % (i+1, self.m2_frames)
                if ( run_time_sum >= kup_time ):                                                                                        #(self.n_key_ups_frame[self.m1_frames - 1]).new_key[0]
                    frame   =   Frame( frame_type='random', valid_mode=self.valid_mode, gmac_mode=self.gmac_mode, key_mode='custom', key=(self.n_key_ups_frame[self.m1_frames - 1]).new_key[0] )
                else:
                    frame   =   Frame( frame_type='random', valid_mode=self.valid_mode, gmac_mode=self.gmac_mode, key_mode='custom', key=key_std )
                (self.random_frames).append( frame )
                run_time_sum    +=  frame.run_time

            self.frame_seq      = [ self.initial_frame, self.random_frames1, self.n_key_ups_frame, self.random_frames ]

        elif( self.frame_seq_type == 'pat_valid1' ):
            # RANDOM PATOLOGIC HIGH VALID
            ########################################################################################
            # This Frame Type has the following characteristics:
            # - SOP Mode                        = SINGLE
            # - RESET Mode                      = NULL
            # - VALID Mode                      = CUSTOM < pat_always_valid >
            # - GMAC Mode                       = CUSTOM < on, off >
            # - IV                              = RANDOM
            # - KEY Mode                        = CUSTOM < argument key >
            # - KEY UP Mode                     = NULL
            # - N KEY UPs                       = NULL
            # - PTX Mode                        = RANDOM
            # - PTX Len                         = RANDOM
            # - AAD Mode                        = RANDOM
            # - PTX Len                         = RANDOM
            ########################################################################################
            self.random_pat_always_valid_frames = []
            for i in range( 0, self.m1_frames ):
                print "Creating frame %d/%d..." % (i+1, self.m1_frames)
                (self.random_pat_always_valid_frames).append( Frame( frame_type='random', valid_mode='pat_always_valid', gmac_mode=self.gmac_mode, key_mode='custom', key=key_std ) )



            # RANDOM
            ########################################################################################
            # This Frame Type has the following characteristics:
            # - SOP Mode                        = SINGLE
            # - RESET Mode                      = NULL
            # - VALID Mode                      = CUSTOM < max_valid, random >
            # - GMAC Mode                       = CUSTOM < on, off >
            # - IV                              = RANDOM
            # - KEY Mode                        = CUSTOM < argument key >
            # - KEY UP Mode                     = NULL
            # - N KEY UPs                       = NULL
            # - PTX Mode                        = RANDOM
            # - PTX Len                         = RANDOM
            # - AAD Mode                        = RANDOM
            # - PTX Len                         = RANDOM
            ########################################################################################
            self.random_frames                  = []
            for i in range( 0, self.m2_frames ):
                print "Creating frame %d/%d..." % (i+1, self.m2_frames)
                (self.random_frames).append( Frame( frame_type='random', valid_mode=self.valid_mode, gmac_mode=self.gmac_mode, key_mode='custom', key=key_std ) )

            self.frame_seq      = [ self.random_pat_always_valid_frames, self.random_frames ]

        elif( self.frame_seq_type == 'pat_valid2' ):
            # RANDOM PATOLOGIC HIGH VALID
            ########################################################################################
            # This Frame Type has the following characteristics:
            # - SOP Mode                        = SINGLE
            # - RESET Mode                      = NULL
            # - VALID Mode                      = CUSTOM < pat_always_valid >
            # - GMAC Mode                       = CUSTOM < on, off >
            # - IV                              = RANDOM
            # - KEY Mode                        = CUSTOM < argument key >
            # - KEY UP Mode                     = NULL
            # - N KEY UPs                       = NULL
            # - PTX Mode                        = RANDOM
            # - PTX Len                         = RANDOM
            # - AAD Mode                        = RANDOM
            # - PTX Len                         = RANDOM
            ########################################################################################
            self.random_pat_always_valid_frames = []
            for i in range( 0, self.m1_frames ):
                (self.random_pat_always_valid_frames).append( Frame( frame_type='random', valid_mode='pat_low_valid', gmac_mode=self.gmac_mode, key_mode='custom', key=key_std ) )


            # RANDOM
            ########################################################################################
            # This Frame Type has the following characteristics:
            # - SOP Mode                        = SINGLE
            # - RESET Mode                      = NULL
            # - VALID Mode                      = CUSTOM < max_valid, random >
            # - GMAC Mode                       = CUSTOM < on, off >
            # - IV                              = RANDOM
            # - KEY Mode                        = CUSTOM < argument key >
            # - KEY UP Mode                     = NULL
            # - N KEY UPs                       = NULL
            # - PTX Mode                        = RANDOM
            # - PTX Len                         = RANDOM
            # - AAD Mode                        = RANDOM
            # - PTX Len                         = RANDOM
            ########################################################################################
            self.random_frames                  = []
            for i in range( 0, self.m2_frames ):
                (self.random_frames).append( Frame( frame_type='random', valid_mode=self.valid_mode, gmac_mode=self.gmac_mode, key_mode='custom', key=key_std ) )

            self.frame_seq      = [ self.random_pat_always_valid_frames, self.random_frames ]

        # elif( self.frame_seq_type == 'pat_sop1' ):
        #     # RANDOM PATOLOGIC HIGH VALID
        #     ########################################################################################
        #     # This Frame Type has the following characteristics:
        #     # - SOP Mode                        = SINGLE
        #     # - RESET Mode                      = NULL
        #     # - VALID Mode                      = CUSTOM < pat_always_valid >
        #     # - GMAC Mode                       = CUSTOM < on, off >
        #     # - IV                              = RANDOM
        #     # - KEY Mode                        = CUSTOM < argument key >
        #     # - KEY UP Mode                     = NULL
        #     # - N KEY UPs                       = NULL
        #     # - PTX Mode                        = RANDOM
        #     # - PTX Len                         = RANDOM
        #     # - AAD Mode                        = RANDOM
        #     # - PTX Len                         = RANDOM
        #     ########################################################################################
        #     self.random_pat_sop_b4_gctr_frames = []
        #     for i in range( 0, self.m1_frames ):
        #         (self.random_pat_sop_b4_gctr_frames).append( Frame( frame_type='custom_sop_mode', valid_mode=self.valid_mode, gmac_mode=self.gmac_mode, key_mode='custom', key=key_std, sop_mode='pat_sop_b4_gctr' ) )


        #     # RANDOM
        #     ########################################################################################
        #     # This Frame Type has the following characteristics:
        #     # - SOP Mode                        = SINGLE
        #     # - RESET Mode                      = NULL
        #     # - VALID Mode                      = CUSTOM < max_valid, random >
        #     # - GMAC Mode                       = CUSTOM < on, off >
        #     # - IV                              = RANDOM
        #     # - KEY Mode                        = CUSTOM < argument key >
        #     # - KEY UP Mode                     = NULL
        #     # - N KEY UPs                       = NULL
        #     # - PTX Mode                        = RANDOM
        #     # - PTX Len                         = RANDOM
        #     # - AAD Mode                        = RANDOM
        #     # - PTX Len                         = RANDOM
        #     ########################################################################################
        #     self.random_frames                  = []
        #     for i in range( 0, self.m2_frames ):
        #         (self.random_frames).append( Frame( frame_type='random', valid_mode=self.valid_mode, gmac_mode=self.gmac_mode, key_mode='custom', key=key_std ) )

        #     self.frame_seq      = [ self.random_pat_sop_b4_gctr_frames, self.random_frames ]

            # self.code_writter()

        # elif( self.frame_seq_type == 'pat_sop_b4_gctr' ):

        # elif( self.frame_seq_type == 'pat_sop_b4_ghash' ):

        # elif( self.frame_seq_type == 'pat_sop_pos_ghash' ):

        # elif( self.frame_seq_type == 'pat_rand_sops' ):

        self.code_writter()

    # Methods
    # **********************************************************************************************************************
    # CODE WIRTTER
    # This method writes a verilog testbench file using the data of a secuence of frames.
    def code_writter( self ):
        run_time                    = 0
        clk                         = 0
        valid_clk                   = 0
        valid_vector                = []
        sop_vector                  = []
        reset_vector                = []
        key_up_vector               = []
        key_vector                  = []
        iv_vector                   = []
        gmac_mode_vector            = []
        encrypt_vector              = []
        clear_fault_flags_vector    = []
        plaintext_vector            = []
        aad_vector                  = []
        o_valid_vector              = []
        o_sop_vector                = []
        ciphertext_vector           = []
        tag_vector                  = []
        tag_ready_vector            = []
        ptx_lenght_vector           = []
        aad_lenght_vector           = []


        for i in range( 0, len(self.frame_seq) ):
            if (debug): print self.frame_seq_type
            for j in range( 0, len(self.frame_seq[i]) ):
                frame   = ( self.frame_seq[i] )[j]
                if (debug): print frame.frame_type

                # Time Stuff
                ones_ctr            = frame.ones_ctr
                aad_init            = frame.aad_init
                aad_end             = frame.aad_end
                started_aad         = frame.started_aad
                finished_aad        = frame.finished_aad
                ptx_init            = frame.ptx_init
                ptx_end             = frame.ptx_end
                started_ptx         = frame.started_ptx
                finished_ptx        = frame.finished_ptx
                gctr_init           = frame.gctr_init
                gctr_end            = frame.gctr_end
                bubbles             = frame.bubbles
                skip_bus            = frame.skip_bus
                ghash_done          = frame.ghash_done
                run_time            = frame.run_time

                if (debug): print "frame.valid)                     =   ", frame.valid
                if (debug): print "frame.aad_len                    =   ", frame.aad_len
                if (debug): print "frame.ptx_len                    =   ", frame.ptx_len
                if (debug): print "aad_init                         =   ", aad_init
                if (debug): print "aad_end                          =   ", aad_end
                if (debug): print "ptx_init                         =   ", ptx_init
                if (debug): print "ptx_end                          =   ", ptx_end
                if (debug): print "gctr_init                        =   ", gctr_init
                if (debug): print "gctr_end                         =   ", gctr_end
                if (debug): print "ghash_done                       =   ", ghash_done


                # Vector generation
                valid_vector.extend( frame.valid )
                fill = len(frame.valid)
                while ( fill < run_time ):
                    valid_vector.extend( [0] )
                    fill = fill + 1

                if (debug): print "valid_vector             -> ", len(valid_vector)
                if (debug): print "valid_vector             -> ", (valid_vector)


                sop_vector.extend( frame.sop )
                fill = len(frame.sop)
                while ( fill < run_time ):
                    sop_vector.extend( [0] )
                    fill = fill + 1


                reset_vector.extend( frame.reset )
                fill = len(frame.reset)
                while ( fill < run_time ):
                    reset_vector.extend( [0] )
                    fill = fill + 1


                key_up_vector.extend( frame.key_up )
                fill = len(frame.key_up)
                while ( fill < run_time ):
                    key_up_vector.extend( [0] )
                    fill = fill + 1


                fill = 0
                while ( fill < run_time ):
                    iv_vector.extend( frame.iv )
                    fill = fill + 1


                fill = 0
                if ( frame.frame_type == 'n_key_ups'):
                    while ( fill < len(frame.key_up) ):
                        if (frame.key_up[fill] == 1 ):
                            key_vector.extend( frame.new_key )
                        else:
                            key_vector.extend( frame.key )
                        fill = fill + 1
                    while ( fill < run_time ):
                        key_vector.extend( frame.key )
                        fill = fill + 1
                else:
                    while ( fill < run_time ):
                        key_vector.extend( frame.key )
                        fill = fill + 1


                fill = 0
                while ( fill < run_time ):
                    gmac_mode_vector.extend( [frame.gmac_mode] )
                    fill = fill + 1


                fill = 0
                while ( fill < run_time ):
                    encrypt_vector.extend( [1] )
                    fill = fill + 1


                fill = 0
                while ( fill < run_time ):
                    clear_fault_flags_vector.extend( [0] )
                    fill = fill + 1


                fill = 0
                while ( fill < run_time ):
                    aad_lenght_vector.extend( [frame.aad_len] )
                    fill = fill + 1


                aad_vector.extend( 'x'*(aad_init) )
                l = aad_init
                v = 0
                if ( frame.valid_mode == 'pat_low_valid' ):
                    if (aad_end > 0):
                        while ( l < aad_end+1 ):
                            aad_vector.extend( [ frame.aad[v][(32/2):32] + frame.aad[v][0:(32/2)] ] )
                            v = v + 1
                            l = l + 1
                else:
                    while ( l < aad_end+1 ):
                        if ( frame.valid[l] == 1 ):
                            aad_vector.extend( [ frame.aad[v][(32/2):32] + frame.aad[v][0:(32/2)] ] )
                            v = v + 1
                        else:
                            aad_vector.extend( 'x' )
                        l = l + 1
                fill = len(aad_vector)
                while ( fill < len(valid_vector) ):
                    aad_vector.extend( 'x' )
                    fill = fill + 1


                fill = 0
                while ( fill < run_time ):
                    ptx_lenght_vector.extend( [frame.ptx_len] )
                    fill = fill + 1


                plaintext_vector.extend( 'x'*(ptx_init) )
                l = ptx_init
                v = 0
                if ( frame.valid_mode == 'pat_low_valid' ):
                     while ( l < ptx_end+1 ):
                        if ( v < frame.ptx_valid ):
                            if (debug): print "V < ptx Valid"
                            if ( frame.ptx_len%2 == 0 ):
                                if (debug): print "========================            EVEN            ========================"
                                plaintext_vector.extend( [ frame.plaintext[v][(32/2):32] + frame.plaintext[v][0:(32/2)] ] )
                            else:
                                if (debug): print "========================            ODD            ========================"
                                if ( v == frame.ptx_len-1):
                                    if (debug): print "========================            ULTIMO            ========================"
                                    plaintext_vector.extend( [ zero_128 + frame.plaintext[v] ] )
                                else:
                                    if (debug): print "========================            ELSE_ULTIMO            ========================"
                                    plaintext_vector.extend( [ frame.plaintext[v][(32/2):32] + frame.plaintext[v][0:(32/2)] ] )
                                v = v + 1
                        else:
                            plaintext_vector.extend( 'x' )
                        l = l + 1
                else:
                    while ( l < ptx_end+1 ):
                        if ( frame.valid[l] == 1 ):
                            if ( v < frame.ptx_valid ):
                                if ( frame.ptx_len%2 == 0 ):
                                    if (debug): print "========================            EVEN            ========================"
                                    plaintext_vector.extend( [ frame.plaintext[v][(32/2):32] + frame.plaintext[v][0:(32/2)] ] )
                                else:
                                    if (debug): print "========================            ODD            ========================"
                                    if ( v == frame.ptx_len-1):
                                        if (debug): print "========================            ULTIMO            ========================"
                                        plaintext_vector.extend( [ zero_128 + frame.plaintext[v] ] )
                                    else:
                                        if (debug): print "========================            ELSE_ULTIMO            ========================"
                                        plaintext_vector.extend( [ frame.plaintext[v][(32/2):32] + frame.plaintext[v][0:(32/2)] ] )
                                v = v + 1
                        else:
                            plaintext_vector.extend( 'x' )
                        l = l + 1
                fill = len(plaintext_vector)
                while ( fill < len(valid_vector) ):
                    plaintext_vector.extend( 'x' )
                    fill = fill + 1


                o_valid_vector.extend( [0]*(gctr_init-1) )
                if ( frame.valid_mode == 'pat_always_valid' ):
                    o_valid_vector.extend( frame.valid[ptx_init:] )
                else:
                    o_valid_vector.extend( frame.valid[ptx_init:ptx_end+1] )
                fill = len(o_valid_vector)
                while ( fill < len(valid_vector) ):
                    o_valid_vector.extend( [0] )
                    fill = fill + 1


                o_sop_vector.extend( [0]*(gctr_init-1) )
                if ( frame.ptx_len > 0 ):
                    o_sop_vector.extend( [1] )
                else:
                    o_sop_vector.extend( [0] )
                fill = len(o_sop_vector)
                while ( fill < len(valid_vector) ):
                    o_sop_vector.extend( [0] )
                    fill = fill + 1


                ciphertext_vector.extend( 'x'*(gctr_init-1) )
                l = ptx_init
                v = 0
                while ( l < ptx_end+1 ):
                    if ( frame.valid[l] == 1 ):
                        if ( v < frame.ptx_valid ):
                            if ( frame.ptx_len%2 == 0 ):
                                if (debug): print "========================            EVEN            ========================"
                                ciphertext_vector.extend( [ frame.ciphertext[v][(32/2):32] + frame.ciphertext[v][0:(32/2)] ] )
                            else:
                                if (debug): print "========================            ODD            ========================"
                                if ( v == frame.ptx_len-1):
                                    if (debug): print "========================            ULTIMO            ========================"
                                    ciphertext_vector.extend( [ zero_128 + frame.ciphertext[v][0:(32/2)] ] )
                                else:
                                    if (debug): print "========================            ELSE_ULTIMO            ========================"
                                    ciphertext_vector.extend( [ frame.ciphertext[v][(32/2):32] + frame.ciphertext[v][0:(32/2)] ] )
                            v = v + 1
                    else:
                        ciphertext_vector.extend( 'x' )
                    l = l + 1
                fill = len(ciphertext_vector)
                while ( fill < len(valid_vector) ):
                    ciphertext_vector.extend( 'x' )
                    fill = fill + 1


                tag_vector.extend( 'x'*(ghash_done-1) )
                tag_vector.extend( frame.tag )
                fill = len(tag_vector)
                while ( fill < len(valid_vector) ):
                    tag_vector.extend( 'x' )
                    fill = fill + 1


                tag_ready_vector.extend( [0]*(ghash_done-1) )
                tag_ready_vector.extend( [1] )
                fill = len(tag_ready_vector)
                while ( fill < len(valid_vector) ):
                    tag_ready_vector.extend( [0] )
                    fill = fill + 1

        if (debug): print ""
        if (debug): print "valid_vector             -> ", len(valid_vector)
        if (debug): print "valid_vector             -> ", (valid_vector)
        if (debug): print ""
        if (debug): print "sop_vector               -> ", len(sop_vector)
        if (debug): print "sop_vector               -> ", (sop_vector)
        if (debug): print ""
        if (debug): print "reset_vector             -> ", len(reset_vector)
        if (debug): print "reset_vector             -> ", (reset_vector)
        if (debug): print ""
        if (debug): print "key_up_vector            -> ", len(key_up_vector)
        if (debug): print "key_up_vector            -> ", (key_up_vector)
        if (debug): print ""
        if (debug): print "key_vector               -> ", len(key_vector)
        if (debug): print "key_vector               -> ", (key_vector)
        if (debug): print ""
        if (debug): print "iv_vector                -> ", len(iv_vector)
        if (debug): print "iv_vector                -> ", (iv_vector)
        if (debug): print ""
        if (debug): print "gmac_mode_vector         -> ", len(gmac_mode_vector)
        if (debug): print "gmac_mode_vector         -> ", (gmac_mode_vector)
        if (debug): print ""
        if (debug): print "encrypt_vector           -> ", len(encrypt_vector)
        if (debug): print "encrypt_vector           -> ", (encrypt_vector)
        if (debug): print ""
        if (debug): print "clear_fault_flags_vector -> ", len(clear_fault_flags_vector)
        if (debug): print "clear_fault_flags_vector -> ", (clear_fault_flags_vector)
        if (debug): print ""
        if (debug): print "aad_lenght_vector        -> ", len(aad_lenght_vector)
        if (debug): print "aad_lenght_vector        -> ", (aad_lenght_vector)
        if (debug): print ""
        if (debug): print "aad_vector               -> ", len(aad_vector)
        if (debug): print "aad_vector               -> ", (aad_vector)
        if (debug): print ""
        if (debug): print "ptx_lenght_vector        -> ", len(ptx_lenght_vector)
        if (debug): print "ptx_lenght_vector        -> ", (ptx_lenght_vector)
        if (debug): print ""
        if (debug): print "plaintext_vector         -> ", len(plaintext_vector)
        if (debug): print "plaintext_vector         -> ", (plaintext_vector)
        if (debug): print ""
        if (debug): print "o_valid_vector           -> ", len(o_valid_vector)
        if (debug): print "o_valid_vector           -> ", (o_valid_vector)
        if (debug): print ""
        if (debug): print "o_sop_vector             -> ", len(o_sop_vector)
        if (debug): print "o_sop_vector             -> ", (o_sop_vector)
        if (debug): print ""
        if (debug): print "ciphertext_vector        -> ", len(ciphertext_vector)
        if (debug): print "ciphertext_vector        -> ", (ciphertext_vector)
        if (debug): print ""
        if (debug): print "tag_vector               -> ", len(tag_vector)
        if (debug): print "tag_vector               -> ", (tag_vector)
        if (debug): print ""
        if (debug): print "tag_ready_vector         -> ", len(tag_ready_vector)
        if (debug): print "tag_ready_vector         -> ", (tag_ready_vector)
        if (debug): print ""

        f = open( 'tb_autogen_gcm_aes.v', 'w' )

        f.write( "module tb_autogen_gcm_aes"                                                                                            )
        # f.write( "\n#("                                                                                                                 )
        # f.write( "\n    // PARAMETERS."                                                                                                 )
        # f.write( "\n    // none so far"                                                                                                 )
        # f.write( "\n)"                                                                                                                  )
        f.write( "\n("                                                                                                                  )
        f.write( "\n    // OUTPUTS."                                                                                                    )
        f.write( "\n    output      wire                    o_compOK                                            ,"                      )
        f.write( "\n    output      wire                    o_ciphertextOK                                      ,"                      )
        f.write( "\n    output      wire                    o_tagOK"                                                                    )
        f.write( "\n    // INPUTS."                                                                                                     )
        f.write( "\n    // none so far"                                                                                                 )
        f.write( "\n);"                                                                                                                 )
        f.write( "\n"                                                                                                                   )
        f.write( "\n// LOCALPARAMETERS."                                                                                                )
        f.write( "\n// ----------------------------------------------------------------------------------------------------"            )
        f.write( "\nlocalparam                              NB_BLOCK                =   128                     ;"                      )
        f.write( "\nlocalparam                              N_BLOCKS                =   2                       ;"                      )
        f.write( "\nlocalparam                              NB_DATA                 =   N_BLOCKS*NB_BLOCK       ;"                      )
        f.write( "\nlocalparam                              NB_IV                   =   96                      ;"                      )
        f.write( "\nlocalparam                              NB_KEY                  =   256                     ;"                      )
        f.write( "\nlocalparam                              NB_INC_MODE             =   2                       ;"                      )
        f.write( "\nlocalparam                              USE_LUT_IN_SUBBYTES     =   0                       ;"                      )
        f.write( "\nlocalparam                              NB_N_MESSAGES           =   10                      ;"                      )
        f.write( "\nlocalparam                              RUN_TIME                =   %d                      ;"  % len(valid_vector) )
        f.write( "\n"                                                                                                                   )
        f.write( "\n"                                                                                                                   )
        f.write( "\n// INTERNAL SIGNALS."                                                                                               )
        f.write( "\n// ----------------------------------------------------------------------------------------------------"            )
        f.write( "\nwire                                    tb_i_valid                      [ RUN_TIME-1:0  ]   ;"                      )
        f.write( "\nwire                                    tb_i_reset                      [ RUN_TIME-1:0  ]   ;"                      )
        f.write( "\nwire                                    tb_i_sop                        [ RUN_TIME-1:0  ]   ;"                      )
        f.write( "\nwire                                    tb_i_key_update                 [ RUN_TIME-1:0  ]   ;"                      )
        f.write( "\nwire    [ NB_KEY-1:0        ]           tb_i_key                        [ RUN_TIME-1:0  ]   ;"                      )
        f.write( "\nwire    [ NB_IV-1:0         ]           tb_i_iv                         [ RUN_TIME-1:0  ]   ;"                      )
        f.write( "\nwire    [ NB_BLOCK/2-1:0    ]           tb_i_rf_static_aad_length       [ RUN_TIME-1:0  ]   ;"                      )
        f.write( "\nwire    [ NB_DATA-1:0       ]           tb_i_aad                        [ RUN_TIME-1:0  ]   ;"                      )
        f.write( "\nwire    [ NB_BLOCK/2-1:0    ]           tb_i_rf_static_plaintext_length [ RUN_TIME-1:0  ]   ;"                      )
        f.write( "\nwire    [ NB_DATA-1:0       ]           tb_i_plaintext                  [ RUN_TIME-1:0  ]   ;"                      )
        f.write( "\nwire    [ NB_INC_MODE-1:0   ]           tb_i_rf_static_inc_mode                             ;"                      )
        f.write( "\nwire                                    tb_i_rf_mode_gmac               [ RUN_TIME-1:0  ]   ;"                      )
        f.write( "\nwire                                    tb_i_rf_static_encrypt          [ RUN_TIME-1:0  ]   ;"                      )
        f.write( "\nwire                                    tb_i_clear_fault_flags          [ RUN_TIME-1:0  ]   ;"                      )
        f.write( "\nwire    [ NB_DATA-1:0       ]           tb_o_ciphertext                 [ RUN_TIME-1:0  ]   ;"                      )
        f.write( "\nwire                                    tb_o_fail                       [ RUN_TIME-1:0  ]   ;"                      )
        f.write( "\nwire                                    tb_o_sop                        [ RUN_TIME-1:0  ]   ;"                      )
        f.write( "\nwire                                    tb_o_valid                      [ RUN_TIME-1:0  ]   ;"                      )
        f.write( "\nwire    [ NB_BLOCK-1:0      ]           tb_o_tag                        [ RUN_TIME-1:0  ]   ;"                      )
        f.write( "\nwire                                    tb_o_tag_ready                  [ RUN_TIME-1:0  ]   ;"                      )
        f.write( "\n"                                                                                                                   )
        f.write( "\nwire    [ NB_DATA-1:0       ]           tb_gcm_aes_core_o_ciphertext                        ;"                      )
        f.write( "\nwire                                    tb_gcm_aes_core_o_fail                              ;"                      )
        f.write( "\nwire                                    tb_gcm_aes_core_o_sop                               ;"                      )
        f.write( "\nwire                                    tb_gcm_aes_core_o_valid                             ;"                      )
        f.write( "\nwire    [ NB_BLOCK-1:0      ]           tb_gcm_aes_core_o_tag                               ;"                      )
        f.write( "\nwire                                    tb_gcm_aes_core_o_tag_ready                         ;"                      )
        f.write( "\nwire                                    tb_gcm_aes_core_o_fault_sop_and_keyupdate           ;"                      )
        f.write( "\n"                                                                                                                   )
        f.write( "\nreg                                     tb_i_clock                                          ;"                      )
        f.write( "\n"                                                                                                                   )
        f.write( "\nwire    [ NB_DATA-1:0       ]           o_ciphertext                                        ;"                      )
        f.write( "\nwire                                    o_sop                                               ;"                      )
        f.write( "\nwire                                    o_valid                                             ;"                      )
        f.write( "\nwire    [ NB_BLOCK-1:0      ]           o_tag                                               ;"                      )
        f.write( "\nwire                                    o_tag_ready                                         ;"                      )
        f.write( "\nwire    [ NB_KEY-1:0        ]           i_key                                               ;"                      )
        f.write( "\nwire    [ NB_DATA-1:0       ]           i_plaintext                                         ;"                      )
        f.write( "\nwire    [ NB_DATA-1:0       ]           i_aad                                               ;"                      )
        f.write( "\nwire    [ NB_IV-1:0         ]           i_iv                                                ;"                      )
        f.write( "\nwire    [ NB_BLOCK/2-1:0    ]           i_rf_static_aad_length                              ;"                      )
        f.write( "\nwire    [ NB_BLOCK/2-1:0    ]           i_rf_static_plaintext_length                        ;"                      )
        f.write( "\nwire                                    i_sop                                               ;"                      )
        f.write( "\nwire                                    i_valid                                             ;"                      )
        f.write( "\nwire                                    i_key_update                                        ;"                      )
        f.write( "\nwire                                    i_rf_mode_gmac                                      ;"                      )
        f.write( "\nwire                                    i_rf_static_encrypt                                 ;"                      )
        f.write( "\nwire                                    i_clear_fault_flags                                 ;"                      )
        f.write( "\nwire                                    i_reset                                             ;"                      )
        f.write( "\n"                                                                                                                   )
        f.write( "\nreg                                     o_ciphertextOK_reg                                  ;"                      )
        f.write( "\nreg                                     o_tagOK_reg                                         ;"                      )
        f.write( "\n"                                                                                                                   )
        f.write( "\ninteger                                 clock_ctr                                           ;"                      )
        f.write( "\n"                                                                                                                   )
        f.write( "\n"                                                                                                                   )
        f.write( "\n// MISC."                                                                                                           )
        f.write( "\n// ----------------------------------------------------------------------------------------------------"            )
        f.write( "\ninitial begin"                                                                                                      )
        f.write( "\n    tb_i_clock  <= 0    ;"                                                                                          )
        f.write( "\n    clock_ctr   <= 0    ;"                                                                                          )
        f.write( "\nend"                                                                                                                )
        f.write( "\n"                                                                                                                   )
        f.write( "\nalways #5 tb_i_clock    <= ~tb_i_clock  ;"                                                                          )
        f.write( "\n"                                                                                                                   )
        f.write( "\nalways @( posedge tb_i_clock )"                                                                                     )
        f.write( "\nbegin"                                                                                                              )
        f.write( "\n    clock_ctr   <= clock_ctr + 1    ;"                                                                              )
        f.write( "\n    if ( clock_ctr == RUN_TIME + 1 )"                                                                               )
        f.write( "\n        $stop();"                                                                                                   )
        f.write( "\nend"                                                                                                                )
        f.write( "\n"                                                                                                                   )
        f.write( "\nassign  o_ciphertext                    = tb_o_ciphertext                   [clock_ctr] ;"                          )
        f.write( "\nassign  o_sop                           = tb_o_sop                          [clock_ctr] ;"                          )
        f.write( "\nassign  o_valid                         = tb_o_valid                        [clock_ctr] ;"                          )
        f.write( "\nassign  o_tag                           = tb_o_tag                          [clock_ctr] ;"                          )
        f.write( "\nassign  o_tag_ready                     = tb_o_tag_ready                    [clock_ctr] ;"                          )
        f.write( "\nassign  tb_i_rf_static_inc_mode         = 2'd2                                          ;"                          )
        f.write( "\nassign  i_plaintext                     = tb_i_plaintext                    [clock_ctr] ;"                          )
        f.write( "\nassign  i_key                           = tb_i_key                          [clock_ctr] ;"                          )
        f.write( "\nassign  i_aad                           = tb_i_aad                          [clock_ctr] ;"                          )
        f.write( "\nassign  i_iv                            = tb_i_iv                           [clock_ctr] ;"                          )
        f.write( "\nassign  i_rf_static_aad_length          = tb_i_rf_static_aad_length         [clock_ctr] ;"                          )
        f.write( "\nassign  i_rf_static_plaintext_length    = tb_i_rf_static_plaintext_length   [clock_ctr] ;"                          )
        f.write( "\nassign  i_sop                           = tb_i_sop                          [clock_ctr] ;"                          )
        f.write( "\nassign  i_valid                         = tb_i_valid                        [clock_ctr] ;"                          )
        f.write( "\nassign  i_key_update                    = tb_i_key_update                   [clock_ctr] ;"                          )
        f.write( "\nassign  i_rf_mode_gmac                  = tb_i_rf_mode_gmac                 [clock_ctr] ;"                          )
        f.write( "\nassign  i_rf_static_encrypt             = tb_i_rf_static_encrypt            [clock_ctr] ;"                          )
        f.write( "\nassign  i_clear_fault_flags             = tb_i_clear_fault_flags            [clock_ctr] ;"                          )
        f.write( "\nassign  i_reset                         = tb_i_reset                        [clock_ctr] ;"                          )
        f.write( "\n"                                                                                                                   )
        f.write( "\n"                                                                                                                   )
        f.write( "\n// COMPS."                                                                                                          )
        f.write( "\n// ----------------------------------------------------------------------------------------------------"            )
        f.write( "\nalways @( posedge tb_i_clock )"                                                                                     )
        f.write( "\nbegin"                                                                                                              )
        f.write( "\n    if (o_valid)"                                                                                                   )
        f.write( "\n        if (i_rf_static_plaintext_length[7])"                                                                       )
        f.write( "\n            o_ciphertextOK_reg  <=  (tb_gcm_aes_core_o_ciphertext[0+:128] == o_ciphertext[0+:128])  ;"              )
        f.write( "\n        else"                                                                                                       )
        f.write( "\n            o_ciphertextOK_reg  <=  (tb_gcm_aes_core_o_ciphertext == o_ciphertext)  ;"                              )
        f.write( "\nend"                                                                                                                )
        f.write( "\n"                                                                                                                   )
        f.write( "\nassign  o_ciphertextOK  =   (tb_gcm_aes_core_o_valid)   ?"                                                          )
        f.write( "\n                            ( (i_rf_static_plaintext_length[7])   ?"                                                )
        f.write( "\n                            (tb_gcm_aes_core_o_ciphertext[0+:128] == o_ciphertext[0+:128]) :"                       )
        f.write( "\n                            (tb_gcm_aes_core_o_ciphertext == o_ciphertext) ) : o_ciphertextOK_reg   ;"              )
        f.write( "\n"                                                                                                                   )
        f.write( "\nalways @( posedge tb_i_clock )"                                                                                     )
        f.write( "\nbegin"                                                                                                              )
        f.write( "\n    if (o_tag_ready)"                                                                                               )
        f.write( "\n        o_tagOK_reg     <=  (tb_gcm_aes_core_o_tag == o_tag)    ;"                                                  )
        f.write( "\nend"                                                                                                                )
        f.write( "\n"                                                                                                                   )
        f.write( "\nassign  o_tagOK         =   (tb_gcm_aes_core_o_tag_ready)   ?"                                                      )
        f.write( "\n                            (tb_gcm_aes_core_o_tag == o_tag) : o_tagOK_reg  ;"                                      )
        f.write( "\n"                                                                                                                   )
        f.write( "\nassign  o_compOK        =   (o_ciphertextOK == 1'b1) & (o_tagOK == 1'b1)    ;"                                      )
        f.write( "\n"                                                                                                                   )
        f.write( "\n"                                                                                                                   )
        f.write( "\n// GCM AES CORE."                                                                                                   )
        f.write( "\n// ----------------------------------------------------------------------------------------------------"            )
        f.write( "\ngcm_aes_core"                                                                                                       )
        f.write( "\n#("                                                                                                                 )
        f.write( "\n    .NB_BLOCK                       ( NB_BLOCK                                      ),"                             )
        f.write( "\n    .N_BLOCKS                       ( N_BLOCKS                                      ),"                             )
        f.write( "\n    .NB_DATA                        ( NB_DATA                                       ),"                             )
        f.write( "\n    .NB_KEY                         ( NB_KEY                                        ),"                             )
        f.write( "\n    .NB_IV                          ( NB_IV                                         ),"                             )
        f.write( "\n    .NB_INC_MODE                    ( NB_INC_MODE                                   ),"                             )
        f.write( "\n    .USE_LUT_IN_SUBBYTES            ( USE_LUT_IN_SUBBYTES                           ),"                             )
        f.write( "\n    .NB_N_MESSAGES                  ( NB_N_MESSAGES                                 )"                              )
        f.write( "\n)"                                                                                                                  )
        f.write( "\nu_gcm_aes_core_cipher"                                                                                              )
        f.write( "\n("                                                                                                                  )
        f.write( "\n    .o_ciphertext                   ( tb_gcm_aes_core_o_ciphertext                  ),"                             )
        f.write( "\n    .o_fail                         ( tb_gcm_aes_core_o_fail                        ),"                             )
        f.write( "\n    .o_sop                          ( tb_gcm_aes_core_o_sop                         ),"                             )
        f.write( "\n    .o_valid                        ( tb_gcm_aes_core_o_valid                       ),"                             )
        f.write( "\n    .o_tag                          ( tb_gcm_aes_core_o_tag                         ),"                             )
        f.write( "\n    .o_tag_ready                    ( tb_gcm_aes_core_o_tag_ready                   ),"                             )
        f.write( "\n    .o_fault_sop_and_keyupdate      ( tb_gcm_aes_core_o_fault_sop_and_keyupdate     ),"                             )
        f.write( "\n    .i_plaintext                    ( i_plaintext                                   ),"                             )
        f.write( "\n    .i_tag                          ( /*unused*/                                    ),"                             )
        f.write( "\n    .i_tag_ready                    ( /*unused*/                                    ),"                             )
        f.write( "\n    .i_rf_static_key                ( i_key                                         ),"                             )
        f.write( "\n    .i_rf_static_aad                ( i_aad                                         ),"                             )
        f.write( "\n    .i_rf_static_iv                 ( i_iv                                          ),"                             )
        f.write( "\n    .i_rf_static_length_aad         ( i_rf_static_aad_length                        ),"                             )
        f.write( "\n    .i_rf_static_length_plaintext   ( i_rf_static_plaintext_length                  ),"                             )
        f.write( "\n    .i_sop                          ( i_sop                                         ),"                             )
        f.write( "\n    .i_valid                        ( i_valid                                       ),"                             )
        f.write( "\n    .i_enable                       ( 1'b1                                          ),"                             )
        f.write( "\n    .i_update_key                   ( i_key_update                                  ),"                             )
        f.write( "\n    .i_rf_static_inc_mode           ( tb_i_rf_static_inc_mode                       ),"                             )
        f.write( "\n    .i_rf_mode_gmac                 ( i_rf_mode_gmac                                ),"                             )
        f.write( "\n    .i_rf_static_encrypt            ( i_rf_static_encrypt                           ),"                             )
        f.write( "\n    .i_clear_fault_flags            ( i_clear_fault_flags                           ),"                             )
        f.write( "\n    .i_reset                        ( i_reset                                       ),"                             )
        f.write( "\n    .i_clock                        ( tb_i_clock                                    )"                              )
        f.write( "\n);"                                                                                                                 )
        f.write( "\n"                                                                                                                   )
        f.write( "\n"                                                                                                                   )
        f.write( "\n// AUTOGENERATED VECTORS."                                                                                          )
        f.write( "\n// ----------------------------------------------------------------------------------------------------"            )

        for clk in range( 0, len(valid_vector) ):
            f.write( "\n// CLK no. %d/%d"                                                   % ( clk, len(valid_vector)                                  )   )
            f.write( "\n// *************************************************"                                                                               )
            # I VALID
            f.write(        "\nassign   tb_i_valid[%d]                      =   1'b%s;"     % ( clk, valid_vector               [ clk ]                 )   )


            # RESET
            f.write(        "\nassign   tb_i_reset[%d]                      =   1'b%s;"     % ( clk, reset_vector               [ clk ]                 )   )


            # SOP
            f.write(        "\nassign   tb_i_sop[%d]                        =   1'b%s;"     % ( clk, sop_vector                 [ clk ]                 )   )


            # KEY UPDATE
            f.write(        "\nassign   tb_i_key_update[%d]                 =   1'b%s;"     % ( clk, key_up_vector              [ clk ]                 )   )


            # KEY
            f.write(        "\nassign   tb_i_key[%d]                        =   256'h%s;"   % ( clk, key_vector                 [ clk ].encode("hex")   )   )


            # IV
            f.write(        "\nassign   tb_i_iv[%d]                         =   96'h%s;"    % ( clk, iv_vector                  [ clk ].encode("hex")   )   )


            # GMAC MODE
            f.write(        "\nassign   tb_i_rf_mode_gmac[%d]               =   1'b%s;"     % ( clk, gmac_mode_vector           [ clk ]                 )   )


            # ENCRYPT
            f.write(        "\nassign   tb_i_rf_static_encrypt[%d]          =   1'b%s;"     % ( clk, encrypt_vector             [ clk ]                 )   )


            # CLEAR FAULT FLAGS
            f.write(        "\nassign   tb_i_clear_fault_flags[%d]          =   1'b%s;"     % ( clk, clear_fault_flags_vector   [ clk ]                 )   )


            # AAD LENGTH
            aad_len_hex     = hex(int(aad_lenght_vector[clk])*256)
            aad_len_hex_str = '0'*(64/4-(len(aad_len_hex) - 2)) + aad_len_hex[2:len(aad_len_hex)]

            f.write(        "\nassign   tb_i_rf_static_aad_length[%d]       =   64'h%s;"    % ( clk, aad_len_hex_str                                    )   )


            # AAD
            if (aad_vector         [ clk ] != 'x'):
                if (debug): print "Entre motherrfucker!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
                f.write(    "\nassign   tb_i_aad[%d]                        =   256'h%s;"   % ( clk, aad_vector                 [ clk ].encode("hex")   )   )
            else:
                if ( clk == 0 ):
                    f.write(    "\nassign   tb_i_aad[%d]                        =   tb_i_aad[%d];"                                  % ( clk, clk        )   ) #256'h%s;"   % ( clk, x_256                                              )   )
                else:
                    f.write(    "\nassign   tb_i_aad[%d]                        =   tb_i_aad[%d];"                                  % ( clk, clk-1      )   ) #256'h%s;"   % ( clk, x_256                                              )   )


            # PLAINTEXT LENGTH
            ptx_len_hex     = hex(int(ptx_lenght_vector[clk])*128)
            ptx_len_hex_str = '0'*(64/4-(len(ptx_len_hex) - 2)) + ptx_len_hex[2:len(ptx_len_hex)]

            f.write(        "\nassign   tb_i_rf_static_plaintext_length[%d] =   64'h%s;"    % ( clk, ptx_len_hex_str                                    )   )


            # PLAINTEXT
            if (plaintext_vector   [ clk ] != 'x'):
                f.write(    "\nassign   tb_i_plaintext[%d]                  =   256'h%s;"   % ( clk, plaintext_vector           [ clk ].encode("hex")   )   )
            else:
                if ( clk == 0 ):
                    f.write(    "\nassign   tb_i_plaintext[%d]                  =   tb_i_plaintext[%d];"                            % ( clk, clk        )   ) #256'h%s;"   % ( clk, x_256                                              )   )
                else:
                    f.write(    "\nassign   tb_i_plaintext[%d]                  =   tb_i_plaintext[%d];"                            % ( clk, clk-1      )   ) #256'h%s;"   % ( clk, x_256                                              )   )


            # O VALID
            f.write(        "\nassign   tb_o_valid[%d]                      =   1'b%s;"     % ( clk, o_valid_vector             [ clk ]                 )   )



            # O SOP
            f.write(        "\nassign   tb_o_sop[%d]                        =   1'b%s;"     % ( clk, o_sop_vector               [ clk ]                 )   )


            # CIPHERTEXT
            if (ciphertext_vector  [ clk ] != 'x'):
                f.write(    "\nassign   tb_o_ciphertext[%d]                 =   256'h%s;"   % ( clk, ciphertext_vector          [ clk ].encode("hex")   )   )
            else:
                if ( clk == 0 ):
                    f.write(    "\nassign   tb_o_ciphertext[%d]                 =   tb_o_ciphertext[%d];"                           % ( clk, clk        )   ) #256'h%s;"   % ( clk, x_256                                              )   )
                else:
                    f.write(    "\nassign   tb_o_ciphertext[%d]                 =   tb_o_ciphertext[%d];"                           % ( clk, clk-1      )   ) #256'h%s;"   % ( clk, x_256                                              )   )


            # TAG READY
            f.write(        "\nassign   tb_o_tag_ready[%d]                  =   1'b%s;"     % ( clk, tag_ready_vector           [ clk ]                 )   )


            # TAG
            if (tag_vector         [ clk ] != 'x'):
                f.write(    "\nassign   tb_o_tag[%d]                        =   128'h%s;"   % ( clk, tag_vector                 [ clk ].encode("hex")   )   )
            else:
                if ( clk == 0 ):
                    f.write(    "\nassign   tb_o_tag[%d]                        =   tb_o_tag[%d];"                                  %  ( clk, clk       )   ) #128'h%s;"   % ( clk, x_128                                              )   )
                else:
                    f.write(    "\nassign   tb_o_tag[%d]                        =   tb_o_tag[%d];"                                  %  ( clk, clk-1     )   ) #128'h%s;"   % ( clk, x_128                                              )   )

            f.write( "\n"                                                                                                                                   )

        f.write( "\nendmodule"                                                                                                          )
        f.close()

# Test Frame Sequencer Class
# --------------------------------------------------------------------------------------------------------------------------
# This class puts together 2 or more basic frame sequences.
# --------------------------------------------------------------------------------------------------------------------------
class Test_Frame_Sequencer( object ):
    # Constructor
    # **********************************************************************************************************************
    def __init__(   self                            ,
                    frame_seq_type  = 'test_seq1'   ,
                    valid_mode      = 'random'      ,   # Must be setted every time. Posible values = random, max
                    gmac_mode       = 0             ,   # Must be setted every time. Posible values = 0, 1
                    k1_seqs         = 1             ,
                    k2_seqs         = 1             ,
                    m1_frames       = 1             ,
                    m2_frames       = 7             ,
                    m3_frames       = 7
                ):

        if (debug): print ""
        if (debug): print "==================================================================================================="
        if (debug): print "New Frame Test Sequence instance.Type -> ", frame_seq_type.upper()

        # Initialize Variables
        # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        self.frame_seq_type         = frame_seq_type
        self.valid_mode             = valid_mode
        self.gmac_mode              = gmac_mode
        self.k1_seqs                = k1_seqs
        self.k2_seqs                = k2_seqs
        self.m1_frames              = m1_frames
        self.m2_frames              = m2_frames
        self.m3_frames              = m3_frames
        self.frame_seq              = []
        self.frame_seq_list         = [ 'start1', 'start2', 'reset1', 'reset2', 'kup', 'pat_valid1', 'pat_valid2' ]
        self.startX_frame_seq_list  = self.frame_seq_list[0:2]
        self.other_frame_seq_list   = self.frame_seq_list[len(self.startX_frame_seq_list):len(self.frame_seq_list)]

        if( self.frame_seq_type == 'test_seq1' ):
            # [ 1 startX, K1 other ]
            ######################################################################################
            x   = randint( 0, len( self.startX_frame_seq_list )-1 )

            self.frame_seq  = [ Basic_Frame_Sequencer( frame_seq_type=self.startX_frame_seq_list[x]) ]

            for i in range( 0, self.k1_seqs ):
                y   = randint( 0, len( self.other_frame_seq_list )-1 )
                (self.frame_seq).append( Basic_Frame_Sequencer( frame_seq_type=self.other_frame_seq_list[y] ) )

            # for frame_seq in self.frame_seq:
                if (debug): print "Frame Seq Type   -> ", (frame_seq.frame_seq_type).upper()



# Main Class
# --------------------------------------------------------------------------------------------------------------------------
def main():
    print "*****************************************************************************************************************"
    print "* Main                                                                                                          *"
    print "*****************************************************************************************************************"

    # test_seq1    = Test_Frame_Sequencer()









    generate_basic_seqs     = 1
    if ( generate_basic_seqs ):
        # test_frame_seq              = Basic_Frame_Sequencer()

        # start1_frame_seq            = Basic_Frame_Sequencer( frame_seq_type='start1', m1_frames=1, m2_frames=50 ) #50

        # start2_frame_seq            = Basic_Frame_Sequencer( frame_seq_type='start2', m1_frames=1, m2_frames=1, m3_frames=50, n_key_ups=3)

        # reset1_frame_seq            = Basic_Frame_Sequencer( frame_seq_type='reset1', m1_frames=1, m2_frames=50)

        # reset2_frame_seq            = Basic_Frame_Sequencer( frame_seq_type='reset2', m1_frames=1, m2_frames=50, n_resets=4)

        kup_frame_seq               = Basic_Frame_Sequencer( frame_seq_type='kup', m1_frames=1, m2_frames=50, n_key_ups=1)

        # pat_valid1_frame_seq        = Basic_Frame_Sequencer( frame_seq_type='pat_valid1', m1_frames=1, m2_frames=50)

        # pat_valid2_frame_seq        = Basic_Frame_Sequencer( frame_seq_type='pat_valid2', m1_frames=1, m2_frames=50)

        # pat_sop1_frame_seq          = Basic_Frame_Sequencer( frame_seq_type='pat_sop1', m1_frames=1, m2_frames=50)

        # pat_sop2_frame_seq          = Basic_Frame_Sequencer( frame_seq_type='pat_sop_b4_gctr', m1_frames=1, m2_frames=50)

        # pat_sop1_frame_seq          = Basic_Frame_Sequencer( frame_seq_type='pat_sop_b4_ghash', m1_frames=1, m2_frames=50)

        # pat_sop1_frame_seq          = Basic_Frame_Sequencer( frame_seq_type='pat_sop_pos_ghash', m1_frames=1, m2_frames=50)

        # pat_sop1_frame_seq          = Basic_Frame_Sequencer( frame_seq_type='pat_rand_sops', m1_frames=1, m2_frames=50)


    generate_all_frames_TEST = 0
    if ( generate_all_frames_TEST ):
        # DEFAULT
        ########################################################################################
        # This Frame Type has the following characteristics:
        # - SOP Mode                        = DEFAULT < single >
        # - RESET Mode                      = DEFAULT < null >
        # - VALID Mode                      = DEFAULT < random >
        # - GMAC Mode                       = DEFAULT < off >
        # - IV                              = DEFAULT < random >
        # - KEY Mode                        = DEFAULT < random >
        # - KEY UP Mode                     = DEFAULT < null >
        # - N KEY UPs                       = DEFAULT < 0 >
        # - PTX Mode                        = DEFAULT < random >
        # - PTX Len                         = DEFAULT < random >
        # - AAD Mode                        = DEFAULT < random >
        # - PTX Len                         = DEFAULT < random >
        ########################################################################################
        test_frame                          = Frame()
        test_max_valid_frame                = Frame(valid_mode='max_valid')

        test_gmac_frame                     = Frame(gmac_mode=1)
        test_gmac_max_valid_frame           = Frame(valid_mode='max_valid', gmac_mode=1)

        # RANDOM
        ########################################################################################
        # This Frame Type has the following characteristics:
        # - SOP Mode                        = SINGLE
        # - RESET Mode                      = NULL
        # - VALID Mode                      = CUSTOM < max_valid, random >
        # - GMAC Mode                       = CUSTOM < on, off >
        # - IV                              = RANDOM
        # - KEY Mode                        = CUSTOM < argument key >
        # - KEY UP Mode                     = NULL
        # - N KEY UPs                       = NULL
        # - PTX Mode                        = RANDOM
        # - PTX Len                         = RANDOM
        # - AAD Mode                        = RANDOM
        # - PTX Len                         = RANDOM
        ########################################################################################
        random_frame                        = Frame( frame_type='random', valid_mode='random', gmac_mode=0, key_mode='custom', key=key_std )
        random_max_val_frame                = Frame( frame_type='random', valid_mode='max_valid', gmac_mode=0, key_mode='custom', key=key_std )

        random_gmac_frame                   = Frame( frame_type='random', valid_mode='random', gmac_mode=1, key_mode='custom', key=key_std )
        random_gmac_max_val_frame           = Frame( frame_type='random', valid_mode='max_valid', gmac_mode=1, key_mode='custom', key=key_std )

        # N KEY UPDATES
        ########################################################################################
        # This Frame Type has the following characteristics:
        # - SOP Mode                        = SINGLE
        # - RESET Mode                      = NULL
        # - VALID Mode                      = CUSTOM < max_valid, random >
        # - GMAC Mode                       = CUSTOM < on, off >
        # - IV                              = RANDOM
        # - KEY Mode                        = CUSTOM < argument key >
        # - KEY UP Mode                     = MULTIPLE
        # - N KEY UPs                       = CUSTOM < argument n_key_ups >
        # - PTX Mode                        = RANDOM
        # - PTX Len                         = RANDOM
        # - AAD Mode                        = RANDOM
        # - PTX Len                         = RANDOM
        ########################################################################################
        n_key_ups_frame                     = Frame( frame_type='n_key_ups', valid_mode='random', gmac_mode=0, key_mode='custom', key=key_std, n_key_ups=2 )
        n_key_ups_max_val_frame             = Frame( frame_type='n_key_ups', valid_mode='max_valid', gmac_mode=0, key_mode='custom', key=key_std, n_key_ups=2 )

        n_key_ups_gmac_frame                = Frame( frame_type='n_key_ups', valid_mode='random', gmac_mode=1, key_mode='custom', key=key_std, n_key_ups=2 )
        n_key_ups_gmac_max_val_frame        = Frame( frame_type='n_key_ups', valid_mode='max_valid', gmac_mode=1, key_mode='custom', key=key_std, n_key_ups=2 )

        # RESET INITIAL
        ########################################################################################
        # This Frame Type has the following characteristics:
        # - SOP Mode                        = SINGLE
        # - RESET Mode                      = SINGLE
        # - VALID Mode                      = CUSTOM < max_valid, random >
        # - GMAC Mode                       = CUSTOM < on, off >
        # - IV                              = CUSTOM < argument iv >
        # - KEY Mode                        = CUSTOM < argument key >
        # - KEY UP Mode                     = NULL
        # - N KEY UPs                       = NULL
        # - PTX Mode                        = CUSTOM < argument ptx_len >
        # - PTX Len                         = RANDOM
        # - AAD Mode                        = CUSTOM < argument aad_len >
        # - AAD Len                         = RANDOM
        ########################################################################################
        reset_init_frame                    = Frame( frame_type='reset_init', valid_mode='random', gmac_mode=0, key_mode='custom', key=key_std, iv=os.urandom(12), ptx_len=5, aad_len=2 )
        reset_init_max_val_frame            = Frame( frame_type='reset_init', valid_mode='max_valid', gmac_mode=0, key_mode='custom', key=key_std, iv=os.urandom(12), ptx_len=5, aad_len=2 )

        reset_init_gmac_frame               = Frame( frame_type='reset_init', valid_mode='random', gmac_mode=1, key_mode='custom', key=key_std, iv=os.urandom(12), ptx_len=5, aad_len=2 )
        reset_init_gmac_max_val_frame       = Frame( frame_type='reset_init', valid_mode='max_valid', gmac_mode=1, key_mode='custom', key=key_std, iv=os.urandom(12), ptx_len=5, aad_len=2 )

        # N RESETS
        ########################################################################################
        # This Frame Type has the following characteristics:
        # - SOP Mode                        = SINGLE
        # - RESET Mode                      = MULTIPLE
        # - VALID Mode                      = CUSTOM < max_valid, random >
        # - GMAC Mode                       = CUSTOM < on, off >
        # - IV                              = CUSTOM < argument iv >
        # - KEY Mode                        = CUSTOM < argument key >
        # - KEY UP Mode                     = NULL
        # - N KEY UPs                       = NULL
        # - PTX Mode                        = CUSTOM < argument ptx_len >
        # - PTX Len                         = RANDOM
        # - AAD Mode                        = CUSTOM < argument aad_len >
        # - AAD Len                         = RANDOM
        ########################################################################################
        n_resets_frame                      = Frame( frame_type='n_resets', valid_mode='random', gmac_mode=0, key_mode='custom', key=key_std, iv=os.urandom(12), ptx_len=5, aad_len=3, n_resets=4 )
        n_resets_max_val_frame              = Frame( frame_type='n_resets', valid_mode='max_valid', gmac_mode=0, key_mode='custom', key=key_std, iv=os.urandom(12), ptx_len=5, aad_len=3, n_resets=5 )

        n_resets_gmac_frame                 = Frame( frame_type='n_resets', valid_mode='random', gmac_mode=1, key_mode='custom', key=key_std, iv=os.urandom(12), ptx_len=5, aad_len=3, n_resets=4 )
        n_resets_gmac_max_val_frame         = Frame( frame_type='n_resets', valid_mode='max_valid', gmac_mode=1, key_mode='custom', key=key_std, iv=os.urandom(12), ptx_len=5, aad_len=3, n_resets=5 )

        # INITIAL
        ########################################################################################
        # This Frame Type has the following characteristics:
        # - SOP Mode                        = SINGLE
        # - RESET Mode                      = SINGLE
        # - VALID Mode                      = CUSTOM < max_valid, random >
        # - GMAC Mode                       = CUSTOM < on, off >
        # - IV                              = CUSTOM < argument iv >
        # - KEY Mode                        = CUSTOM < argument key >
        # - KEY UP Mode                     = SINGLE
        # - N KEY UPs                       = 1
        # - PTX Mode                        = CUSTOM < argument ptx_len >
        # - PTX Len                         = RANDOM
        # - AAD Mode                        = CUSTOM < argument aad_len >
        # - AAD Len                         = RANDOM
        ########################################################################################
        initial_frame                       = Frame( frame_type='init', valid_mode='random', gmac_mode=0, key_mode='custom', key=key_std, iv=os.urandom(12), ptx_len=5, aad_len=4 )
        initial_max_valid_frame             = Frame( frame_type='init', valid_mode='max_valid', gmac_mode=0, key_mode='custom', key=key_std, iv=os.urandom(12), ptx_len=5, aad_len=4 )

        initial_gmac_frame                  = Frame( frame_type='init', valid_mode='random', gmac_mode=1, key_mode='custom', key=key_std, iv=os.urandom(12), ptx_len=5, aad_len=4 )
        initial_gmac_max_valid_frame        = Frame( frame_type='init', valid_mode='max_valid', gmac_mode=1, key_mode='custom', key=key_std, iv=os.urandom(12), ptx_len=5, aad_len=4 )

        # CUSTOM LENGTH ( AAD, Plaintext)
        ########################################################################################
        # This Frame Type has the following characteristics:
        # - SOP Mode                        = SINGLE
        # - RESET Mode                      = NULL
        # - VALID Mode                      = CUSTOM < max_valid, random >
        # - GMAC Mode                       = CUSTOM < on, off >
        # - IV                              = RANDOM
        # - KEY Mode                        = CUSTOM < argument key >
        # - KEY UP Mode                     = NULL
        # - N KEY UPs                       = NULL
        # - PTX Mode                        = CUSTOM < argument ptx_len >
        # - PTX Len                         = RANDOM
        # - AAD Mode                        = CUSTOM < argument aad_len >
        # - AAD Len                         = RANDOM
        ########################################################################################
        custom_len_frame                    = Frame( frame_type='custom_len', valid_mode='random', gmac_mode=0, key_mode='custom', key=key_std, ptx_len=4, aad_len=2 )
        custom_len_max_val_frame            = Frame( frame_type='custom_len', valid_mode='max_valid', gmac_mode=0, key_mode='custom', key=key_std, ptx_len=4, aad_len=2 )

        custom_len_gmac_frame               = Frame( frame_type='custom_len', valid_mode='random', gmac_mode=1, key_mode='custom', key=key_std, ptx_len=4, aad_len=2 )
        custom_len_gmac_max_val_frame       = Frame( frame_type='custom_len', valid_mode='max_valid', gmac_mode=1, key_mode='custom', key=key_std, ptx_len=4, aad_len=2 )

        # CUSTOM LENGTH+IV ( AAD, Plaintext + IV)
        ########################################################################################
        # This Frame Type has the following characteristics:
        # - SOP Mode                        = SINGLE
        # - RESET Mode                      = NULL
        # - VALID Mode                      = CUSTOM < max_valid, random >
        # - GMAC Mode                       = CUSTOM < on, off >
        # - IV                              = CUSTOM < argument iv >
        # - KEY Mode                        = CUSTOM < argument key >
        # - KEY UP Mode                     = NULL
        # - N KEY UPs                       = NULL
        # - PTX Mode                        = CUSTOM < argument ptx_len >
        # - PTX Len                         = RANDOM
        # - AAD Mode                        = CUSTOM < argument aad_len >
        # - AAD Len                         = RANDOM
        ########################################################################################
        custom_len_iv_frame                 = Frame( frame_type='custom_len+iv', valid_mode='random', gmac_mode=0, key_mode='custom', key=key_std, iv=os.urandom(12), ptx_len=4, aad_len=4 )
        custom_len_iv_max_val_frame         = Frame( frame_type='custom_len+iv', valid_mode='max_valid', gmac_mode=0, key_mode='custom', key=key_std, iv=os.urandom(12), ptx_len=4, aad_len=4 )

        custom_len_iv_gmac_frame            = Frame( frame_type='custom_len+iv', valid_mode='random', gmac_mode=1, key_mode='custom', key=key_std, iv=os.urandom(12), ptx_len=4, aad_len=4 )
        custom_len_iv_gmac_max_val_frame    = Frame( frame_type='custom_len+iv', valid_mode='max_valid', gmac_mode=1, key_mode='custom', key=key_std, iv=os.urandom(12), ptx_len=4, aad_len=4 )

        # CUSTOM IV
        ########################################################################################
        # This Frame Type has the following characteristics:
        # - SOP Mode                        = SINGLE
        # - RESET Mode                      = NULL
        # - VALID Mode                      = CUSTOM < max_valid, random >
        # - GMAC Mode                       = CUSTOM < on, off >
        # - IV                              = CUSTOM < argument iv >
        # - KEY Mode                        = CUSTOM < argument key >
        # - KEY UP Mode                     = NULL
        # - N KEY UPs                       = NULL
        # - PTX Mode                        = RANDOM
        # - PTX Len                         = RANDOM
        # - AAD Mode                        = RANDOM
        # - AAD Len                         = RANDOM
        ########################################################################################
        custom_iv_frame                     = Frame( frame_type='custom_iv', valid_mode='random', gmac_mode=0, key_mode='custom', key=key_std, iv=os.urandom(12) )
        custom_iv_max_val_frame             = Frame( frame_type='custom_iv', valid_mode='max_valid', gmac_mode=0, key_mode='custom', key=key_std, iv=os.urandom(12) )

        custom_iv_gmac_frame                = Frame( frame_type='custom_iv', valid_mode='random', gmac_mode=1, key_mode='custom', key=key_std, iv=os.urandom(12) )
        custom_iv_gmac_max_val_frame        = Frame( frame_type='custom_iv', valid_mode='max_valid', gmac_mode=1, key_mode='custom', key=key_std, iv=os.urandom(12) )


# MODULE NAME
# ==========================================================================================================================
if __name__ == "__main__":
    main()