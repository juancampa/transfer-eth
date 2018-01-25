#!/bin/bash

# Description
#
# Transfer from one account to another taking into account the gas costs and
# working around the geth (javascript) number precision limitations
#
# Usage:
#
# transfer <from> <to> <ether-amount>
#
# Note: a geth instance must be running with --rpc
# Note: the "from" account must be unlocked first
#
# Author: Juan Campa

from=$1
to=$2
amount=$3

weiAmount=`geth attach --exec "console.log(web3.toWei(\"$3\"))" | head -1`
gasPrice=`geth attach --exec 'x = eth.getGasPrice(function(e, v) { console.log(v) })' | head -1`
gasEstimate=`geth attach --exec "x = eth.estimateGas({ from: \"$1\", to: \"$2\" })"`

echo Transfering...
echo From $from
echo To $to
echo Amount \(ether\) $amount
echo Amount \(wei\) $weiAmount
echo Gas Price \(wei\) $gasPrice
echo Gas Estimate \(wei\) $gasEstimate

# Confirm
read -n1 -r -p "[y/N]" key
echo

if [ "$key" != "y" ]; then
    echo Aborting
    exit 1
fi

echo Converting values to hex...
hexValue=0x$(echo "obase=16;$weiAmount-($gasEstimate*$gasPrice)"|bc);
hexGasPrice=0x$(echo "obase=16;$gasPrice"|bc);
hexGasEstimate=0x$(echo "obase=16;$gasEstimate"|bc);

echo Transfering...
echo geth attach --exec "eth.sendTransaction({ from: \"$from\", to: \"$to\", value: \"$hexValue\", gasPrice: \"$hexGasPrice\", gas: \"$hexGasEstimate\" })"

