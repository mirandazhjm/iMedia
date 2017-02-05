__author__ = 'Jingmei'

import csv
with open('users.tsv','rb') as tsvin, open('new.csv', 'wb') as csvout:
    tsvin = csv.reader(tsvin, delimiter='\t')
    csvout = csv.writer(csvout)
    for row in tsvin:
        if row[2]=='NA':
            row[2]=str(0)
            csvout.writerow(row)
        else: csvout.writerow(row)

