#!/bin/sh
umount /media/Project || lsof /media/Project
umount /media/wontstay
umount /media/Trialog || lsof /media/Project
umount /media/User
