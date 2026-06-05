#!/bin/bash

# ----------------------------------------------------------
# 			  R36H Pro Max CPU 1512Mhz Overclock 
#						 by djparent
#     Based on initial discovery and work by u/Wivi2013
# ----------------------------------------------------------

if [ "$(id -u)" -ne 0 ]; then
    exec sudo -- "$0" "$@"
fi

if ! which dtc &>/dev/null; then
    apt-get install -y device-tree-compiler
fi

for f in /boot/*.dtb.bak; do
    cp "$f" "${f%.bak}"
done

for f in /boot/*.dtb; do
    [[ -f "$f.bak" ]] || cp "$f" "$f.bak"
done

for f in /boot/*.dtb; do
    dtc -I dtb -O dts -o "${f%.dtb}.dts" "$f"
done

SEARCH='		opp-1296000000 {
			opp-hz = < 0x00 0x4d3f6400 >;
			opp-microvolt = < 0x149970 0x149970 0x149970 >;
			opp-microvolt-L0 = < 0x149970 0x149970 0x149970 >;
			opp-microvolt-L1 = < 0x149970 0x149970 0x149970 >;
			opp-microvolt-L2 = < 0x13d620 0x13d620 0x149970 >;
			opp-microvolt-L3 = < 0x1312d0 0x1312d0 0x149970 >;
			clock-latency-ns = < 0x9c40 >;
		};'

INSERT='

		opp-1512000000 {
			opp-hz = < 0x00 0x5a1f4a00 >;
			opp-microvolt = < 0x149970 0x149970 0x149970 >;
			opp-microvolt-L0 = < 0x149970 0x149970 0x149970 >;
			opp-microvolt-L1 = < 0x149970 0x149970 0x149970 >;
			opp-microvolt-L2 = < 0x13d620 0x13d620 0x149970 >;
			opp-microvolt-L3 = < 0x1312d0 0x1312d0 0x149970 >;
			clock-latency-ns = < 0x9c40 >;
		};'

for f in /boot/*.dts; do
patched=$(python3 - "$f" <<EOF
import sys
path = sys.argv[1]
search = '''$SEARCH'''
insert = '''$INSERT'''
content = open(path).read()
if search in content and insert.strip() not in content:
    open(path, 'w').write(content.replace(search, search + insert))
    print("yes")
EOF
)
    dtb="${f%.dts}.dtb"
    if [[ "$patched" == "yes" ]]; then
        echo "Patched: $f"
    else
        rm -f "$dtb.bak"
    fi
done

for f in /boot/*.dts; do
    dtb="${f%.dts}.dtb"
    [[ -f "$dtb.bak" ]] || rm -f "$f"
done

for f in /boot/*.dts; do
    dtc -I dts -O dtb -o "${f%.dts}.dtb" "$f"
done

rm -f /boot/*.dts

reboot