import sys
alignment_sequence_path=sys.argv[1]
alignment_database_path=sys.argv[2]
misses_path=sys.argv[3]
mock=sys.argv[4]
pipeline=sys.argv[5]

def read_alignment(exact,partial,alignment_path):
    tag=0
    alignment_file=open(alignment_path,'r')
    for line in alignment_file:
        if tag==0:
            tag=1
            continue
        line=line.strip()
        fields=line.split('\t')
        if float(fields[3])==100.00 and float(fields[14])==1.0:
            exact+=1        
        elif float(fields[3])>=97.00 and float(fields[14])==1.0:
            print(fields[2])
            partial+=1
    return(exact,partial)

unmatched=0
misses=open(misses_path,'r')
for line in misses:
    line=line.strip()
    if line[0]=='>':
        unmatched+=1



sequence_alignment=read_alignment(0,0,alignment_sequence_path)
print(sequence_alignment)
try:
    database_alignment=read_alignment(0,0,alignment_database_path)
except:
    database_alignment=(0,0)
print(database_alignment)

output=open('feature_'+mock+'_'+pipeline+'.tsv','w')
output.write('Exact sequence'+'\t'+str(sequence_alignment[0])+'\t'+pipeline+'\n'+'Partial sequence'+'\t'+str(sequence_alignment[1])+'\t'+pipeline+'\n'+'Exact database'+'\t'+str(database_alignment[0])+'\t'+pipeline+'\n'+'Partial database'+'\t'+str(database_alignment[1])+'\t'+pipeline+'\n'+'Unmatched'+'\t'+str(unmatched)+'\t'+pipeline+'\n')

