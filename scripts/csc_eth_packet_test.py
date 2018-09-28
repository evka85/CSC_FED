from rw_reg import *
from time import *
import datetime
import array
import struct
import signal
import sys
import os

DEBUG=False

class Colors:            
    WHITE   = '\033[97m' 
    CYAN    = '\033[96m' 
    MAGENTA = '\033[95m' 
    BLUE    = '\033[94m' 
    YELLOW  = '\033[93m' 
    GREEN   = '\033[92m' 
    RED     = '\033[91m' 
    ENDC    = '\033[0m'  

def main():

    parseXML()

    heading("Sending a packet")
    writeReg(getNode('CSC_FED.TEST.GBE_TEST.ENABLE'), 0x1)

    writeReg(getNode('CSC_FED.TEST.GBE_TEST.PUSH_GBE_DATA'), 0x155FB)
    writeReg(getNode('CSC_FED.TEST.GBE_TEST.PUSH_GBE_DATA'), 0x5555)
    writeReg(getNode('CSC_FED.TEST.GBE_TEST.PUSH_GBE_DATA'), 0x5555)
    writeReg(getNode('CSC_FED.TEST.GBE_TEST.PUSH_GBE_DATA'), 0xD555)
    writeReg(getNode('CSC_FED.TEST.GBE_TEST.PUSH_GBE_DATA'), 0x35a0)
    writeReg(getNode('CSC_FED.TEST.GBE_TEST.PUSH_GBE_DATA'), 0x149f)
    writeReg(getNode('CSC_FED.TEST.GBE_TEST.PUSH_GBE_DATA'), 0x5aca)
    writeReg(getNode('CSC_FED.TEST.GBE_TEST.PUSH_GBE_DATA'), 0xdbdb)
    writeReg(getNode('CSC_FED.TEST.GBE_TEST.PUSH_GBE_DATA'), 0xdbdb)
    writeReg(getNode('CSC_FED.TEST.GBE_TEST.PUSH_GBE_DATA'), 0xdbdb)
    writeReg(getNode('CSC_FED.TEST.GBE_TEST.PUSH_GBE_DATA'), 0x7088)
    writeReg(getNode('CSC_FED.TEST.GBE_TEST.PUSH_GBE_DATA'), 0xcafe)
    writeReg(getNode('CSC_FED.TEST.GBE_TEST.PUSH_GBE_DATA'), 0xf971)
    writeReg(getNode('CSC_FED.TEST.GBE_TEST.PUSH_GBE_DATA'), 0x3f7fd)
    writeReg(getNode('CSC_FED.TEST.GBE_TEST.PUSH_GBE_DATA'), 0x3f7f7)

    writeReg(getNode('CSC_FED.TEST.GBE_TEST.START_TRANSMIT'), 0x1)
    heading("DONE")

#---------------------------- utils ------------------------------------------------

def check_bit(byteval,idx):
    return ((byteval&(1<<idx))!=0);

def debug(string):
    if DEBUG:
        print('DEBUG: ' + string)

def debugCyan(string):
    if DEBUG:
        printCyan('DEBUG: ' + string)

def heading(string):                                                                    
    print Colors.BLUE                                                             
    print '\n>>>>>>> '+str(string).upper()+' <<<<<<<'
    print Colors.ENDC                   
                                                      
def subheading(string):                         
    print Colors.YELLOW                                        
    print '---- '+str(string)+' ----',Colors.ENDC                    
                                                                     
def printCyan(string):                                                
    print Colors.CYAN                                    
    print string, Colors.ENDC                                                                     
                                                                      
def printRed(string):                                                                                                                       
    print Colors.RED                                                                                                                                                            
    print string, Colors.ENDC                                           

def hex(number):
    if number is None:
        return 'None'
    else:
        return "{0:#0x}".format(number)

def hexPadded64(number):
    if number is None:
        return 'None'
    else:
        return "{0:#0{1}x}".format(number, 18)

def binary(number, length):
    if number is None:
        return 'None'
    else:
        return "{0:#0{1}b}".format(number, length + 2)

def parseInt(string):
    if string is None:
        return None
    elif string.startswith('0x'):
        return int(string, 16)
    elif string.startswith('0b'):
        return int(string, 2)
    else:
        return int(string)

if __name__ == '__main__':
    main()
