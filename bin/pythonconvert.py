#!/bin/bash

python3 - "$1" "$2" <<'EOF'
import sys
import pandas as pd

infile  = sys.argv[1]
outfile = sys.argv[2]

df = pd.read_csv(infile, sep="\t")
df.to_excel(outfile, index=False)
EOF
