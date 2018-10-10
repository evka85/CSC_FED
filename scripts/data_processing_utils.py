import struct
from utils import *
import numpy as np
import time

##########################
######## unpacker ########
##########################

class FedEvent:

    l1Id = None
    errors = []

    def __init__(self, words):
        self.words = words
        self.dmbs = []
        self.unpackHeader()
        self.unpackDmbs()

    def unpackHeader(self):
        self.l1Id = (int(self.words[0]) >> 32) & 0xffffff

    def unpackDmbs(self):
        dmbHeaders = np.where(self.words & 0xf000f000f000f000 == 0x9000900090009000)[0]
        if dmbHeaders.size == 0:
            return
        for i in range(1, dmbHeaders.size):
            self.dmbs.append(DmbEvent(self.words[dmbHeaders[i - 1]:dmbHeaders[i]]))
        self.dmbs.append(DmbEvent(self.words[dmbHeaders[dmbHeaders.size - 1]:self.words.size - 3]))

    def checkErrors(self):
        if self.words.size < 6:
            self.errors.append("FED block size error (size = %d words)" % self.words.size)
        for dmb in self.dmbs:
            dmb.checkErrors()
            if len(dmb.errors) > 0:
                self.errors.append("DMB error (crateId = %d, dmbId = %d)" % (dmb.crateId, dmb.dmbId))

class DmbEvent:

    crateId = 0
    dmbId = 0
    errors = None

    def __init__(self, words):
        self.words = words
        errors = []
        if self.words.size < 4:
            self.errors.append("DMB block size error (size = %d words)" % self.words.size)
        else:
            self.unpackHeader()

    def unpackHeader(self):
        self.crateId = (int(self.words[1]) >> 20) & 0xff
        self.dmbId = (int(self.words[1]) >> 16) & 0xf

    def printDmbInfo(self):
        print ("Crate %d DMB %d" % (self.crateId, self.dmbId))

    def checkErrors(self):
        pass


def unpackFile(localDaqFilename):

    # read the whole file into a numpy array
    print("Reading the file")
    f = open(localDaqFilename, 'rb')
    raw = np.fromfile(f, dtype=np.dtype('u8'))
    f.close()

    eoes = np.where(raw==0x8000ffff80008000)

    print("Unpacking events")
    events = []
    start = 0
    i = 0
    for eoe in eoes[0]:
        events.append(FedEvent(raw[start:eoe+3]))
        start = eoe + 3
        i += 1
        if (i % 1000 == 0):
            print "%d events unpacked (out of %d)" % (i, eoes[0].size)


    # for i in range(0, 20):
    #     print("=============== event %d, L1 ID %d ===============" % (i, events[i].l1Id))
    #     for dmb in events[i].dmbs:
    #         dmb.printDmbInfo()

    print "=============== DONE ==============="
    print "read %d bytes" % (raw.size * 8)
    print "unpacked %d events" % len(events)

    return events


##########################
######## raw utils ########
##########################
def dduReadEventRaw(file, eventIdx):

    words = []
    word = 0
    lastWord = 0
    # look for beginning of the event with requested index
    while ((word & 0xffffffffffff0000) != 0x8000000180000000) or (lastWord & 0xf000000000000000 != 0x5000000000000000) or (((lastWord >> 32) & 0xffffff != eventIdx) and (eventIdx is not None)):
        lastWord = word
        wordStr = file.read(8)
        if (len(wordStr) < 8):
            return words
        word = struct.unpack("Q", wordStr)[0]

    words.append(lastWord)
    words.append(word)

    #read the current event until the DDU trailer2
    while (word != 0x8000ffff80008000):
        wordStr = file.read(8)
        if (len(wordStr) < 8):
            return words
        word = struct.unpack("Q", wordStr)[0]
        words.append(word)

    # read the last two ddu trailer words
    words.append(struct.unpack("Q", file.read(8))[0])
    words.append(struct.unpack("Q", file.read(8))[0])

    return words

def dumpEvents(cfedEvent, dduEvent):
    cfedLen = len(cfedEvent)
    dduLen = len(dduEvent)
    length = cfedLen
    if (dduLen > length):
        length = dduLen

    line = ""
    for i in range(0, length):
        line = hexPadded(i*8, 2) + ":   "
        if (i < cfedLen):
            # line = hexPadded(cfedEvent[i], 8, False)
            line += hexPadded((cfedEvent[i] >> 48) & 0xffff, 2, False) + " " + hexPadded((cfedEvent[i] >> 32) & 0xffff, 2, False) + " " + hexPadded((cfedEvent[i] >> 16) & 0xffff, 2, False) + " " + hexPadded(cfedEvent[i] & 0xffff, 2, False)
        else:
            line = "                  "

        line += "  ----  "

        if (i < dduLen):
            # line += hexPadded(dduEvent[i], 8, False)
            line += hexPadded((dduEvent[i] >> 48) & 0xffff, 2, False) + " " + hexPadded((dduEvent[i] >> 32) & 0xffff, 2, False) + " " + hexPadded((dduEvent[i] >> 16) & 0xffff, 2, False) + " " + hexPadded(dduEvent[i] & 0xffff, 2, False)

        if (i < cfedLen) and (i < dduLen) and (cfedEvent[i] != dduEvent[i]):
            printRed(line)
        else:
            print(line)

def dumpEventsNumpy(words1, words2, annotateWords1 = True):
    len1 = words1.size
    len2 = words2.size

    length = len1
    if (len2 > len1):
        length = len2

    line = ""
    dmbHead2Idx = -9999
    alctHeadIdx = None
    alctTrailIdx = None
    tmbHeadIdx = None
    tmbTrailIdx = None
    cfebData = False
    cfebWordCnt = 0
    dmbTrail2Idx = None
    for i in range(0, length):
        line = hexPadded(i*8, 2) + ":   "
        if (i < len1):
            line += hexPadded((int(words1[i]) >> 48) & 0xffff, 2, False) + " " + hexPadded((int(words1[i]) >> 32) & 0xffff, 2, False) + " " + hexPadded((int(words1[i]) >> 16) & 0xffff, 2, False) + " " + hexPadded(int(words1[i]) & 0xffff, 2, False)
            if annotateWords1:
                if  (int(words1[i]) & 0xf000f000f000f000) == 0xa000a000a000a000:
                    dmbHead2Idx = i
                    cfebData = False
                    cfebWordCnt = 0
                elif (int(words1[i]) & 0xf000f000f000f000) == 0xe000e000e000e000:
                    dmbTrail2Idx = i
                elif (int(words1[i]) & 0xf000f000f000ffff) == 0xd000d000d000db0a:
                    alctHeadIdx = i
                elif (int(words1[i]) & 0xf000f000f000ffff) == 0xd000d000d000de0d:
                    alctTrailIdx = i
                elif (int(words1[i]) & 0xf000f000f000ffff) == 0xd000d000d000db0c:
                    tmbHeadIdx = i
                elif (int(words1[i]) & 0xf000f000f000ffff) == 0xd000d000d000de0f:
                    tmbTrailIdx = i

                if ((dmbHead2Idx == i - 1) and (alctHeadIdx is None) and (tmbHeadIdx is None)) or \
                   ((alctTrailIdx is not None) and (alctTrailIdx == i -1) and (tmbHeadIdx is None)) or \
                   ((tmbTrailIdx is not None) and (tmbTrailIdx == i - 1)):
                    cfebData = True

                if cfebData:
                    cfebWordCnt += 1
        else:
            line = "                  "

        line += "  ----  "

        if (i < len2):
            line += hexPadded((int(words2[i]) >> 48) & 0xffff, 2, False) + " " + hexPadded((int(words2[i]) >> 32) & 0xffff, 2, False) + " " + hexPadded((int(words2[i]) >> 16) & 0xffff, 2, False) + " " + hexPadded(int(words2[i]) & 0xffff, 2, False)

        if annotateWords1:
            if dmbHead2Idx == i:
                line += "   <=== DMB HEADER #2"
            elif dmbTrail2Idx == i:
                line += "   <=== DMB TRAILER #2"
            elif alctHeadIdx == i:
                line += "   <=== ALCT HEADER"
            elif alctTrailIdx == i:
                line += "   <=== ALCT TRAILER"
            elif tmbHeadIdx == i:
                line += "   <=== TMB HEADER"
            elif tmbTrailIdx == i:
                line += "   <=== TMB TRAILER"
            elif (cfebWordCnt > 0) and (cfebWordCnt % 25 == 0):
                line += "   <=== CFEB SAMPLE %d TRAILER" % int(cfebWordCnt / 25)

        if (i < len1) and (i < len2) and (words1[i] != words2[i]):
            printRed(line)
        else:
            print(line)

def printRawWords(words64):
    i = 0
    for word in words64:
        print "%d\t: %s" % (i, hexPadded64(word))
        i += 1
