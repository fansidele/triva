#!/bin/bash

ps2epsi triva-output.ps
eps2eps triva-output.epsi triva-output.eps
rm triva-output.ps
rm triva-output.epsi
