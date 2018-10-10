from utils import *
from data_processing_utils import *
import signal
import sys
import os
import struct
import numpy as np
from time import *

IGNORE_DMBS = [[1, 1], [12, 1]]

def main():

    ldaqFilename1 = ""
    ldaqFilename2 = ""

    if len(sys.argv) < 3:
        print('Usage: local_daq_unpack_compare.py <local_daq_data_file_1> <local_daq_data_file_2>')
        print('File #1 is the reference')
        return
    else:
        ldaqFilename1 = sys.argv[1]
        ldaqFilename2 = sys.argv[2]

    heading('Welcome to Local DAQ raw file unpacking and comparison tool')

    heading("Unpacking the first file")
    tt1 = clock()
    t1 = clock()
    events1 = unpackFile(ldaqFilename1)
    t2 = clock()
    print("Unpacking the first file took %f" % (t2 - t1))

    heading("Unpacking the second file")
    t1 = clock()
    events2 = unpackFile(ldaqFilename2)
    t2 = clock()
    print("Unpacking the second file took %f" % (t2 - t1))

    heading("Comparing the data")
    t1 = clock()
    idx2 = 0
    syncing = True
    skipped_events_syncing1 = 0
    skipped_events_syncing2 = 0
    mismatched_dmb_blocks = 0
    mismatched_dmb_errs = []
    dmb_number_mismatches = 0
    dmb_blocks_checked = 0
    for idx1 in range(0, len(events1)):
        event1 = events1[idx1]
        l1Id = event1.l1Id
        print("Checking event #%d, L1 ID = %d" % (idx1, l1Id))
        #find the indexes of the DMBs that we want to compare (ignoring the ones in IGNORE_DMBS mask)
        dmbs1 = []
        for dmb in event1.dmbs:
            if [dmb.crateId, dmb.dmbId] not in IGNORE_DMBS:
                dmbs1.append(dmb)

        # if we still have DMBs left here, lets check them against the file 2
        if len(dmbs1) != 0:
            if idx2 >= len(events2):
                break

            if syncing and l1Id > events2[idx2].l1Id:
                while idx2 < len(events2) and events2[idx2].l1Id < l1Id:
                    # printCyan("Syncing the two files (skipping L1 ID %d on file 2, because we need to start at L1 ID %d)" % (events2[idx2].l1Id, l1Id))
                    idx2 += 1
                    skipped_events_syncing2 += 1
                # syncing = False

            if idx2 >= len(events2):
                break

            event2 = events2[idx2]
            if (l1Id != event2.l1Id):
                if syncing and idx1 < 1000 and l1Id < event2.l1Id:
                    # printCyan("Syncing the two files (skipping L1 ID %d on file 1, because we need to start at L1 ID %d)" % (l1Id, event2.l1Id))
                    skipped_events_syncing1 += 1
                    continue
                else:
                    printRed("L1 IDs don't match! expected %d, but found %d in file 2" % (l1Id, event2.l1Id))
                    continue
            # syncing = False
            idx2 += 1
            if (len(dmbs1) != len(event2.dmbs)):
                printRed("The number of DMBs don't match. Expected %d, but found %d in file 2" % (len(dmbs1), len(event2.dmbs)))
                dmb_number_mismatches += 1
            for i in range(0, len(dmbs1)):
                dmb_blocks_checked += 1
                smaller_size = dmbs1[i].words.size
                if event2.dmbs[i].words.size < smaller_size:
                    smaller_size = event2.dmbs[i].words.size
                mismatches = (dmbs1[i].words[0:smaller_size] != event2.dmbs[i].words[0:smaller_size])
                if ((dmbs1[i].words.size != event2.dmbs[i].words.size) or mismatches.any()):
                    printRed("DMB words don't match")
                    dumpEventsNumpy(dmbs1[i].words, event2.dmbs[i].words)
                    mismatched_dmb_blocks += 1
                    firstMismatchStr = "none"
                    if mismatches.any():
                        firstMismatch64Idx = np.where(mismatches == True)[0][0]
                        firstMismatch64_1 = int(dmbs1[i].words[firstMismatch64Idx])
                        firstMismatch64_2 = int(event2.dmbs[i].words[firstMismatch64Idx])
                        for j in range(0, 4):
                            word16_1 = (firstMismatch64_1 >> (16*j)) & 0xffff
                            word16_2 = (firstMismatch64_2 >> (16*j)) & 0xffff
                            if word16_1 != word16_2:
                                firstMismatchStr = hexPadded(word16_1, 2, True) + " ---- " + hexPadded(word16_2, 2, True)
                                break
                    mismatched_dmb_errs.append("Crate %d DMB %d, event %d, first mismatched word = %s" % (dmbs1[i].crateId, dmbs1[i].dmbId, idx1, firstMismatchStr))
                    # return

    print("Total number of events skipped due to syncing on file1 = %d, file2 = %d" % (skipped_events_syncing1, skipped_events_syncing2))
    if (mismatched_dmb_blocks > 0):
        printRed("Total mismatched DMB words = %d out of %d checked" % (mismatched_dmb_blocks, dmb_blocks_checked))
        for dmbId in mismatched_dmb_errs:
            printRed("      %s" % dmbId)
    else:
        print("Total mismatched DMB words = %d out of %d checked" % (mismatched_dmb_blocks, dmb_blocks_checked))

    print("Number of events with different number of DMBs = %d" % dmb_number_mismatches)

    t2 = clock()
    tt2 = clock()
    print("Comparing the data took %f" % (t2 - t1))
    print("Total time spent = %f" % (tt2 - tt1))

if __name__ == '__main__':
    main()
