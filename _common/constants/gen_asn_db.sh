#!/usr/bin/env bash
set -e
pyasn_util_download.py --latest
pyasn_util_convert.py --single rib.*.bz2 ipasn.dat
rm rib.*.bz2
gzip --best ipasn.dat