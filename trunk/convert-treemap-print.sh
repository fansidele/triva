#!/bin/bash

if [ -z $1 ]
then
   exit
fi

CORE=`echo $1 | cut -d"." -f1`

ps2epsi $CORE.ps
eps2eps $CORE.epsi $CORE.eps
epstopdf $CORE.eps
rm $CORE.ps
rm $CORE.eps
rm $CORE.epsi
