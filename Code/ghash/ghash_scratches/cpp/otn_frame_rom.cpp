#include <iostream>
#include <fstream>

using namespace std;

int main () {
    int odu_oh_i, fec_i, fs_i, pl_i ;
    pl_i        = 0 ;
    odu_oh_i    = 0 ;
    fec_i       = 0 ;
    fs_i        = 0 ;
    ofstream myfile;
    myfile.open ("otn_frame_rom.txt");
    // myfile << "Writing this to a file.\n";
    for( int i=0; i<512; i++){
        if( i==0 ){
            myfile << "assign data[" << i << "] =\t{ fas, \totu_oh,\t\topu_oh,\t\tpl[" << pl_i << "],\t\tpl["<< pl_i+1 << "]\t\t};\t\t// ROW 1" << endl ;
            pl_i = pl_i + 2 ;
        }
        else if ( i<119 ){
            myfile << "assign data[" << i << "] =\t{ pl[" << pl_i << "],\t\tpl[" << pl_i+1 << "],\t\tpl[" << pl_i+2 << "],\t\tpl["<< pl_i+3 << "]\t\t};" << endl ;
            pl_i = pl_i + 4 ;
        }
        else if ( i==119 ){
            myfile << "assign data[" << i << "] =\t{ pl[" << pl_i << "],\t\tfs[" << fs_i << "],\t\tfec[" << fec_i << "],\t\tfec["<< fec_i+1 << "]\t\t};" << endl ;
            pl_i++ ;
            fs_i++ ;
            fec_i = fec_i + 2 ;
        }
        else if ( i<127 ){
            myfile << "assign data[" << i << "] =\t{ fec[" << fec_i << "],\t\tfec["<< fec_i+1 << "],\t\tfec[" << fec_i+2 << "],\t\tfec["<< fec_i+3 << "]\t\t};" << endl ;
            fec_i = fec_i + 4 ;
        }
        else if ( i==127){
            myfile << "assign data[" << i << "] =\t{ fec[" << fec_i << "],\tfec["<< fec_i+1 << "],\t\todu_oh[" << odu_oh_i << "],\t\topu_oh\t\t};\t\t// ROW 2" << endl ;
            fec_i = fec_i + 2 ;
            odu_oh_i++ ;
        }
        else if ( i<246 ){
            myfile << "assign data[" << i << "]  = { pl[" << pl_i << "],\t\tpl[" << pl_i+1 << "],\t\tpl[" << pl_i+2 << "],\t\tpl["<< pl_i+3 << "]\t\t};" << endl ;
            pl_i = pl_i + 4 ;
        }
        else if ( i==246 ){
            myfile << "assign data[" << i << "]  = { pl[" << pl_i << "],\t\tpl[" << pl_i+1 << "],\t\tpl[" << pl_i+2 << "],\t\tfs["<< fs_i << "]\t\t};" << endl ;
            pl_i = pl_i + 3 ;
            fs_i++ ;
        }
        else if ( i<255 ){
            myfile << "assign data[" << i << "]  = { fec[" << fec_i << "],\t\tfec["<< fec_i+1 << "],\t\t\tfec[" << fec_i+2 << "],\t\tfec["<< fec_i+3 << "]\t\t};" << endl ;
            fec_i = fec_i + 4 ;
        }
        else if ( i==255 ){
            myfile << "assign data[" << i << "]  = { odu_oh[" << odu_oh_i << "],\topu_oh,\t\tpl[" << pl_i << "],\t\t\tpl[" << pl_i+1 << "]\t\t};\t\t// ROW 3" << endl ;
            odu_oh_i++ ;
            pl_i = pl_i + 2 ;
        }
        else if ( i<374 ){
            myfile << "assign data[" << i << "]  = { pl[" << pl_i << "],\t\tpl[" << pl_i+1 << "],\t\tpl[" << pl_i+2 << "],\t\tpl["<< pl_i+3 << "]\t\t};" << endl ;
            pl_i = pl_i + 4 ;
        }
        else if ( i==374 ){
            myfile << "assign data[" << i << "]  = { pl[" << pl_i << "],\t\tfs[" << fs_i << "],\t\t\tfec[" << fec_i << "],\t\tfec["<< fec_i+1 << "]\t\t};" << endl ;
            pl_i++ ;
            fs_i++ ;
            fec_i = fec_i + 2 ;
        }
        else if ( i<382 ){
            myfile << "assign data[" << i << "]  = { fec[" << fec_i << "],\t\tfec["<< fec_i+1 << "],\t\tfec[" << fec_i+2 << "],\t\tfec["<< fec_i+3 << "]\t\t};" << endl ;
            fec_i = fec_i + 4 ;
        }
        else if ( i==382){
            myfile << "assign data[" << i << "]  = { fec[" << fec_i << "],\t\tfec["<< fec_i+1 << "],\t\todu_oh[" << odu_oh_i << "],\t\topu_oh\t\t};\t\t//ROW 4" << endl ;
            fec_i = fec_i + 2 ;
            odu_oh_i++ ;
        }
        else if ( i<501 ){
            myfile << "assign data[" << i << "]  = { pl[" << pl_i << "],\t\tpl[" << pl_i+1 << "],\t\tpl[" << pl_i+2 << "],\t\tpl["<< pl_i+3 << "]\t\t};" << endl ;
            pl_i = pl_i + 4 ;
        }
        else if ( i==501 ){
            myfile << "assign data[" << i << "]  = { pl[" << pl_i << "],\t\tpl[" << pl_i+1 << "],\t\tpl[" << pl_i+2 << "],\t\tfs["<< fs_i << "]\t\t\t};" << endl ;
            pl_i = pl_i + 3 ;
            fs_i++ ;
        }
        else if ( i<510 ){
            myfile << "assign data[" << i << "]  = { fec[" << fec_i << "],\t\tfec["<< fec_i+1 << "],\t\tfec[" << fec_i+2 << "],\t\tfec["<< fec_i+3 << "]\t\t\t};" << endl ;
            fec_i = fec_i + 4 ;
        }
    }
    myfile.close();
    return 0;
}