from rw_reg import *
from data_processing_utils import *
from utils import *
from time import *
import datetime
import array
import struct
import signal
import sys
import os
import zlib

DEBUG=False

# SOURCE_MAC = 0x00151714809e
SOURCE_MAC = 0xdbdbdbdbdbdb
DESTINATION_MAC = 0x00151714809e

class Colors:            
    WHITE   = '\033[97m' 
    CYAN    = '\033[96m' 
    MAGENTA = '\033[95m' 
    BLUE    = '\033[94m' 
    YELLOW  = '\033[93m' 
    GREEN   = '\033[92m' 
    RED     = '\033[91m' 
    ENDC    = '\033[0m'  

REG_PUSH_GBE_DATA = None
REG_START_TRANSMIT = None
REG_EMPTY_BUSY = None

def main():

    localDaqFilename = None
    localDaqEventNum = None
    localDaqNumOfEvents = None

    if (len(sys.argv) > 1) and ('help' in sys.argv[1]):
        print('Usage: csc_eth_packet_test.py [local_daq_data_file] [local_daq_event_number_to_start_from] [local_daq_number_of_events_to_send]')
        print('if no arguments are given, a dummy eth packet will be sent')
        print('if local daq data file is supplied but no event number is supplied, the whole file will be read and sent out event by event')
        print('if local_daq_event_number_to_start_from is supplied and local_daq_number_of_events_to_send, it will send this many events starting at the given position')
        print('if local_daq_number_of_events_to_send is ommited, it will send the whole file starting at local_daq_event_number_to_start_from')
        return

    if len(sys.argv) > 1:
        localDaqFilename = sys.argv[1]

    if len(sys.argv) > 2:
        if "none" not in sys.argv[2]:
            localDaqEventNum = parseInt(sys.argv[2])

    if len(sys.argv) > 3:
        localDaqNumOfEvents = parseInt(sys.argv[3])

    parseXML()
    initRegAddrs()

    if localDaqFilename is None:
        sendDummyEmptyDduPacket()
        # sendDummyEthPacket()
        return

    localDaqFile = open(localDaqFilename, 'rb')
    events = []
    smallest_size = 99999
    smallest_size_idx = -1
    largest_size = 0
    largest_size_idx = -1
    events_read = 0
    if localDaqEventNum is not None:
        events.append(dduReadEvent(localDaqFile, localDaqEventNum))
        events_read = 1
        print("read event #%d, size = %d bytes" % (localDaqEventNum, len(events[0]) * 8))
        localDaqEventNum = None

    size = 1
    words_read = 0
    while size > 0 and ((events_read < localDaqNumOfEvents) or localDaqNumOfEvents is None):
        event = dduReadEvent(localDaqFile, localDaqEventNum)
        size = len(event)
        words_read += size
        events.append(event)
        print("read event #%d, size = %d bytes, total bytes read = %d" % (events_read, size * 8, words_read * 8))
        events_read += 1
        if size > 48 and size < smallest_size:
            smallest_size = size
            smallest_size_idx = events_read
        if size > largest_size:
            largest_size = size
            largest_size_idx = events_read

    printCyan("Smallest event size (excluding empty events): %d bytes (event #%d)" % (smallest_size * 8, smallest_size_idx))
    printCyan("Largest event size: %d bytes (event #%d)" % (largest_size * 8, largest_size_idx))

    heading("Starting to send the events out!")
    writeReg(getNode('CSC_FED.TEST.CTRL.MODULE_RESET'), 0x1)
    sleep(0.1)
    writeReg(getNode('CSC_FED.TEST.GBE_TEST.ENABLE'), 0x1)

    packet_counter = 0
    for event in events:
        #print("Event size = %d bytes" % (len(event)*8))
        #split up the events into multiple packets of max payload size = 994 64bit words
        i = 0
        last_fragment = False
        while i < len(event):
            end = i + 994 #255
            if end >= len(event):
                end = len(event)
                last_fragment = True
            if i > 0:
                printCyan("Split event is being sent! i = %d, end = %d, event length = %d" % (i, end, len(event)))
            event_fragment = event[i:end]
            #make sure the FIFO is empty and there's no active transmission before pushing in new data
            while i == 0 and rReg(REG_EMPTY_BUSY) != 2:
                sleep(0.00001)
            i += 994 #255
            #print("Sending a packet of size %d bytes" % (len(event_fragment) * 8))
            if not sendDduEthPacket(event_fragment, packet_counter, True, last_fragment, True):
                return
            if packet_counter == 0xffff:
                packet_counter = 0
            else:
                packet_counter += 1

    localDaqFile.close()

    return

def initRegAddrs():
    global REG_PUSH_GBE_DATA
    global REG_START_TRANSMIT
    global REG_EMPTY_BUSY
    REG_PUSH_GBE_DATA = getNode('CSC_FED.TEST.GBE_TEST.PUSH_GBE_DATA').real_address
    REG_START_TRANSMIT = getNode('CSC_FED.TEST.GBE_TEST.START_TRANSMIT').real_address
    REG_EMPTY_BUSY = getNode('CSC_FED.TEST.GBE_TEST.BUSY').real_address

# this function pushes an ETH frame with the provided payload to the CTP7 and sends it out
# note that the payload can be provided as either an array of 64 bit words (default), or an array of 16bit words (only used for fake packet testing)
def sendStandardEthPacket(payload_words64, ethType = 0x0800, payload_words16 = None):

    heading("Sending an ethernet packet")

    writeReg(getNode('CSC_FED.TEST.GBE_TEST.ENABLE'), 0x1)

    s = "" # eth frame as char vector, to be used for crc

    ########## preamble and SOF ##########
    pushGbeWord16(0x155FB)
    pushGbeWord16(0x5555)
    pushGbeWord16(0x5555)
    pushGbeWord16(0xD555)

    ########## source MAC ##########
    s += pushGbeWord16(((SOURCE_MAC >> 24) & 0xff00) + (SOURCE_MAC >> 40))
    s += pushGbeWord16(((SOURCE_MAC >> 8) & 0xff00) + ((SOURCE_MAC >> 24) & 0xff))
    s += pushGbeWord16(((SOURCE_MAC & 0xff) << 8) + ((SOURCE_MAC >> 8) & 0xff))

    ########## destination MAC (simply use the same as source) ##########
    s += pushGbeWord16(((DESTINATION_MAC >> 24) & 0xff00) + (DESTINATION_MAC >> 40))
    s += pushGbeWord16(((DESTINATION_MAC >> 8) & 0xff00) + ((DESTINATION_MAC >> 24) & 0xff))
    s += pushGbeWord16(((DESTINATION_MAC & 0xff) << 8) + ((DESTINATION_MAC >> 8) & 0xff))

    ########## ETH type ##########
    s += pushGbeWord16(((ethType & 0xff) << 8) + (ethType >> 8))

    if payload_words64 is not None:
        for word64 in payload_words64:
            s += pushGbeWord16(word64 & 0xffff, True)
            s += pushGbeWord16((word64 >> 16) & 0xffff, True)
            s += pushGbeWord16((word64 >> 32) & 0xffff, True)
            s += pushGbeWord16((word64 >> 48) & 0xffff, True)
            # s += pushGbeWord16(word64 & 0xffff, False, True)
            # s += pushGbeWord16((word64 >> 16) & 0xffff, False, True)
            # s += pushGbeWord16((word64 >> 32) & 0xffff, False, True)
            # s += pushGbeWord16((word64 >> 48) & 0xffff, False, True)
    elif payload_words16 is not None:
        for word16 in payload_words16:
            s += pushGbeWord16(word16)
    else:
        printRed("No payload provided to the sendEthPacket() function! exiting..")
        exit(1)

    crc = zlib.crc32(s) & 0xffffffff
    # print("CRC: " + hex(crc))

    ########## CRC ##########
    pushGbeWord16(crc & 0xffff)
    pushGbeWord16(crc >> 16)

    ########## EOF and carrier extend ##########
    pushGbeWord16(0x3f7fd)

    ########## SEND!! ##########
    writeReg(getNode('CSC_FED.TEST.GBE_TEST.START_TRANSMIT'), 0x1)
    heading("DONE")

# DDU doesn't send the ethernet header at all, and also appends a 16bit packet counter just before the CRC -- that's what this function will do.
def sendDduEthPacket(payload_words64, packet_counter, add_idles = False, send = True, test_readback_mode = False):

    s = "" # eth frame as char vector, to be used for crc

    ########## preamble and SOF ##########
    pushGbeWord16(0x155FB)
    pushGbeWord16(0x5555)
    pushGbeWord16(0x5555)
    pushGbeWord16(0xD555)

    for word64 in payload_words64:
        s += pushGbeWord16(word64 & 0xffff)
        s += pushGbeWord16((word64 >> 16) & 0xffff)
        s += pushGbeWord16((word64 >> 32) & 0xffff)
        s += pushGbeWord16((word64 >> 48) & 0xffff)

    # append filler words if the payload is short to meet the ethernet minimum packet size requirement
    bytes_pushed = len(payload_words64) * 8
    first_filler = False
    while bytes_pushed < 64:
        if first_filler:
            s += pushGbeWord16(0xff00 + bytes_pushed)
            first_filler = False
        else:
            s += pushGbeWord16(0xffff)
        bytes_pushed += 2

    s += pushGbeWord16(packet_counter)

    crc = zlib.crc32(s) & 0xffffffff
    # print("CRC: " + hex(crc))

    ########## CRC ##########
    pushGbeWord16(crc & 0xffff)
    pushGbeWord16(crc >> 16)

    ########## EOF and carrier extend ##########
    pushGbeWord16(0x3f7fd)

    if add_idles:
        for i in range(0, 7):
            pushGbeWord16(0x150bc)

    ########## SEND!! ##########
    if send and not test_readback_mode:
        wReg(REG_START_TRANSMIT, 0x1)
    print("Packet #%d sent" % packet_counter)

    if test_readback_mode:
        expected_words16 = []
        expected_words16.append(0x155FB)
        expected_words16.append(0x5555)
        expected_words16.append(0x5555)
        expected_words16.append(0xD555)
        for i in range (0, len(s)):
            expected_words16.append(ord(s[i]) + (ord(s[i]) << 8))
        expected_words16.append(crc & 0xffff)
        expected_words16.append(crc >> 16)
        expected_words16.append(0x3f7fd)
        for i in range(0, 7):
            expected_words16.append(0x150bc)
        return readBackTest(expected_words16)
    else:
        return True

def pushGbeWord16(word16, verbose = False):
    wReg(REG_PUSH_GBE_DATA, word16)
    if verbose:
        print 'pushing ' + hex(word16)
    return chr(word16 & 0xff) + chr((word16 >> 8) & 0xff)

def readBackTest(expected_words16):
    read_words16 = []
    writeReg(getNode('CSC_FED.TEST.GBE_TEST.MANUAL_READ_ENABLE'), 1)
    while (rReg(REG_EMPTY_BUSY) & 0x2) == 0:
        print("reading")
        read_words16 = parseInt(readReg(getNode('CSC_FED.TEST.GBE_TEST.MANUAL_READ')))
    writeReg(getNode('CSC_FED.TEST.GBE_TEST.MANUAL_READ_ENABLE'), 0)

    if len(read_words16) != len(expected_words16):
        printRed("readback and expected word count doesn't match. Expected %d words, read %d words" % (len(expected_words16), len(read_words16)))
        return False

    for i in range(0, len(read_words16)):
        if read_words16[i] != expected_words16[i]:
            printRed("readback word #%d did not match the expected word. Expected %s, but read %s" % (i, hexPadded(expected_words16[i], 2), hexPadded(read_words16, 2)))
            return False

    return True

def sendDummyEthPacket():
    words16 = []
    for i in range(0, 23):
        words16.append(0x0000)

    sendEthPacket(None, False, 0, 0x800, words16)

def sendDummyEmptyDduPacket():
    preamble = [0x155fb, 0x5555, 0x5555, 0xd555]
    dduHeader = [0x4770, 0x7313, 0x04ce, 0x5000, 0x0000, 0x8000, 0x0001, 0x8000, 0x0080, 0x0000, 0x3031, 0x7fff]
    dduTrailer = [0x8000, 0x8000, 0xffff, 0x8000, 0x0000, 0x0000, 0x0000, 0x2010, 0x0080, 0x3a6d, 0x0006, 0xa000]
    padding = [0xff30, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff]
    packet_cnt = [0x04cf]
    crc = [0x30ba, 0xe514]
    eofHmm = [0x3f7fd, 0x1c5bc]

    packetPayload = dduHeader + dduTrailer + padding + packet_cnt


    writeReg(getNode('CSC_FED.TEST.GBE_TEST.ENABLE'), 0x1)

    for word in preamble:
        pushGbeWord16(word)

    s = ""
    print("packet payload:")
    for word in packetPayload:
        s += pushGbeWord16(word, True)

    print("crc:")
    for word in crc:
        pushGbeWord16(word, True)

    print("eof:")
    for word in eofHmm:
        pushGbeWord16(word, True)

    calcCrc = zlib.crc32(s) & 0xffffffff
    print("Calculated CRC: " + hex(calcCrc))


    writeReg(getNode('CSC_FED.TEST.GBE_TEST.START_TRANSMIT'), 0x1)
    heading("DONE")

def sendDummyEthPacketOld():
    heading("Sending a dummy ethernet packet")

    writeReg(getNode('CSC_FED.TEST.GBE_TEST.ENABLE'), 0x1)

    ########## preamble and SOF ##########
    writeReg(getNode('CSC_FED.TEST.GBE_TEST.PUSH_GBE_DATA'), 0x155FB)
    writeReg(getNode('CSC_FED.TEST.GBE_TEST.PUSH_GBE_DATA'), 0x5555)
    writeReg(getNode('CSC_FED.TEST.GBE_TEST.PUSH_GBE_DATA'), 0x5555)
    writeReg(getNode('CSC_FED.TEST.GBE_TEST.PUSH_GBE_DATA'), 0xD555)

    ########## source MAC ##########
    writeReg(getNode('CSC_FED.TEST.GBE_TEST.PUSH_GBE_DATA'), 0x1500)
    writeReg(getNode('CSC_FED.TEST.GBE_TEST.PUSH_GBE_DATA'), 0x1417)
    writeReg(getNode('CSC_FED.TEST.GBE_TEST.PUSH_GBE_DATA'), 0x9e80)

    ########## destination MAC ##########
    writeReg(getNode('CSC_FED.TEST.GBE_TEST.PUSH_GBE_DATA'), 0x1500)
    writeReg(getNode('CSC_FED.TEST.GBE_TEST.PUSH_GBE_DATA'), 0x1417)
    writeReg(getNode('CSC_FED.TEST.GBE_TEST.PUSH_GBE_DATA'), 0x9e80)

    ########## ETH type ##########
    writeReg(getNode('CSC_FED.TEST.GBE_TEST.PUSH_GBE_DATA'), 0x0008)

    ########## Payload ##########
    for i in range(0, 23):
        writeReg(getNode('CSC_FED.TEST.GBE_TEST.PUSH_GBE_DATA'), 0x0000)

    ########## CRC ##########
    writeReg(getNode('CSC_FED.TEST.GBE_TEST.PUSH_GBE_DATA'), 0xabb8)
    writeReg(getNode('CSC_FED.TEST.GBE_TEST.PUSH_GBE_DATA'), 0x962d)

    ########## EOF and carrier extend ##########
    writeReg(getNode('CSC_FED.TEST.GBE_TEST.PUSH_GBE_DATA'), 0x3f7fd)



    ########## SEND!! ##########
    writeReg(getNode('CSC_FED.TEST.GBE_TEST.START_TRANSMIT'), 0x1)
    heading("DONE")

if __name__ == '__main__':
    main()