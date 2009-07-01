#!/bin/bash

if [ -z $1 ]
then
   exit
fi

CORE=`echo $1 | cut -d"." -f1`

ps2epsi $CORE.ps
eps2eps $CORE.epsi $CORE.eps
rm $CORE.ps
rm $CORE.epsi
