#!/bin/bash

cryptsetup luksOpen /dev/sda1 USB
mount /dev/mapper/USB /mnt/

