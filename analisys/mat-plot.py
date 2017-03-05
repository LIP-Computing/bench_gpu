#########################################################################
# Developed in the framework of INDIGO project,
#
# Author: Mario David <mariojmdavid@gmail.com>
#########################################################################

import os
import pprint
import numpy as np
import matplotlib.pyplot as plt

if __name__ == '__main__':
    # TODO; this is input arg
    csvfile = "/home/david/Dropbox/AA-work/bench-run4/bench-results01-4th-bench.csv"

    machPh = ['Phys-C7-QK5200',
              'Dock-C7-QK5200',
              'Dock-U16-QK5200',
              'UDock-C7-QK5200',
              'UDock-U16-QK5200'
              ]
    machVM = ['VM-U16-TK40',
              'Dock-C7-TK40',
              'Dock-U16-TK40',
              'UDock-C7-TK40',
              'UDock-U16-TK40'
              ]
    cases = ['RNA-polymerase-II', 'PRE5-PUP2-complex']
    angles = ['5.0', '10.0']
    voxspac = ['1', '2']
