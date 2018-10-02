import struct
from utils import *

def dduReadEvent(file, eventIdx):

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
