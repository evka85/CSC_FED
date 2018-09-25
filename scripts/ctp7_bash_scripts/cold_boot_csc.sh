#!/bin/sh

echo "CTP7 Virtex-7 cold boot in progress..."

echo "Configuring reference clocks..."

# First initialize ref clocks before loading the V7 firmware (160 MHz refclk)
clockinit GEM_SynthA_125in_200_off_out.txt 320_160 B1 A0 A0 B1

sleep 1

false
RETVAL=$?

while [ $RETVAL -ne 0 ]
do
    v7load csc_ctp7.bit
    RETVAL=$?
done

# Disable Opto TX Lasers
/bin/txpower enable

# Configure GTHs in loopback mode
sh gth_config_opto.sh
#sh gth_config_opto_tx_inverted.sh

# GTH channel reset procedure
sh gth_reset.sh

#Print gth status register
sh gth_status.sh

