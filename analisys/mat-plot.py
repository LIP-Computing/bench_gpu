#########################################################################
# Developed in the framework of INDIGO project,
#
# Author: Mario David <mariojmdavid@gmail.com>
#########################################################################

import os
import pprint
import numpy as np
import matplotlib.pyplot as plt
import csv

if __name__ == '__main__':
    # TODO; this is input arg
    csvfile = "/home/david/Dropbox/AA-work/bench-run4/bench-results01-4th-bench-1.csv"

    csvhead = ['Case', 'Machine', 'Time', 'STDev']
    machs = {}
    machs['QK5200'] = ['Phys-C7-QK5200',
                       'Dock-C7-QK5200',
                       'Dock-U16-QK5200',
                       'UDock-C7-QK5200',
                       'UDock-U16-QK5200']

    machs['TK40'] = ['VM-U16-TK40',
                     'Dock-C7-TK40',
                     'Dock-U16-TK40',
                     'UDock-C7-TK40',
                     'UDock-U16-TK40']
    
    cases = ['RNA-polymerase-II Angle = 5 VoxSpac = 1',
             'PRE5-PUP2-complex Angle = 5 VoxSpac = 1',
             'GroEL-GroES Angle = 4.71 resolution = 23',
             'RsgA-ribosome Angle = 4.71 resolution = 13.3']

    i = 0
#    allfig = []
#    for case in cases:
#        for mach in machs:
#            allfig[i] = plt.figure()
#            i += 1

    nbars = 5
    index = np.arange(nbars)
    bar_width = 0.35
    error_config = {'ecolor': '0.3'}
    mc = []
    rtime = []
    rstdev = []
    with open(csvfile, 'rb') as cf:
        rowdata = csv.DictReader(cf)
        for row in rowdata:
            mc.append(row['Machine'])
            rtime.append(float(row['Time']))
            rstdev.append(float(row['STDev']))
            lbl = row['Case']
            #print(row['Case'], row['Machine'], float(row['Time']), float(row['STDev']))

    bplt = plt.bar(index, rtime, bar_width,
                   color='b',
                   yerr=rstdev,
                   error_kw=error_config,
                   label=lbl)
    plt.show()
