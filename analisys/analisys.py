#########################################################################
# Developed in the framework of INDIGO project,
#
# Author: Mario David <mariojmdavid@gmail.com>
#########################################################################

import os

if __name__ == '__main__':
    # TODO; this is input arg
    root_dir = "/home/david/Dropbox/AA-work/LIP-tech/bench-results"

    machines = ['M-KVM-01', 'M-Phys-01', 'M-Phys-02']
    tot_cpus = [24, 24, 8]
    cases = ['RNA-polymerase-II', 'PRE5-PUP2-complex']
    angles = ['5.0', '10.0']
    voxspac = ['1', '2']
    types = ['GPU', 'CPU']
    lruns = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10']

    for mach in machines:
        for cs in cases:
            for ang in angles:
                for vs in voxspac:
                    for n in lruns:
                        tr_file = root_dir + os.sep + mach + os.sep + \
                            'time-' + cs + os.sep + 'tr_ang-' + ang + \
                            '-vs-' + vs + '-type-GPU' + '-n-' + n + '.txt'
                        try:
                            f = open(tr_file)
                            print '-> File: %s' % tr_file
                            s = f.readline()
                            rtime = s.split('=')[1].split()[0]
                            print rtime
                        except IOError:
                            print 'Cannot open', tr_file

