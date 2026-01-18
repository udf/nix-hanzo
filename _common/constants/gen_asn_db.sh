#!/usr/bin/env nix-shell
#! nix-shell -i bash -p python3Packages.pyasn
set -e
pyasn_util_download.py --latest
pyasn_util_convert.py --single rib.*.bz2 ipasn.dat
pyasn_util_asnames.py -o asnames.json
rm rib.*.bz2
gzip -f --best ipasn.dat