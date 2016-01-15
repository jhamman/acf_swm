#!/usr/bin/env python

import argparse
import pdb
from numpy import mean

parser = argparse.ArgumentParser()
parser.add_argument('fin', help='input file')
parser.add_argument('fout', help='output file')
args=parser.parse_args()

fi=open(args.fin,'r')
fo=open(args.fout,'w')
p=[]
tx=[]
tn=[]
pr=[]
txr=[]
tnr=[]
yr=[]
mr=[]

next(fi)

for line in fi:
	ls=line.split()
	if len(p)==0:
		p.append(float(ls[3]))
		tx.append(float(ls[4]))
		tn.append(float(ls[5]))
		yo=float(ls[0])
		mo=float(ls[1])
	else:
		yn=float(ls[0])
		mn=float(ls[1])
		if (yo==yn) and (mn==mo):
			p.append(float(ls[3]))
			tx.append(float(ls[4]))
			tn.append(float(ls[5]))
		else:
			if not(all(x==-99.0 for x in p)):
				p=[x for x in p if x != -99.0]
			pr.append(mean(p))
			if not(all(x==-99.0 for x in tx)):
				tx=[x for x in tx if x != -99.0]
			txr.append(mean(tx))
			if not(all(x==-99.0 for x in tn)):
				tn=[x for x in tn if x != -99.0]
			tnr.append(mean(tn))
			yr.append(yo)
			mr.append(mo)
			p=[float(ls[3])]
			tx=[float(ls[4])]
			tn=[float(ls[5])]
			yo=float(ls[0])
			mo=float(ls[1])

if not(all(x==-99.0 for x in p)):
    p=[x for x in p if x != -99.0]
pr.append(mean(p))
if not(all(x==-99.0 for x in tx)):
    tx=[x for x in tx if x != -99.0]
txr.append(mean(tx))
if not(all(x==-99.0 for x in tn)):
    tn=[x for x in tn if x != -99.0]
tnr.append(mean(tn))

yr.append(float(ls[0]))
mr.append(float(ls[1]))

for i in range(0,len(pr)):
	cont=str(int(yr[i]))+' '+ str(int(mr[i])).zfill(2)+' '+\
	     str("{0:.2f}".format(pr[i]))+' '+\
             str("{0:.2f}".format(txr[i]))+' '+\
	     str("{0:.2f}".format(tnr[i]))+'\n'
	fo.write(cont)

fi.close()
fo.close()

