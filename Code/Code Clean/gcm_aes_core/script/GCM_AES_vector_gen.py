import os
import argparse

from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives.ciphers import (
    Cipher, algorithms, modes
)

parser = argparse.ArgumentParser(fromfile_prefix_chars='@')
parser.add_argument("-vectors"      , help="specifies how many vectors will be generated", default=1)
parser.add_argument("-ptext_lenght" , help="plain text lengh in bytes defaul 32", default=32)
parser.add_argument("-print_test" 	, help="print the vector generated divided in variables and index as a test just copy paste", default=0)
args = parser.parse_args()

iv_str  = "cafebabefacedbaddecaf888"
# iv_str  = "012345670123456789abcdef"
iv      = iv_str.decode("hex")
print "len(iv) = " +  str(len(iv)) + " -> 'd" + str(len(iv)*8)
key_str = "feffe9928665731c6d6a8f9467308308feffe9928665731c6d6a8f9467308308"  # Standart key
# key_str =   "88889999aaaabbbbccccddddeeeeffff88889999aaaabbbbccccddddeeeeffff"
key = key_str.decode("hex")
print "len(key) = " +  str(len(key)) + " -> 'd" + str(len(key)*8)
associated_data_str  = ""
associated_data_str  = "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
associated_data_str += "00000000000000000000000000000000"
associated_data_str += "00000000000000000000000000000000"
associated_data_str += "00000000000000000000000000000000"
associated_data_str += "00000000000000000000000000000000"
associated_data_str += "00000000000000000000000000000000"

# associated_data_str = "00000000000000001111111111111111222222222222222233333333333333334444444444444444555555555555555566666666666666667777777777777777"
# associated_data_str   = "11111111111111112222222222222222333333333333333344444444444444440000000000000000000000000000000000000000000000000000000000000000"

# associated_data_str =  "1111111111111111222222222222222233333333333333334444444444444444"
# associated_data_str+=  "5555555555555555666666666666666677777777777777778888888888888888"

# associated_data_str +=  "0000000000000000000000000000000000000000000000000000000000000000"
# associated_data_str     = "11111111111111112222222222222222333333333333333344444444444444440000000000000000000000000000000000000000000000000000000000000000"
# associated_data_str = ""
associated_data      = associated_data_str.decode("hex")
print "len(associated_data) = " +  str(len(associated_data)) + " -> 'd" + str(len(associated_data)*8)

plaintext_str        = "d9313225f88406e5a55909c5aff5269a86a7a9531534f7da2e4c303d8a318a721c3c0c95956809532fcf0e2449a6b525b16aedf5aa0de657ba637b391aafd255"
plaintext_str       += "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
plaintext_str       += "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
plaintext_str       += "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
plaintext_str       += "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
plaintext_str       += "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
plaintext_str       += "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
# plaintext_str       += "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
# plaintext_str       += "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
# plaintext_str     += "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc"
# plaintext_str     +=                                                                 "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc"

# plaintext_str     = ""

plaintext            = plaintext_str.decode("hex")

gmac = 0

if ( bool(gmac) ):
    # Construct an AES-GCM Cipher object with the given key and a
    # randomly generated IV.

    encryptor = Cipher(
        algorithms.AES(key),
        modes.GCM(iv),
        backend=default_backend()
    ).encryptor()

    # associated_data will be authenticated but not encrypted,
    # it must also be passed in on decryption.
    encryptor.authenticate_additional_data(associated_data)

    # Encrypt the plaintext and get the associated ciphertext.
    # GCM does not require padding.
    plaintext = encryptor.update(plaintext) + encryptor.finalize()


print "len(plaintext) = " +  str(len(plaintext)) + " -> 'd" + str(len(plaintext)*8)

for x in range(int(args.vectors)):
	# iv                 = os.urandom(12)
	# key                = os.urandom(32)
	# associated_data    = os.urandom(64)
	# plaintext          = os.urandom(int(args.ptext_lenght))
	n_word = int(args.ptext_lenght) / 32

	encryptor = Cipher(
	    algorithms.AES(key),
	    modes.GCM(iv),
	    backend=default_backend()
	).encryptor()

	# associated_data will be authenticated but not encrypted,
	# it must also be passed in on decryption.
	encryptor.authenticate_additional_data(associated_data)

	# Encrypt the plaintext and get the associated ciphertext.
	# GCM does not require padding.
	ciphertext = encryptor.update(plaintext) + encryptor.finalize()

	print "########  Vector " + str(x) + " ########"
	if(bool(args.print_test)):

		for i in range(0, len(key), 8):
			print "sc_key[%d] = 0x%s;" % ((i/8),key[i:i+8].encode("hex"))

		print "sc_iv[1] = 0x%s0000;" % iv[0:4].encode("hex")
		print "sc_iv[0] = 0x%s;" % iv[4:12].encode("hex")

		for i in range(0, len(associated_data), 8):
			print "sc_aad[%d] = 0x%s;" % (len(associated_data)/8-1-(i/8),associated_data[i:i+8].encode("hex"))

		for i in range(0, int(args.ptext_lenght), 32):
			for j in range (3,-1,-1):
				print "sc_plaintext[%d] = 0x%s;" % (int(args.ptext_lenght)/8-1-(j+4*i/32), plaintext[i+(3-j)*8:i+(3-j+1)*8].encode("hex"))

		for i in range(0, int(args.ptext_lenght), 32):
			for j in range (3,-1,-1):
				print "EXPECT_EQ(data[%d], 0x%s)" % (int(args.ptext_lenght)/8-1-(j+4*i/32), ciphertext[i+(3-j)*8:i+(3-j+1)*8].encode("hex"))

		for i in range(0, len(encryptor.tag), 8):
			print "EXPECT_EQ(tag[%d] , 0x%s)" % (len(encryptor.tag)/8-1-(i/8),encryptor.tag[i:i+8].encode("hex"))

	else:
		print "Key: " + key.encode("hex")
		print "IV: " + iv.encode("hex")
		print "AAD: " + associated_data.encode("hex")
		print "PTEXT: " + plaintext.encode("hex")
		print "D: " + ciphertext.encode("hex")
		print "T: " + encryptor.tag.encode("hex")
