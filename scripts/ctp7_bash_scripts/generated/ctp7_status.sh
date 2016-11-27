#!/bin/sh

MODULE=$1
if [ -z "$MODULE" ]; then
    echo "Usage: this_script.sh <module_name>"
    echo "Available modules:"
    echo "TTC"    echo "SYSTEM"    echo "LINKS"    echo "DAQ"    exit
fi

if [ "$MODULE" = "TTC" ]; then
    printf 'CSC_FED.TTC.CTRL.L1A_ENABLE                   = 0x%x\n' $(( (`mpeek 0x64c00010` & 0x00000001) >> 0 ))
    printf 'CSC_FED.TTC.CONFIG.CMD_BC0                    = 0x%x\n' $(( (`mpeek 0x64c00014` & 0x000000ff) >> 0 ))
    printf 'CSC_FED.TTC.CONFIG.CMD_EC0                    = 0x%x\n' $(( (`mpeek 0x64c00014` & 0x0000ff00) >> 8 ))
    printf 'CSC_FED.TTC.CONFIG.CMD_RESYNC                 = 0x%x\n' $(( (`mpeek 0x64c00014` & 0x00ff0000) >> 16 ))
    printf 'CSC_FED.TTC.CONFIG.CMD_OC0                    = 0x%x\n' $(( (`mpeek 0x64c00014` & 0xff000000) >> 24 ))
    printf 'CSC_FED.TTC.CONFIG.CMD_HARD_RESET             = 0x%x\n' $(( (`mpeek 0x64c00018` & 0x000000ff) >> 0 ))
    printf 'CSC_FED.TTC.CONFIG.CMD_CALPULSE               = 0x%x\n' $(( (`mpeek 0x64c00018` & 0x0000ff00) >> 8 ))
    printf 'CSC_FED.TTC.CONFIG.CMD_START                  = 0x%x\n' $(( (`mpeek 0x64c00018` & 0x00ff0000) >> 16 ))
    printf 'CSC_FED.TTC.CONFIG.CMD_STOP                   = 0x%x\n' $(( (`mpeek 0x64c00018` & 0xff000000) >> 24 ))
    printf 'CSC_FED.TTC.CONFIG.CMD_TEST_SYNC              = 0x%x\n' $(( (`mpeek 0x64c0001c` & 0x000000ff) >> 0 ))
    printf 'CSC_FED.TTC.STATUS.MMCM_LOCKED                = 0x%x\n' $(( (`mpeek 0x64c00020` & 0x00000001) >> 0 ))
    printf 'CSC_FED.TTC.STATUS.TTC_SINGLE_ERROR_CNT       = 0x%x\n' $(( (`mpeek 0x64c00024` & 0x0000ffff) >> 0 ))
    printf 'CSC_FED.TTC.STATUS.TTC_DOUBLE_ERROR_CNT       = 0x%x\n' $(( (`mpeek 0x64c00024` & 0xffff0000) >> 16 ))
    printf 'CSC_FED.TTC.STATUS.BC0.LOCKED                 = 0x%x\n' $(( (`mpeek 0x64c00028` & 0x00000001) >> 0 ))
    printf 'CSC_FED.TTC.STATUS.BC0.UNLOCK_CNT             = 0x%x\n' $(( (`mpeek 0x64c0002c` & 0x0000ffff) >> 0 ))
    printf 'CSC_FED.TTC.STATUS.BC0.OVERFLOW_CNT           = 0x%x\n' $(( (`mpeek 0x64c00030` & 0x0000ffff) >> 0 ))
    printf 'CSC_FED.TTC.STATUS.BC0.UNDERFLOW_CNT          = 0x%x\n' $(( (`mpeek 0x64c00030` & 0xffff0000) >> 16 ))
    printf 'CSC_FED.TTC.CMD_COUNTERS.L1A                  = 0x%x\n' `mpeek 0x64c00034` 
    printf 'CSC_FED.TTC.CMD_COUNTERS.BC0                  = 0x%x\n' `mpeek 0x64c00038` 
    printf 'CSC_FED.TTC.CMD_COUNTERS.EC0                  = 0x%x\n' `mpeek 0x64c0003c` 
    printf 'CSC_FED.TTC.CMD_COUNTERS.RESYNC               = 0x%x\n' `mpeek 0x64c00040` 
    printf 'CSC_FED.TTC.CMD_COUNTERS.OC0                  = 0x%x\n' `mpeek 0x64c00044` 
    printf 'CSC_FED.TTC.CMD_COUNTERS.HARD_RESET           = 0x%x\n' `mpeek 0x64c00048` 
    printf 'CSC_FED.TTC.CMD_COUNTERS.CALPULSE             = 0x%x\n' `mpeek 0x64c0004c` 
    printf 'CSC_FED.TTC.CMD_COUNTERS.START                = 0x%x\n' `mpeek 0x64c00050` 
    printf 'CSC_FED.TTC.CMD_COUNTERS.STOP                 = 0x%x\n' `mpeek 0x64c00054` 
    printf 'CSC_FED.TTC.CMD_COUNTERS.TEST_SYNC            = 0x%x\n' `mpeek 0x64c00058` 
    printf 'CSC_FED.TTC.L1A_ID                            = 0x%x\n' $(( (`mpeek 0x64c0005c` & 0x00ffffff) >> 0 ))
    printf 'CSC_FED.TTC.L1A_RATE                          = 0x%x\n' `mpeek 0x64c00060` 
    printf 'CSC_FED.TTC.TTC_SPY_BUFFER                    = 0x%x\n' `mpeek 0x64c00064` 
fi

if [ "$MODULE" = "SYSTEM" ]; then
    printf 'CSC_FED.SYSTEM.BOARD_ID                       = 0x%x\n' $(( (`mpeek 0x64400008` & 0x0000ffff) >> 0 ))
    printf 'CSC_FED.SYSTEM.BOARD_TYPE                     = 0x%x\n' $(( (`mpeek 0x64400008` & 0x000f0000) >> 16 ))
    printf 'CSC_FED.SYSTEM.RELEASE.BUILD                  = 0x%x\n' $(( (`mpeek 0x6440000c` & 0x000000ff) >> 0 ))
    printf 'CSC_FED.SYSTEM.RELEASE.MINOR                  = 0x%x\n' $(( (`mpeek 0x6440000c` & 0x0000ff00) >> 8 ))
    printf 'CSC_FED.SYSTEM.RELEASE.MAJOR                  = 0x%x\n' $(( (`mpeek 0x6440000c` & 0x00ff0000) >> 16 ))
    printf 'CSC_FED.SYSTEM.RELEASE.DATE                   = 0x%x\n' `mpeek 0x64400010` 
    printf 'CSC_FED.SYSTEM.CONFIG.NUM_OF_DMBS             = 0x%x\n' $(( (`mpeek 0x64400014` & 0x000000ff) >> 0 ))
fi

if [ "$MODULE" = "LINKS" ]; then
    printf 'CSC_FED.LINKS.DMB0.MGT_BUF_OVF_CNT            = 0x%x\n' $(( (`mpeek 0x64800040` & 0x0000ffff) >> 0 ))
    printf 'CSC_FED.LINKS.DMB0.MGT_BUF_UNF_CNT            = 0x%x\n' $(( (`mpeek 0x64800040` & 0xffff0000) >> 16 ))
    printf 'CSC_FED.LINKS.DMB0.CLK_CORR_ADD_CNT           = 0x%x\n' $(( (`mpeek 0x64800044` & 0x0000ffff) >> 0 ))
    printf 'CSC_FED.LINKS.DMB0.CLK_CORR_DROP_CNT          = 0x%x\n' $(( (`mpeek 0x64800044` & 0xffff0000) >> 16 ))
    printf 'CSC_FED.LINKS.DMB0.NOT_IN_TABLE_CNT           = 0x%x\n' $(( (`mpeek 0x64800048` & 0x0000ffff) >> 0 ))
    printf 'CSC_FED.LINKS.DMB0.DISPERR_CNT                = 0x%x\n' $(( (`mpeek 0x64800048` & 0xffff0000) >> 16 ))
    printf 'CSC_FED.LINKS.DMB1.MGT_BUF_OVF_CNT            = 0x%x\n' $(( (`mpeek 0x64800080` & 0x0000ffff) >> 0 ))
    printf 'CSC_FED.LINKS.DMB1.MGT_BUF_UNF_CNT            = 0x%x\n' $(( (`mpeek 0x64800080` & 0xffff0000) >> 16 ))
    printf 'CSC_FED.LINKS.DMB1.CLK_CORR_ADD_CNT           = 0x%x\n' $(( (`mpeek 0x64800084` & 0x0000ffff) >> 0 ))
    printf 'CSC_FED.LINKS.DMB1.CLK_CORR_DROP_CNT          = 0x%x\n' $(( (`mpeek 0x64800084` & 0xffff0000) >> 16 ))
    printf 'CSC_FED.LINKS.DMB1.NOT_IN_TABLE_CNT           = 0x%x\n' $(( (`mpeek 0x64800088` & 0x0000ffff) >> 0 ))
    printf 'CSC_FED.LINKS.DMB1.DISPERR_CNT                = 0x%x\n' $(( (`mpeek 0x64800088` & 0xffff0000) >> 16 ))
    printf 'CSC_FED.LINKS.SPY.MGT_BUF_OVF_CNT             = 0x%x\n' $(( (`mpeek 0x64802800` & 0x0000ffff) >> 0 ))
    printf 'CSC_FED.LINKS.SPY.MGT_BUF_UNF_CNT             = 0x%x\n' $(( (`mpeek 0x64802800` & 0xffff0000) >> 16 ))
    printf 'CSC_FED.LINKS.SPY.CLK_CORR_ADD_CNT            = 0x%x\n' $(( (`mpeek 0x64802804` & 0x0000ffff) >> 0 ))
    printf 'CSC_FED.LINKS.SPY.CLK_CORR_DROP_CNT           = 0x%x\n' $(( (`mpeek 0x64802804` & 0xffff0000) >> 16 ))
    printf 'CSC_FED.LINKS.SPY.NOT_IN_TABLE_CNT            = 0x%x\n' $(( (`mpeek 0x64802808` & 0x0000ffff) >> 0 ))
    printf 'CSC_FED.LINKS.SPY.DISPERR_CNT                 = 0x%x\n' $(( (`mpeek 0x64802808` & 0xffff0000) >> 16 ))
fi

if [ "$MODULE" = "DAQ" ]; then
    printf 'CSC_FED.DAQ.CONTROL.DAQ_ENABLE                = 0x%x\n' $(( (`mpeek 0x65000000` & 0x00000001) >> 0 ))
    printf 'CSC_FED.DAQ.CONTROL.IGNORE_AMC13              = 0x%x\n' $(( (`mpeek 0x65000000` & 0x00000002) >> 1 ))
    printf 'CSC_FED.DAQ.CONTROL.DAQ_LINK_RESET            = 0x%x\n' $(( (`mpeek 0x65000000` & 0x00000004) >> 2 ))
    printf 'CSC_FED.DAQ.CONTROL.RESET                     = 0x%x\n' $(( (`mpeek 0x65000000` & 0x00000008) >> 3 ))
    printf 'CSC_FED.DAQ.CONTROL.TTS_OVERRIDE              = 0x%x\n' $(( (`mpeek 0x65000000` & 0x000000f0) >> 4 ))
    printf 'CSC_FED.DAQ.CONTROL.INPUT_ENABLE_MASK         = 0x%x\n' $(( (`mpeek 0x65000000` & 0xffffff00) >> 8 ))
    printf 'CSC_FED.DAQ.STATUS.DAQ_LINK_RDY               = 0x%x\n' $(( (`mpeek 0x65000004` & 0x00000001) >> 0 ))
    printf 'CSC_FED.DAQ.STATUS.DAQ_CLK_LOCKED             = 0x%x\n' $(( (`mpeek 0x65000004` & 0x00000002) >> 1 ))
    printf 'CSC_FED.DAQ.STATUS.TTC_RDY                    = 0x%x\n' $(( (`mpeek 0x65000004` & 0x00000004) >> 2 ))
    printf 'CSC_FED.DAQ.STATUS.DAQ_LINK_AFULL             = 0x%x\n' $(( (`mpeek 0x65000004` & 0x00000008) >> 3 ))
    printf 'CSC_FED.DAQ.STATUS.DAQ_OUTPUT_FIFO_HAD_OVERFLOW = 0x%x\n' $(( (`mpeek 0x65000004` & 0x00000010) >> 4 ))
    printf 'CSC_FED.DAQ.STATUS.TTC_BC0_LOCKED             = 0x%x\n' $(( (`mpeek 0x65000004` & 0x00000020) >> 5 ))
    printf 'CSC_FED.DAQ.STATUS.L1A_FIFO_HAD_OVERFLOW      = 0x%x\n' $(( (`mpeek 0x65000004` & 0x00800000) >> 23 ))
    printf 'CSC_FED.DAQ.STATUS.L1A_FIFO_IS_UNDERFLOW      = 0x%x\n' $(( (`mpeek 0x65000004` & 0x01000000) >> 24 ))
    printf 'CSC_FED.DAQ.STATUS.L1A_FIFO_IS_FULL           = 0x%x\n' $(( (`mpeek 0x65000004` & 0x02000000) >> 25 ))
    printf 'CSC_FED.DAQ.STATUS.L1A_FIFO_IS_NEAR_FULL      = 0x%x\n' $(( (`mpeek 0x65000004` & 0x04000000) >> 26 ))
    printf 'CSC_FED.DAQ.STATUS.L1A_FIFO_IS_EMPTY          = 0x%x\n' $(( (`mpeek 0x65000004` & 0x08000000) >> 27 ))
    printf 'CSC_FED.DAQ.STATUS.TTS_STATE                  = 0x%x\n' $(( (`mpeek 0x65000004` & 0xf0000000) >> 28 ))
    printf 'CSC_FED.DAQ.EXT_STATUS.NOTINTABLE_ERR         = 0x%x\n' $(( (`mpeek 0x65000008` & 0x0000ffff) >> 0 ))
    printf 'CSC_FED.DAQ.EXT_STATUS.DISPER_ERR             = 0x%x\n' $(( (`mpeek 0x6500000c` & 0x0000ffff) >> 0 ))
    printf 'CSC_FED.DAQ.EXT_STATUS.L1AID                  = 0x%x\n' $(( (`mpeek 0x65000010` & 0x00ffffff) >> 0 ))
    printf 'CSC_FED.DAQ.EXT_STATUS.EVT_SENT               = 0x%x\n' `mpeek 0x65000014` 
    printf 'CSC_FED.DAQ.CONTROL.DAV_TIMEOUT               = 0x%x\n' $(( (`mpeek 0x65000018` & 0x00ffffff) >> 0 ))
    printf 'CSC_FED.DAQ.EXT_STATUS.MAX_DAV_TIMER          = 0x%x\n' $(( (`mpeek 0x6500001c` & 0x00ffffff) >> 0 ))
    printf 'CSC_FED.DAQ.EXT_STATUS.LAST_DAV_TIMER         = 0x%x\n' $(( (`mpeek 0x65000020` & 0x00ffffff) >> 0 ))
    printf 'CSC_FED.DAQ.EXT_STATUS.L1A_FIFO_DATA_CNT      = 0x%x\n' $(( (`mpeek 0x65000024` & 0x00001fff) >> 0 ))
    printf 'CSC_FED.DAQ.EXT_STATUS.DAQ_FIFO_DATA_CNT      = 0x%x\n' $(( (`mpeek 0x65000024` & 0x1fff0000) >> 16 ))
    printf 'CSC_FED.DAQ.EXT_STATUS.L1A_FIFO_NEAR_FULL_CNT = 0x%x\n' $(( (`mpeek 0x65000028` & 0x0000ffff) >> 0 ))
    printf 'CSC_FED.DAQ.EXT_STATUS.DAQ_FIFO_NEAR_FULL_CNT = 0x%x\n' $(( (`mpeek 0x65000028` & 0xffff0000) >> 16 ))
    printf 'CSC_FED.DAQ.EXT_STATUS.DAQ_ALMOST_FULL_CNT    = 0x%x\n' $(( (`mpeek 0x6500002c` & 0x0000ffff) >> 0 ))
    printf 'CSC_FED.DAQ.EXT_STATUS.TTS_WARN_CNT           = 0x%x\n' $(( (`mpeek 0x6500002c` & 0xffff0000) >> 16 ))
    printf 'CSC_FED.DAQ.EXT_STATUS.DAQ_WORD_RATE          = 0x%x\n' `mpeek 0x65000030` 
    printf 'CSC_FED.DAQ.EXT_CONTROL.RUN_PARAMS            = 0x%x\n' $(( (`mpeek 0x65000034` & 0x00ffffff) >> 0 ))
    printf 'CSC_FED.DAQ.EXT_CONTROL.RUN_TYPE              = 0x%x\n' $(( (`mpeek 0x65000034` & 0x0f000000) >> 24 ))
    printf 'CSC_FED.DAQ.LAST_EVENT_FIFO.EMPTY             = 0x%x\n' $(( (`mpeek 0x65000038` & 0x00000001) >> 0 ))
    printf 'CSC_FED.DAQ.LAST_EVENT_FIFO.DISABLE           = 0x%x\n' $(( (`mpeek 0x65000038` & 0x80000000) >> 31 ))
    printf 'CSC_FED.DAQ.LAST_EVENT_FIFO.DATA              = 0x%x\n' `mpeek 0x6500003c` 
    printf 'CSC_FED.DAQ.DMB0.STATUS.INPUT_FIFO_HAD_OFLOW  = 0x%x\n' $(( (`mpeek 0x65000040` & 0x00000100) >> 8 ))
    printf 'CSC_FED.DAQ.DMB0.STATUS.INPUT_FIFO_HAD_UFLOW  = 0x%x\n' $(( (`mpeek 0x65000040` & 0x00000200) >> 9 ))
    printf 'CSC_FED.DAQ.DMB0.STATUS.EVENT_FIFO_HAD_OFLOW  = 0x%x\n' $(( (`mpeek 0x65000040` & 0x00000400) >> 10 ))
    printf 'CSC_FED.DAQ.DMB0.STATUS.EVT_SIZE_ERR          = 0x%x\n' $(( (`mpeek 0x65000040` & 0x00000800) >> 11 ))
    printf 'CSC_FED.DAQ.DMB0.STATUS.TTS_STATE             = 0x%x\n' $(( (`mpeek 0x65000040` & 0x0000f000) >> 12 ))
    printf 'CSC_FED.DAQ.DMB0.STATUS.INPUT_FIFO_IS_UFLOW   = 0x%x\n' $(( (`mpeek 0x65000040` & 0x01000000) >> 24 ))
    printf 'CSC_FED.DAQ.DMB0.STATUS.INPUT_FIFO_IS_FULL    = 0x%x\n' $(( (`mpeek 0x65000040` & 0x02000000) >> 25 ))
    printf 'CSC_FED.DAQ.DMB0.STATUS.INPUT_FIFO_IS_AFULL   = 0x%x\n' $(( (`mpeek 0x65000040` & 0x04000000) >> 26 ))
    printf 'CSC_FED.DAQ.DMB0.STATUS.INPUT_FIFO_IS_EMPTY   = 0x%x\n' $(( (`mpeek 0x65000040` & 0x08000000) >> 27 ))
    printf 'CSC_FED.DAQ.DMB0.STATUS.EVENT_FIFO_IS_UFLOW   = 0x%x\n' $(( (`mpeek 0x65000040` & 0x10000000) >> 28 ))
    printf 'CSC_FED.DAQ.DMB0.STATUS.EVENT_FIFO_IS_FULL    = 0x%x\n' $(( (`mpeek 0x65000040` & 0x20000000) >> 29 ))
    printf 'CSC_FED.DAQ.DMB0.STATUS.EVENT_FIFO_IS_AFULL   = 0x%x\n' $(( (`mpeek 0x65000040` & 0x40000000) >> 30 ))
    printf 'CSC_FED.DAQ.DMB0.STATUS.EVENT_FIFO_IS_EMPTY   = 0x%x\n' $(( (`mpeek 0x65000040` & 0x80000000) >> 31 ))
    printf 'CSC_FED.DAQ.DMB0.COUNTERS.EVN                 = 0x%x\n' $(( (`mpeek 0x65000048` & 0x00ffffff) >> 0 ))
    printf 'CSC_FED.DAQ.DMB0.COUNTERS.INPUT_FIFO_DATA_CNT = 0x%x\n' $(( (`mpeek 0x65000050` & 0x00003fff) >> 0 ))
    printf 'CSC_FED.DAQ.DMB0.COUNTERS.EVT_FIFO_DATA_CNT   = 0x%x\n' $(( (`mpeek 0x65000050` & 0x0fff0000) >> 16 ))
    printf 'CSC_FED.DAQ.DMB0.COUNTERS.INPUT_FIFO_NEAR_FULL_CNT = 0x%x\n' $(( (`mpeek 0x65000054` & 0x0000ffff) >> 0 ))
    printf 'CSC_FED.DAQ.DMB0.COUNTERS.EVT_FIFO_NEAR_FULL_CNT = 0x%x\n' $(( (`mpeek 0x65000054` & 0xffff0000) >> 16 ))
    printf 'CSC_FED.DAQ.DMB0.COUNTERS.DATA_WORD_RATE      = 0x%x\n' $(( (`mpeek 0x65000058` & 0x00007fff) >> 0 ))
    printf 'CSC_FED.DAQ.DMB0.COUNTERS.EVT_RATE            = 0x%x\n' $(( (`mpeek 0x65000058` & 0xffff8000) >> 15 ))
    printf 'CSC_FED.DAQ.DMB1.STATUS.INPUT_FIFO_HAD_OFLOW  = 0x%x\n' $(( (`mpeek 0x65000080` & 0x00000100) >> 8 ))
    printf 'CSC_FED.DAQ.DMB1.STATUS.INPUT_FIFO_HAD_UFLOW  = 0x%x\n' $(( (`mpeek 0x65000080` & 0x00000200) >> 9 ))
    printf 'CSC_FED.DAQ.DMB1.STATUS.EVENT_FIFO_HAD_OFLOW  = 0x%x\n' $(( (`mpeek 0x65000080` & 0x00000400) >> 10 ))
    printf 'CSC_FED.DAQ.DMB1.STATUS.EVT_SIZE_ERR          = 0x%x\n' $(( (`mpeek 0x65000080` & 0x00000800) >> 11 ))
    printf 'CSC_FED.DAQ.DMB1.STATUS.TTS_STATE             = 0x%x\n' $(( (`mpeek 0x65000080` & 0x0000f000) >> 12 ))
    printf 'CSC_FED.DAQ.DMB1.STATUS.INPUT_FIFO_IS_UFLOW   = 0x%x\n' $(( (`mpeek 0x65000080` & 0x01000000) >> 24 ))
    printf 'CSC_FED.DAQ.DMB1.STATUS.INPUT_FIFO_IS_FULL    = 0x%x\n' $(( (`mpeek 0x65000080` & 0x02000000) >> 25 ))
    printf 'CSC_FED.DAQ.DMB1.STATUS.INPUT_FIFO_IS_AFULL   = 0x%x\n' $(( (`mpeek 0x65000080` & 0x04000000) >> 26 ))
    printf 'CSC_FED.DAQ.DMB1.STATUS.INPUT_FIFO_IS_EMPTY   = 0x%x\n' $(( (`mpeek 0x65000080` & 0x08000000) >> 27 ))
    printf 'CSC_FED.DAQ.DMB1.STATUS.EVENT_FIFO_IS_UFLOW   = 0x%x\n' $(( (`mpeek 0x65000080` & 0x10000000) >> 28 ))
    printf 'CSC_FED.DAQ.DMB1.STATUS.EVENT_FIFO_IS_FULL    = 0x%x\n' $(( (`mpeek 0x65000080` & 0x20000000) >> 29 ))
    printf 'CSC_FED.DAQ.DMB1.STATUS.EVENT_FIFO_IS_AFULL   = 0x%x\n' $(( (`mpeek 0x65000080` & 0x40000000) >> 30 ))
    printf 'CSC_FED.DAQ.DMB1.STATUS.EVENT_FIFO_IS_EMPTY   = 0x%x\n' $(( (`mpeek 0x65000080` & 0x80000000) >> 31 ))
    printf 'CSC_FED.DAQ.DMB1.COUNTERS.EVN                 = 0x%x\n' $(( (`mpeek 0x65000088` & 0x00ffffff) >> 0 ))
    printf 'CSC_FED.DAQ.DMB1.COUNTERS.INPUT_FIFO_DATA_CNT = 0x%x\n' $(( (`mpeek 0x65000090` & 0x00003fff) >> 0 ))
    printf 'CSC_FED.DAQ.DMB1.COUNTERS.EVT_FIFO_DATA_CNT   = 0x%x\n' $(( (`mpeek 0x65000090` & 0x0fff0000) >> 16 ))
    printf 'CSC_FED.DAQ.DMB1.COUNTERS.INPUT_FIFO_NEAR_FULL_CNT = 0x%x\n' $(( (`mpeek 0x65000094` & 0x0000ffff) >> 0 ))
    printf 'CSC_FED.DAQ.DMB1.COUNTERS.EVT_FIFO_NEAR_FULL_CNT = 0x%x\n' $(( (`mpeek 0x65000094` & 0xffff0000) >> 16 ))
    printf 'CSC_FED.DAQ.DMB1.COUNTERS.DATA_WORD_RATE      = 0x%x\n' $(( (`mpeek 0x65000098` & 0x00007fff) >> 0 ))
    printf 'CSC_FED.DAQ.DMB1.COUNTERS.EVT_RATE            = 0x%x\n' $(( (`mpeek 0x65000098` & 0xffff8000) >> 15 ))
fi

