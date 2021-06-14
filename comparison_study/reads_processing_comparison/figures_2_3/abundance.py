import sys
alignment_path=sys.argv[1]
misses_path=sys.argv[2]
table_path=sys.argv[3]
mock=sys.argv[4]
pipeline=sys.argv[5]
alignment=open(alignment_path,'r')
table=open(table_path,'r')
tag=0
dic_alignment={}
dic_alignment['non_reference']=[]
for line in alignment:
    if tag==0:
        tag=1
        continue
    line=line.strip()
    fields=line.split('\t')
    if float(fields[3])==100.00 and float(fields[14])==1.0:
        if fields[2][:-2] not in dic_alignment:        
            dic_alignment[fields[2]]=[]
            dic_alignment[fields[2]].append(fields[1])
        else:
            dic_alignment[fields[2]].append(fields[1])

misses=open(misses_path,'r')
for line in misses:
    line=line.strip()
    if line[0]=='>':
        dic_alignment['non_reference'].append(line[1:]) 
    

dic_table={}
total=0
for line in table:
    if line[0]==',':
        continue
    line=line.strip()
    fields=line.split(',')
    dic_table[fields[0]]=float(fields[1])
    total+=float(fields[1])
print(dic_table)
dic_final={}
for bacteria in dic_alignment:
    dic_final[bacteria]=0    
    for otu in dic_alignment[bacteria]:
        dic_final[bacteria]+=dic_table[otu]

output=open('abundance_'+mock+'_'+pipeline+'.tsv','w')
for bacteria in dic_final:
    output.write(bacteria+'\t'+str(dic_final[bacteria]/total)+'\t'+pipeline+'\n')

