#!/bin/bash
# cleardebug.sh
# Clears ~/smartnode/debug.log on a daily basis
# Add the following to the crontab (i.e. crontab -e)
# @daily ~/smartnode/cleardebug.sh

cd ~/.smartcash
>debug.log
