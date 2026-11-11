#!/bin/bash

env LUTRIS_SKIP_INIT=1 lutris lutris:rungameid/12 &
obs &
pkill picom &
