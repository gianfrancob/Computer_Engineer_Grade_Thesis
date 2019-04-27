#!/usr/bin/env python
import os
import sys
import numpy               as     np
import time
import math 
#import matplotlib.pyplot   as     mpl
from   random              import gauss, randint, seed, random
#from   scipy.stats         import norm
import cPickle             as     cpickle
#from   scipy.interpolate   import interp1d
#from sympy import f_binomial


################################
class Frame(object):

    #----------------------------
    def __init__( self, type_f="normal_random", aad_len=2, aad_type="random", pt_len=4, pt_type="random", iv_type="random", key_type="random", key_update_mode="null", reset_mode="null", valid_mode="random", sop_mode="single" ): #-- const
        self.tp_f   = type_f
        self.pt     = []

        #self.aad_l  = aad_len
        #self.add_t  = 

        print 'Se creo un frame tipo : %s'%(self.tp_f)

        if ( self.tp_f == 'normal_random' ):
            self.aad_l  = aad_len
            self.aad_t  = "random"
            self.pt_l   = pt_len
            self.pt_t   = "random"
            self.iv_t   = "random"
            self.iv     = randint(0, 2**96)
            self.key_t  = "random"
            self.key    = randint(0, 2**256)
            self.ku_mod = "null"


            for n in xrange( 0, randint(2,7) ):
                (self.pt).append( randint(10,20) )

        return ;

    def print_x(self):
        print 'print_x: %s'%(self.tp_f)
        return ;

    def print_pt(self):
        print self.pt


################################
class Frame_simple_seq(object):

    #---------------------------
    def __init__( self, type_ss, number_of_frames ):
        self.tp_ss = type_ss
        self.nf    = number_of_frames
        self.frame_seq = []
        if ( self.tp_ss == "normal" ):
            for n in xrange(0,self.nf):
                (self.frame_seq).append( Frame("normal") )
        print 'Se creo una sequencia simple de frames de tipo:%s y de %d frames'%( self.tp_ss, self.nf )

    def print_frames( self ):
        for frame in self.frame_seq:
            print 'frame:'
            frame.print_pt()




###############################
def main():



    print 'AAAAAAAAAAAA'

    frame_x = Frame( 'random' )
    frame_x.print_x()

    seq_1 = Frame_simple_seq( 'normal', 3 )

    print "HOLA:%d"%( randint(0,50) ), "=================="
    seq_1.print_frames()

    print "======>>>>>>%s"%(seq_1.tp_ss)
    seq_1.tp_ss = "super"
    print "======>>>>>>%s"%(seq_1.tp_ss)

    return



###############################
if __name__ == "__main__":
    main()