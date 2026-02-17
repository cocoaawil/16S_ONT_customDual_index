#! /usr/bin/awk -f 

BEGIN{n=split(ARGV[1],a,"/");split(a[n],b,".")}
NR==1 {print "Sample_ID\t"$0}
NR!=1 {print b[1]"\t"$0}