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
    csvfile = "/home/david/Dropbox/AA-work/bench-run4/bench-results01-4th-bench.csv"

    csvhead = ['Case', 'Machine', 'Time', 'STDev']
    machines = ['Phys-C7-QK5200',
                'Dock-C7-QK5200',
                'Dock-U16-QK5200',
                'UDock-C7-QK5200',
                'UDock-U16-QK5200',
                'VM-U16-TK40',
                'Dock-C7-TK40',
                'Dock-U16-TK40',
                'UDock-C7-TK40',
                'UDock-U16-TK40']
    
    cases = ['RNA-polymerase-II Angle = 5 VoxSpac = 1',
             'PRE5-PUP2-complex Angle = 5 VoxSpac = 1',
             'GroEL-GroES Angle = 4.71 resolution = 23',
             'RsgA-ribosome Angle = 4.71 resolution = 13.3']
    
    with open(csvfile, 'rb') as cf:
        rowdata = csv.DictReader(cf)
        for row in rowdata:
            print(row['Case'], row['Machine'])
