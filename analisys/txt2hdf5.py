#########################################################################
# Developed in the framework of INDIGO project,
#
# Author: Mario David <mariojmdavid@gmail.com>
#########################################################################

import os
import h5py
import numpy as np

if __name__ == '__main__':

    root_dir = "/home/david/Dropbox/AA-work/bench-run4"
    fout = root_dir + "/bench.hdf"
    haddocks = ['disvis', 'powerfit']
    cases = {'disvis': ['RNA-polymerase-II', 'PRE5-PUP2-complex'],
             'powerfit': ['GroEL-GroES', 'RsgA-ribosome']}

    angles = ['5.0', '10.0']
    voxspac = ['1', '2']
    type = 'GPU'
    nvidia = ['QK5200', 'TK40']

    machs = {'QK5200': ['Phys-C7-QK5200', 'Dock-C7-QK5200', 'Dock-U16-QK5200',
                       'UDock-C7-QK5200', 'UDock-U16-QK5200'],
            'TK40': ['VM-U16-TK40', 'Dock-C7-TK40', 'Dock-U16-TK40',
                     'UDock-C7-TK40', 'UDock-U16-TK40']}

    lrunsG = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10']
    initName = 'time-'

    with h5py.File(fout, 'w') as f:
        for case in cases['disvis']:
            for angle in angles:
                for vs in voxspac:
                    for nv in nvidia:
                        for mach in machs[nv]:
                            grp_name = 'disvis' + '/' +\
                                       case + '-' + angle + '-' + vs + '/' +\
                                       nv + '/' + mach
                            grp1 = f.create_group(grp_name)
                            npres = np.arange(10)
                            for n in lrunsG:
                                tr_file = root_dir + os.sep + mach + os.sep + \
                                          initName + case + os.sep + 'tr_ang-' + angle + \
                                          '-vs-' + vs + '-type-GPU' + '-n-' + n + '.txt'
                                try:
                                    fraw = open(tr_file)
                                    npres[int(n)-1] = float(fraw.readline())
                                except IOError:
                                    print 'Cannot open', tr_file
                            res = grp1.create_dataset("runtime", data=npres)

        for case in cases['powerfit']:
            for nv in nvidia:
                for mach in machs[nv]:
                    grp_name = 'powerfit' + '/' + case + '/' + nv + '/' + mach
                    grp1 = f.create_group(grp_name)
                    npres = np.arange(10)
                    for n in lrunsG:
                        tr_file = root_dir + os.sep + mach + os.sep + initName + case + os.sep + 'tr_ang-4.71' + \
                                  '-type-GPU' + '-n-' + n + '.txt'
                        try:
                            fraw = open(tr_file)
                            npres[int(n) - 1] = float(fraw.readline())
                        except IOError:
                            print 'Cannot open', tr_file
                    res = grp1.create_dataset("runtime", data=npres)

