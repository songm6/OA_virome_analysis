#!/usr/bin/env python3
import sys,re
argvs = sys.argv

run_Id = re.sub(r".+\/(SRR[0-9]+)_.+",r"\1",argvs[1])

f1 = open(argvs[1])
f2 = open(argvs[2])
max_Eval = float(argvs[3])

score_d1 = {}
score_d2 = {}

score_d_l = [score_d1, score_d2]
f_l = [f1,f2]

for i in range(2):
    for line in f_l[i]:
        ls = line.strip().split("\t")
        if ls[0] not in score_d_l[i]:
            score_d_l[i][ls[0]] = [ls[1],float(ls[10])]
        else:
            if score_d_l[i][ls[0]][1] > float(ls[10]):
                score_d_l[i][ls[0]] = [ls[1],float(ls[10])]

f1.close()
f2.close()

count_d = {}
for i in range(2):
    for k in score_d_l[i]:
        if score_d_l[i][k][1] <= max_Eval:
            if score_d_l[i][k][0] not in count_d:
                count_d[score_d_l[i][k][0]] = 1
            else:
                count_d[score_d_l[i][k][0]] += 1

print("target\t" + run_Id)
for k in count_d:
    print(k + "\t" + str(count_d[k]))
