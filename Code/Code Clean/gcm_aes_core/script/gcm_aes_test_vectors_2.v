module gcm_aes_test_vector
#(
     //PARAMETERS.
     parameter       NB_BLOCK      =   128                      ,
     parameter       N_BLOCKS      =   2                        ,
     parameter       NB_DATA       =   N_BLOCKS*NB_BLOCK        ,
     parameter       NB_CLK_CTR    =   10                       ,
     parameter       LOG2_FRAMES   =   4
)
(
     // OUTPUTS.
     output  wire    [ NB_DATA-1:0       ]       o_key          ,
     output  wire    [ NB_BLOCK-1:0      ]       o_iv           ,
     output  wire    [ NB_DATA-1:0       ]       o_aad          ,
     output  wire    [ NB_DATA-1:0       ]       o_plaintext    ,
     output  wire    [ NB_DATA-1:0       ]       o_ciphertext   ,
     output  wire    [ NB_BLOCK-1:0      ]       o_tag          ,
     // INPUTS.
     input   wire    [ NB_CLK_CTR-1:0    ]       i_clk_ctr      ,
     input   wire    [ LOG2_FRAMES-1:0   ]       i_frame_ctr
);

// LOCALPARAMETERS.
// ----------------------------------------------------------------------------------------------------
// none so far

// INTERNAL SIGNALS.
// ----------------------------------------------------------------------------------------------------
wire     [ NB_BLOCK-1:0  ]           key         [ LOG2_FRAMES-1:0 ] ;
wire     [ NB_BLOCK-1:0  ]           iv          [ LOG2_FRAMES-1:0 ] ;
wire     [ NB_BLOCK-1:0  ]           aad         [ LOG2_FRAMES-1:0 ] ;
wire     [ NB_BLOCK-1:0  ]           plaintext   [ LOG2_FRAMES-1:0 ] ;
wire     [ NB_BLOCK-1:0  ]           ciphertext  [ LOG2_FRAMES-1:0 ] ;
wire     [ NB_BLOCK-1:0  ]           tag         [ LOG2_FRAMES-1:0 ] ;

// FRAME No. 0
// ===================================================================================================
assign   key[0]             =   256'hfeffe9928665731c6d6a8f9467308308feffe9928665731c6d6a8f9467308308;
assign   iv[0]              =   96'hb53762581d0a8e086d499caf;
assign   aad[0][0]          =   256'hcc26245b40cb0a647c7027c1201f743534e2a7cb7b142e2f12bd239ed3e869a4;
assign   tag[0]             =   128'he6230f858af62a7f27fbc1f98ef7aa8b;


// FRAME No. 1
// ===================================================================================================
assign   key[1]             =   256'hfeffe9928665731c6d6a8f9467308308feffe9928665731c6d6a8f9467308308;
assign   iv[1]              =   96'hc84c37e8e87ab06fd03e6d4e;
assign   aad[1][0]          =   256'h4d9cf2411bc08ae851024905fd34a70d007d1397bc25cb8a74c178d324ed46fa;
assign   plaintext[1][0]    =   128'h45d1a118b1b77de7d12313b2807d23a7;
assign   ciphertext[1][0]   =   128'hf9f58d836cbd843f59ca0ffc71bb1fb0;
assign   tag[1]             =   128'h44792e69d59427406e91400f9952943c;


// FRAME No. 2
// ===================================================================================================
assign   key[2]             =   256'hfeffe9928665731c6d6a8f9467308308feffe9928665731c6d6a8f9467308308;
assign   iv[2]              =   96'h0e2b22aa6b7ef8358e445b8e;
assign   aad[2][0]          =   256'h22d76473223361d310b7ff156ea52c7b03a621ae806eac36d85c93a1c4bd7306;
assign   plaintext[2][0]    =   128'ha50288915136b1fb4ef126302b113241;
assign   plaintext[2][1]    =   128'hb3049626f454de0b4dca811594155e63;
assign   ciphertext[2][0]   =   128'h7c29938f6b9f1eab22d167944cd90967;
assign   ciphertext[2][1]   =   128'h2e9d78383327f1c6941bb3e7c4dce9c2;
assign   tag[2]             =   128'h89413943d4b95a968fda4ebbbf76774b;


// FRAME No. 3
// ===================================================================================================
assign   key[3]             =   256'hfeffe9928665731c6d6a8f9467308308feffe9928665731c6d6a8f9467308308;
assign   iv[3]              =   96'h5e766a32f3bda8c8382a4c0d;
assign   aad[3][0]          =   256'h443cbad5de4563192b9367db9e17c6addb3e2233dea29c21a00ff4a71b8d10db;
assign   plaintext[3][0]    =   128'hee26b7a7a2708ac13f784ccc430cfeba;
assign   plaintext[3][1]    =   128'h823ca0574017bb306e58511deb9b696b;
assign   plaintext[3][2]    =   128'h3a182c473f33e51ef8f8eef96a54bbb1;
assign   ciphertext[3][0]   =   128'h352e6125531700b61813ff7fda6fcc7f;
assign   ciphertext[3][1]   =   128'h1a373159761864c2af934ebf01ea8907;
assign   ciphertext[3][2]   =   128'hc12479e7d34ae73f81e780ac0e85485b;
assign   tag[3]             =   128'hc2a8d671bf77b3e359e4f0ff824f6a7b;


// FRAME No. 4
// ===================================================================================================
assign   key[4]             =   256'hfeffe9928665731c6d6a8f9467308308feffe9928665731c6d6a8f9467308308;
assign   iv[4]              =   96'h727bb2ed57bd61e4dcd4ba5c;
assign   aad[4][0]          =   256'h211e4d3e8047be2baf9056ca6fef9cb9c189e4acc1872b7453c09235bae18257;
assign   plaintext[4][0]    =   128'h64c7ef624fadb225d73c3470b4a3fb65;
assign   plaintext[4][1]    =   128'h7fec778f6481a321f839abdf0b48f291;
assign   plaintext[4][2]    =   128'hcd0d665e4f844def6dace19795f6f7cd;
assign   plaintext[4][3]    =   128'hb4a4bff1e2405ba149550f0fd6256687;
assign   ciphertext[4][0]   =   128'h5e79a3344a47281a3d78f35aef84a7f4;
assign   ciphertext[4][1]   =   128'hdeea21b4850040e0f8c9355ffcce889d;
assign   ciphertext[4][2]   =   128'hc021c54d0b389ea0a950481024374f4b;
assign   ciphertext[4][3]   =   128'hcacfa65e7ff0cbd551e098fddef81964;
assign   tag[4]             =   128'hbdaa4c00f0c7ad913760f2d5551377d2;


// FRAME No. 5
// ===================================================================================================
assign   key[5]             =   256'hfeffe9928665731c6d6a8f9467308308feffe9928665731c6d6a8f9467308308;
assign   iv[5]              =   96'h26934de8e4df66727609a887;
assign   aad[5][0]          =   256'h41ceeb5ba1e80f9901cad08d29509158eb6ebb02b492c8abe1bb2e6b5b058285;
assign   plaintext[5][0]    =   128'hdfe2102b927af45167f3968c77b19778;
assign   plaintext[5][1]    =   128'hd0f7a396a42c4b04b23f1b27a90c9d4c;
assign   plaintext[5][2]    =   128'h23bdc953beba4067ddfdebce4ae26e17;
assign   plaintext[5][3]    =   128'h67243217f6d3ef45ce84529ade65e22a;
assign   plaintext[5][4]    =   128'hc8b160e63e2fb30ccdfd09a5082a49be;
assign   ciphertext[5][0]   =   128'h2f8a7388c5afeff709fca4eb9ac28392;
assign   ciphertext[5][1]   =   128'h77e038bf397c72844caba20a3e7b8bbf;
assign   ciphertext[5][2]   =   128'h21752c1d97fbe1bf4faa92080e0b2690;
assign   ciphertext[5][3]   =   128'h17774509e379c676b172be00f465397c;
assign   ciphertext[5][4]   =   128'h55799f9f832bbe1583c479cf20e623a7;
assign   tag[5]             =   128'h0a7b2d1f233e408e2e51fb1a4f8b665a;


// FRAME No. 6
// ===================================================================================================
assign   key[6]             =   256'hfeffe9928665731c6d6a8f9467308308feffe9928665731c6d6a8f9467308308;
assign   iv[6]              =   96'hf31e699c5aa3ccdc7a18b6e8;
assign   aad[6][0]          =   256'h45c49a552b63bc96e81c890f5b358425b766313aad33eab8e9a0c50d747e50e6;
assign   plaintext[6][0]    =   128'h8fdb1b5a1bce1ae170568cc0f23735a8;
assign   plaintext[6][1]    =   128'h0b115e00c98f4559929993a99a544277;
assign   plaintext[6][2]    =   128'he1c19db37337afc2d010937d20ddbc04;
assign   plaintext[6][3]    =   128'h406c961f070e6a2e041f4e90edece4d1;
assign   plaintext[6][4]    =   128'h018bde6c5ae743b8a2ec64bf5582ddbe;
assign   plaintext[6][5]    =   128'h7b34b10e90d9c59a8b73603fe57420aa;
assign   ciphertext[6][0]   =   128'h9d91855eab3a3a38e0ca3d97c4375fdf;
assign   ciphertext[6][1]   =   128'h17cc2163c26f0abf41d5e6a7740f00bc;
assign   ciphertext[6][2]   =   128'h085b9d102aaed565a1fb0766ebb5f56f;
assign   ciphertext[6][3]   =   128'h08c23df014f6fb436a0695345afc9ab9;
assign   ciphertext[6][4]   =   128'h9ca642ca767beb50e7223f66e1159639;
assign   ciphertext[6][5]   =   128'h0ddfdbc311f8c3b33e8a58ea62359fe8;
assign   tag[6]             =   128'he918d946e4de0e7218b86803f48b81e8;


// FRAME No. 7
// ===================================================================================================
assign   key[7]             =   256'hfeffe9928665731c6d6a8f9467308308feffe9928665731c6d6a8f9467308308;
assign   iv[7]              =   96'h22a5247190727744429e0576;
assign   aad[7][0]          =   256'h4e787163098768315d4c031a23c6b1ec9e21a765f939dfa4bbe1d162ae173ce9;
assign   plaintext[7][0]    =   128'hab942c68dd3123d1a1067e27b63da23a;
assign   plaintext[7][1]    =   128'he6bac8ed732b33943d9e9759ac19dfc1;
assign   plaintext[7][2]    =   128'h549c9886af6ab059fd0690c81569e015;
assign   plaintext[7][3]    =   128'h89bfca971e03717ad3ee6140cf6e2f1e;
assign   plaintext[7][4]    =   128'h6a739cd13e42b0a8b7eba20f3f70ba0c;
assign   plaintext[7][5]    =   128'h64f3475b3ad449bb3f0a4eee006fc292;
assign   plaintext[7][6]    =   128'hd713e79c00dc1e75b9b6fcc565a4ac4c;
assign   ciphertext[7][0]   =   128'hf7cdc053adcc38b5693408729bbf2c90;
assign   ciphertext[7][1]   =   128'h37b4bfa1a219f5c9ed6fc96aff86cef5;
assign   ciphertext[7][2]   =   128'h7d025aeaa03dc5dc2161f2e1bd740b78;
assign   ciphertext[7][3]   =   128'h056e1e874b2386a8e3de413794657680;
assign   ciphertext[7][4]   =   128'h89e05a389d7db91d8362edf57b2dd9b6;
assign   ciphertext[7][5]   =   128'h99ef7866bba052a8ff49f32daeea8847;
assign   ciphertext[7][6]   =   128'h4f9e21eea2d2d4f940bb81942732c596;
assign   tag[7]             =   128'h30202ad7427801882bd22782616c5d66;


// FRAME No. 8
// ===================================================================================================
assign   key[8]             =   256'hfeffe9928665731c6d6a8f9467308308feffe9928665731c6d6a8f9467308308;
assign   iv[8]              =   96'he8c36caa3012de50bfc75ea7;
assign   aad[8][0]          =   256'hd6d6d435d43fc7556fe08a1df914011c542644ad1901b6eca03a8074aaba61c7;
assign   plaintext[8][0]    =   128'h235e9199cf2b8480ab91341ea32738f4;
assign   plaintext[8][1]    =   128'h0e174f7c4989cf45e764495f90ed15c8;
assign   plaintext[8][2]    =   128'h561e074a6387e144881b169d3f50b96f;
assign   plaintext[8][3]    =   128'hf98edc0675660f8308503409770423fa;
assign   plaintext[8][4]    =   128'hbf6f6195d25aa1729df34cc0d1ec1e15;
assign   plaintext[8][5]    =   128'h6c3bbc4c9815fc38234176d680414518;
assign   plaintext[8][6]    =   128'h7bafc23e4b7bd69db2e3b9a2fbd6fde8;
assign   plaintext[8][7]    =   128'h12f65910200dea7f07ab65d0612086f1;
assign   ciphertext[8][0]   =   128'h2b1e975767e217532bb5ebd9d108f257;
assign   ciphertext[8][1]   =   128'h82392fc3d87c68db407f875f4dec69d2;
assign   ciphertext[8][2]   =   128'h15443c3949633ea845139ed9d50b3396;
assign   ciphertext[8][3]   =   128'h62b7f0b243f0a113e006cd2366895d26;
assign   ciphertext[8][4]   =   128'h3469bbae7ba791964f77c0181f4161ae;
assign   ciphertext[8][5]   =   128'ha07ae90712757bfb8ea8e61ac38655c5;
assign   ciphertext[8][6]   =   128'h46390529f2a6dfb77dc41ad9962c2171;
assign   ciphertext[8][7]   =   128'h59a8a2e9e42d2e4fdd66543d92582b93;
assign   tag[8]             =   128'hac57b0235d95cca217f7e2f54031fac1;


// FRAME No. 9
// ===================================================================================================
assign   key[9]             =   256'hfeffe9928665731c6d6a8f9467308308feffe9928665731c6d6a8f9467308308;
assign   iv[9]              =   96'h14cdb572f78c70c082a7dd02;
assign   aad[9][0]          =   256'h17dd6d04a03ab2069362b8d9c1286329948ae25a2058df04d2f790dc98cbc011;
assign   plaintext[9][0]    =   128'hac8bf7f02a18627fd9a2f77efd6ab4dc;
assign   plaintext[9][1]    =   128'h7b0dcf1eaf4bd5c6b56b3629abc12ccc;
assign   plaintext[9][2]    =   128'h9ed8972b49176ec6b430b189553c40d2;
assign   plaintext[9][3]    =   128'h84744ec2e5fe99c2984e0dc3ed4316f6;
assign   plaintext[9][4]    =   128'h8177e9d04a93be3602f454b8dc538195;
assign   plaintext[9][5]    =   128'hd8f2dab943d5eecee5f721084c28dcac;
assign   plaintext[9][6]    =   128'hdf34831eb046e61d2c038d4448bcb12d;
assign   plaintext[9][7]    =   128'h59c4ab7edca58716c81fabaffe1d6d2e;
assign   plaintext[9][8]    =   128'hd113715c58be2e0e0a608d3dde55b655;
assign   ciphertext[9][0]   =   128'h732402dc086a4e93a33969c9352f1e02;
assign   ciphertext[9][1]   =   128'hc1333d725b4a040abf8fccb5a3c14c57;
assign   ciphertext[9][2]   =   128'h27528729c3b5cf0e833777dd0b59b069;
assign   ciphertext[9][3]   =   128'h75af24c3e696fa280d000d17ba7a88f3;
assign   ciphertext[9][4]   =   128'h0f90b6881abf842f2eeaf055b5961b39;
assign   ciphertext[9][5]   =   128'hfe33dd9855befcce8c3c68281576ac4e;
assign   ciphertext[9][6]   =   128'hc0cdadb0f096dab07dd842eb5e011dba;
assign   ciphertext[9][7]   =   128'h7064ab3efe502d62e7d8620f6705eb57;
assign   ciphertext[9][8]   =   128'hade7d57cc31c13a1ab5a2a58359693f1;
assign   tag[9]             =   128'hd377689b3a39ec2da9c504e9d85bbabc;


// FRAME No. 10
// ===================================================================================================
assign   key[10]             =   256'h3006bef2467a4647859447c777ccb9a52c0b2ff75cc0974eda09e35a6bd0d909;
assign   iv[10]              =   96'hc31ec204828f9095e54f03b9;
assign   aad[10][0]          =   256'h26fd12b232c4ed4f1c20fe04f9b25a6b775e3155b77c688de9626004db77ea22;
assign   plaintext[10][0]    =   128'hb488e14d33184db46e7c8731ebb9df85;
assign   plaintext[10][1]    =   128'hbe0b7da213ec669c994756564afdf2f7;
assign   plaintext[10][2]    =   128'hb4d3795f94e3cffd574e4191715e2bef;
assign   plaintext[10][3]    =   128'hb4cede0448e21472eb170b2005675d8f;
assign   plaintext[10][4]    =   128'ha7f0fd80d79e8910d7368af92792e755;
assign   plaintext[10][5]    =   128'h33509f283359e2c26fbb9bcdc09ab608;
assign   plaintext[10][6]    =   128'h67784305cebfe2940d2d5d57d1f7af16;
assign   plaintext[10][7]    =   128'h28adb2786c31acc2b2ef2a7fc6237e3b;
assign   plaintext[10][8]    =   128'h071503fd1f6171d1770a7b75dc4d00f3;
assign   plaintext[10][9]    =   128'h5edbe4f98202cd95b46bb7fa1794aa89;
assign   ciphertext[10][0]   =   128'h2701cc86a1e973d8e8fa8bd80b5fb0bc;
assign   ciphertext[10][1]   =   128'h67e358194633404679d16a5290f3ba97;
assign   ciphertext[10][2]   =   128'hc2a394cbdeaa1a2807cbcc28bf37eb00;
assign   ciphertext[10][3]   =   128'h737654deb87a38c9e06f65f6833b064d;
assign   ciphertext[10][4]   =   128'h1523adc0ab180b06eb6a46a9a40cb481;
assign   ciphertext[10][5]   =   128'h628a227f3a0dcda72e3177af2f8da552;
assign   ciphertext[10][6]   =   128'hec271f5e633f8b52cf8a4b2ac81015de;
assign   ciphertext[10][7]   =   128'h5ab54b49d704c2ec17d87845b79b2f66;
assign   ciphertext[10][8]   =   128'h7214c37b76f3323d2388ef2537f99914;
assign   ciphertext[10][9]   =   128'h8c9978c414c506c7a03684d2101792a6;
assign   tag[10]             =   128'h88f6aa38f1abf9e5edeb29f65f417419;


// FRAME No. 11
// ===================================================================================================
assign   key[11]             =   256'h3006bef2467a4647859447c777ccb9a52c0b2ff75cc0974eda09e35a6bd0d909;
assign   iv[11]              =   96'h6d1389551ab8e0217ad6c2c5;
assign   aad[11][0]          =   256'h13415a068cea071e45e10c65326083be0cf25e36f843560b73f6d82eae1e6fe6;
assign   plaintext[11][0]    =   128'h15cbbb47f162884b28620b96e19286ad;
assign   plaintext[11][1]    =   128'h5358a66480150542c79a0cc78197b652;
assign   plaintext[11][2]    =   128'h56b3fdc11606a5ae9e9f927e79f2dffb;
assign   plaintext[11][3]    =   128'h2ff65e6652bf0c14840e397a50c73162;
assign   plaintext[11][4]    =   128'h8eff70405baa48b43048131079d6e458;
assign   plaintext[11][5]    =   128'h08251cff14101ec5cf0f590fa54475a9;
assign   plaintext[11][6]    =   128'hb0879c71b87118384f121231519fe357;
assign   plaintext[11][7]    =   128'hcc6f56455e8957972de9c468ae2cf5e6;
assign   plaintext[11][8]    =   128'haf923b4ed9ca51272ff4a79adebc0bf2;
assign   plaintext[11][9]    =   128'h0b70df4cbeb899fa821b83ae3f42da7a;
assign   plaintext[11][10]    =   128'h67b2cf0f40842904b15513d894ff1386;
assign   ciphertext[11][0]   =   128'h41ba408746474aaef94126d63d581ef5;
assign   ciphertext[11][1]   =   128'ha9d913f82f89c264163d9b55808418b0;
assign   ciphertext[11][2]   =   128'hcc5f74d6c41822537e6fb602700d69bc;
assign   ciphertext[11][3]   =   128'hd11c238c9e2be4a50cfee3704cafeef9;
assign   ciphertext[11][4]   =   128'h99e6fa70709ef3c27c5d56d5a6ab591c;
assign   ciphertext[11][5]   =   128'hb2215ac4e401be70ec3bf318a113a7cf;
assign   ciphertext[11][6]   =   128'h39370b01ee1e3b6b80e3a93baa5b91c4;
assign   ciphertext[11][7]   =   128'hf1bfa163a4bab562ab065cd5c58d9e6a;
assign   ciphertext[11][8]   =   128'h3889640569c396010baab93993f75011;
assign   ciphertext[11][9]   =   128'h29e197a6f046ed61b1f28a78867f2bb7;
assign   ciphertext[11][10]   =   128'h08b763e4a1edf50c68d72dc65363ae44;
assign   tag[11]             =   128'h0cbcb23c79e5d0ffc620e5a420d42f0d;


// FRAME No. 12
// ===================================================================================================
assign   key[12]             =   256'h3006bef2467a4647859447c777ccb9a52c0b2ff75cc0974eda09e35a6bd0d909;
assign   iv[12]              =   96'h30cd8190a99a3a3815e75926;
assign   aad[12][0]          =   256'h1b8c436572de7551968f7a520202275f8892892724559daa3e0bfcd9dec9f7f4;
assign   plaintext[12][0]    =   128'hec03f912e4bbe63f62a48f71cc940b42;
assign   plaintext[12][1]    =   128'h9473d51d2246c56e17f074271648890f;
assign   plaintext[12][2]    =   128'h66c461ba53d90a4c21eb7ec304f3ce80;
assign   plaintext[12][3]    =   128'h920e69f38fc8c6d059df0170b54b5e56;
assign   plaintext[12][4]    =   128'h6ab9723a7cd0a1f46e79cff76e328945;
assign   plaintext[12][5]    =   128'hfbc1a7668b79bf385c017c5a98d8cbb0;
assign   plaintext[12][6]    =   128'h63d09c1ab6a5dd09140731121e5a0dcd;
assign   plaintext[12][7]    =   128'h0bbb76fc3b3b537414fc19f20654a475;
assign   plaintext[12][8]    =   128'h7a186e6b1f7a6a0db841b5d9dadee4ee;
assign   plaintext[12][9]    =   128'h4b28e99faacfa122741e3376537b7d09;
assign   plaintext[12][10]    =   128'h8153944c8fb25ea8b41f31d1604d0a96;
assign   plaintext[12][11]    =   128'h6720345158468360bc4d35486920102e;
assign   ciphertext[12][0]   =   128'hf73402ef5cdee45e92772202cb24f69b;
assign   ciphertext[12][1]   =   128'h4d976b04b9b11df3ab4a2038b03b996f;
assign   ciphertext[12][2]   =   128'hf844310b7a5139d366c93fc848341955;
assign   ciphertext[12][3]   =   128'h113820973358df2e315cec2dd100b5cb;
assign   ciphertext[12][4]   =   128'hcf6b8894ef944a6a72bba7659112f066;
assign   ciphertext[12][5]   =   128'hd9338a1e9dc612a9adeb0f1c9a7b2ada;
assign   ciphertext[12][6]   =   128'h780f8a4e0ec242889b69eed27b456584;
assign   ciphertext[12][7]   =   128'h6e5795234c6a074c1eb55103c9953b4e;
assign   ciphertext[12][8]   =   128'hc0ecac051d9626d124c1469ea7af76d2;
assign   ciphertext[12][9]   =   128'h07e8440ecb587b31929ab8d4df967076;
assign   ciphertext[12][10]   =   128'h430242c7a971847a31121067bc6efff6;
assign   ciphertext[12][11]   =   128'h0b343cd38aa224faed4d2bc6c99ad28f;
assign   tag[12]             =   128'hf9987f02f28b5868b3c54dbee79a7754;


// FRAME No. 13
// ===================================================================================================
assign   key[13]             =   256'h3006bef2467a4647859447c777ccb9a52c0b2ff75cc0974eda09e35a6bd0d909;
assign   iv[13]              =   96'h34fc8a1a1db002ef348c6d6f;
assign   aad[13][0]          =   256'ha623e306a3a861571405df1dd618dabae703f47ef23c79f8094b3c56854110ed;
assign   plaintext[13][0]    =   128'h31c676b458c274dbc12ba2d84a17fcad;
assign   plaintext[13][1]    =   128'h1042cf9e2c770f42f1a7c20501c388a1;
assign   plaintext[13][2]    =   128'h8da1df0c90f4bca1727aba5cf4c55b47;
assign   plaintext[13][3]    =   128'hc7209e9ef52e6eaed5c1e8bfc370e7ec;
assign   plaintext[13][4]    =   128'hc66652215b29b706b45ca66a7efd15ae;
assign   plaintext[13][5]    =   128'h2ed7c7bba9148daa8b6b46c43ad76ff4;
assign   plaintext[13][6]    =   128'h63bd56096ef46a38852e4706b2275797;
assign   plaintext[13][7]    =   128'hbba7abb2be7f67e162524167ec65d1c3;
assign   plaintext[13][8]    =   128'h4943a2766b6ab636c7e43c1141c6c4dd;
assign   plaintext[13][9]    =   128'ha85a737921b0733cc5075d3ab9401768;
assign   plaintext[13][10]    =   128'h354f91dbdf8e2ac78c6ad1a77d88d0f9;
assign   plaintext[13][11]    =   128'h44ea5c3f2f3f87030b47b9cd065c659e;
assign   plaintext[13][12]    =   128'h0d8e0f345fd3b2c5e2dc94505fb82424;
assign   ciphertext[13][0]   =   128'hebad1ffdda1bb5679274eb0de9ee75a5;
assign   ciphertext[13][1]   =   128'hb85cc0334d9a1cbe4a21129ae37cd131;
assign   ciphertext[13][2]   =   128'h864d1a8df9e7af05054eb96340f055ab;
assign   ciphertext[13][3]   =   128'h4a38f75d8e2dd138a4b7062f762b551f;
assign   ciphertext[13][4]   =   128'hcd0e10dd096ad9957e10ff8ed77225d3;
assign   ciphertext[13][5]   =   128'h52da00bc2f688293275f04f821623053;
assign   ciphertext[13][6]   =   128'h86684b187644f398d9e92010aa680958;
assign   ciphertext[13][7]   =   128'h3d74867bf6ae8674288bfbfdfcb3f33f;
assign   ciphertext[13][8]   =   128'h62df0bcab3ba9b3c2985cb19cd755b8e;
assign   ciphertext[13][9]   =   128'h903336f22b38ac0d70966a84f4788143;
assign   ciphertext[13][10]   =   128'h6568e46aefbfae7524b3c2563dba609f;
assign   ciphertext[13][11]   =   128'hc783cd1477b158960a4b4e4bd9ba70f0;
assign   ciphertext[13][12]   =   128'hfac8d4ac5c078d8f0869d67c602e08cf;
assign   tag[13]             =   128'h4a4c50708310250aa9c3b16d9deb3dc8;


// FRAME No. 14
// ===================================================================================================
assign   key[14]             =   256'h3006bef2467a4647859447c777ccb9a52c0b2ff75cc0974eda09e35a6bd0d909;
assign   iv[14]              =   96'h3172b37f3269c1ba859008dc;
assign   aad[14][0]          =   256'h8c28862bdd2a97607315c78f36f19b9abfc8d26930d8cc9a8ccfa55454e9b7e0;
assign   plaintext[14][0]    =   128'h047e9ce40de810b3caa24a7b6a00c990;
assign   plaintext[14][1]    =   128'hb690bf4d6d1a6d501190fe3696b4f0d7;
assign   plaintext[14][2]    =   128'h75356be64a8f6f1e1cfcbd367ceca630;
assign   plaintext[14][3]    =   128'hb88b78b9fee274fbb13df17de69984f8;
assign   plaintext[14][4]    =   128'h9051cc18ff4430905166214b36f8be3a;
assign   plaintext[14][5]    =   128'h94a49a7e1d798548e5babae97f849cbd;
assign   plaintext[14][6]    =   128'hccec3e1d20d42dc20b7236a652447f1e;
assign   plaintext[14][7]    =   128'hf971701f45c67410da7690b57e0c08ee;
assign   plaintext[14][8]    =   128'hb4f23b77ef82790d133917b02a74aeb0;
assign   plaintext[14][9]    =   128'h5c8bc25fb88a07005ed0ec425eb70e5b;
assign   plaintext[14][10]    =   128'h18482f86b58d8c8ea2a1c714dd3f7cbd;
assign   plaintext[14][11]    =   128'h5a943b2c952d2c23b0d643c686d41093;
assign   plaintext[14][12]    =   128'he3fe3c19a6033fbb515e4c2631638a59;
assign   plaintext[14][13]    =   128'h13c07fed8395da2c3a35506c189fae98;
assign   ciphertext[14][0]   =   128'hc61595952a9e2181b28f7cbd378d30d7;
assign   ciphertext[14][1]   =   128'h3661dc7072ff19467950ca33988f0e60;
assign   ciphertext[14][2]   =   128'h076e2f8e7927068e1bc96ab9febcf9e6;
assign   ciphertext[14][3]   =   128'hff211c166eb77366d51ebe46dd7f7127;
assign   ciphertext[14][4]   =   128'h1050217bf6e97d75b89a935344de61b2;
assign   ciphertext[14][5]   =   128'h4d4c4f6d42d5bd33932cb3d4ba64b52e;
assign   ciphertext[14][6]   =   128'h450addad4ad31150b63b15b8f5437aa4;
assign   ciphertext[14][7]   =   128'h5f2b31d342b283f9ce97b92b5658ffed;
assign   ciphertext[14][8]   =   128'hfb3d16308a79e74a7524a712cb91cc0b;
assign   ciphertext[14][9]   =   128'h0263eed5c1d424c67915c00c8f1c8641;
assign   ciphertext[14][10]   =   128'hfb91b797706264536bc9d0191a9c8763;
assign   ciphertext[14][11]   =   128'he1fb7eba1c698cbec5a697188f927900;
assign   ciphertext[14][12]   =   128'hcdadefaa8a15ed7174d8cf2ae9767553;
assign   ciphertext[14][13]   =   128'h65cee925dd24ac8d9c7038f4794bea40;
assign   tag[14]             =   128'h2892df67efe291de44183073b39a8704;


assign   o_key          = key[i_frame_ctr]                      ;
assign   o_iv           = iv[i_frame_ctr]                       ;
assign   o_aad          = aad[i_frame_ctr][i_clk_ctr]           ;
assign   o_plaintext    = plaintext[i_frame_ctr][i_clk_ctr]     ;
assign   o_ciphertext   = ciphertext[i_frame_ctr][i_clk_ctr]    ;
assign   o_tag          = tag[i_frame_ctr]                      ;

endmodule    //gcm_aes_test_vector