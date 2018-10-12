from utils import *
from data_processing_utils import *
import signal
import sys
import os
import struct
import numpy as np
from time import *

def main():

    ldaqFilename = ""
    maxFiles = None

    if len(sys.argv) < 2:
        print('Usage: local_daq_analyze.py <local_daq_data_file_pattern> [max_num_files_match]')
        print('file patterns can be exact filenames or have a * indicating a wildcard, but only for the part number (last number in the local daq filename)')
        print('if a wildcard is used, you can optionally provide a max number of files to match to (default is no limit)')
        return
    else:
        ldaqFilename = sys.argv[1]

    if len(sys.argv) > 2:
        maxFiles = int(sys.argv[2])

    heading('Welcome to Local DAQ raw file analyzer')

    files = getAllLocalDaqRawFiles(ldaqFilename, maxFiles)

    events = []
    fileIdx = -1
    evtNum = 0
    idx = -1

    errors = []

    while True:
        evtNum += 1
        idx += 1

        # read the next file if we got to the end, and exit the loop if we got to the last file already
        if idx >= len(events):
            fileIdx += 1
            if fileIdx >= len(files):
                print("DONE")
                break
            del events[:]
            events = unpackFile(files[fileIdx])
            idx1 = 0

        if (evtNum % 1000 == 0):
            print("Checking event %d" % evtNum)

        evt = events[idx]
        err = checkEventErrors(evt)
        if len(err) > 0:
            errors.append(["Global event #%d (file %d, local event #%d)" % (evtNum, fileIdx, idx)] + err)


    print("===================================================================")
    print("Total number of events checked: %d" % evtNum)
    print("Total number of events with errors: %d" % len(errors))
    print("===================================================================")

    if (len(errors) > 0):
        printRed("===============================================================")
        printRed("======================= ERRORS ================================")
        printRed("===============================================================")

        for err in errors:
            printRed(err[0])
            for i in range(1, len(err)):
                printRed("    %s" % err[i])

if __name__ == '__main__':
    main()
