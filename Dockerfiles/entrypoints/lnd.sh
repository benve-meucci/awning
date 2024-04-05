#!/bin/bash

if [ ! -f /data/.lnd/password.txt ]; then
  echo $LND_PASSWORD > /data/.lnd/password.txt
  mkdir -p /data/lnd/data/chain/bitcoin/mainnet/
fi
lnd

