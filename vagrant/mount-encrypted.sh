#!/bin/bash

cryptsetup luksOpen /dev/sdc1 USB
mount /dev/mapper/USB /mnt/

