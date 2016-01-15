#!/usr/bin/env python

import argparse
import pdb
import numpy as np

parser = argparse.ArgumentParser()
parser.add_argument('fin', help='input file')
parser.add_argument('fout', help='output file')
args=parser.parse_args()

fi=open(args.fin,'r')
fo=open(args.fout,'w')
year=[]
mon=[]
prec=[]
data=[]
for line in fi:
	lc=line.split()
	year.append(float(lc[0]))
	mon.append(float(lc[1]))
	prec.append(float(lc[2]))
yst=1961
yed=2010
for month in range(1,13):
	dmon=[prec[i] for i in range(0,len(year)) if (year[i]>=yst and year[i]<=yed and mon[i]==month)]
	dmon=np.sort(dmon)
	data.append(dmon)
cont=args.fout
for month in range(0,12):
		for j in range(0,len(data[0])):
			cont=cont+' '+str(data[month][j])
fo.write(cont)
fi.close()
fo.close()

