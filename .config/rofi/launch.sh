#!/bin/bash

G_MESSAGES_DEBUG=Dialogs.DRun rofi -show drun -drun-display-format {name} -theme simple -filter "$1" 
