#!/bin/bash
# Sjednotit zápis času mezi Windows a Linux systémem.

timedatectl set-local-rtc 1 --adjust-system-clock

