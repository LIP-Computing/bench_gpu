#########################################################################
# Developed in the framework of INDIGO project,
#
# Author: Mario David <mariojmdavid@gmail.com>
#########################################################################

import os
import pprint
import numpy

if __name__ == '__main__':
    # TODO; this is input arg
    root_dir = "/home/david/Dropbox/AA-work/LIP-tech/bench-results"

    machines = ['M-KVM-01', 'M-Phys-01', 'M-Phys-02']
    tot_cpus = [24, 24, 8]
    cases = ['RNA-polymerase-II', 'PRE5-PUP2-complex']
    angles = ['5.0', '10.0']
    voxspac = ['1', '2']
    types = ['GPU', 'CPU']
    lrunsG = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10']
    lrunsC = ['1', '2']
    ljsres = []

    i = 0
    for mach in machines:
        lncores = [x for x in range(tot_cpus[i], 0, -2)]
        lncores.append(1)
        print lncores
        for cs in cases:
            for ang in angles:
                for vs in voxspac:
                    jsres = {'machine': mach, 'case': cs, 'angle': ang,
                             'voxspac': vs, 'type': 'GPU', 'rtime': []}
                    for n in lrunsG:
                        tr_file = root_dir + os.sep + mach + os.sep + \
                            'time-' + cs + os.sep + 'tr_ang-' + ang + \
                            '-vs-' + vs + '-type-GPU' + '-n-' + n + '.txt'
                        try:
                            f = open(tr_file)
                            #print '-> File: %s' % tr_file
                            s = f.readline()
                            rtime = s.split('=')[1].split()[0]
                            jsres['rtime'].append(rtime)
                        except IOError:
                            print 'Cannot open', tr_file
                    ljsres.append(jsres)
                    for ncores in lncores:
                        jsres = {'machine': mach, 'case': cs, 'angle': ang,
                                 'voxspac': vs, 'type': 'CPU',
                                 'ncores': ncores, 'rtime': []}
                        for n in lrunsC:
                            tr_file = root_dir + os.sep + mach + os.sep + \
                                'time-' + cs + os.sep + 'tr_ang-' + ang + \
                                '-vs-' + vs + '-type-CPU' + '-ncores-' + \
                                str(ncores) + '-n-' + n + '.txt'
                            try:
                                f = open(tr_file)
                                #print '-> File: %s' % tr_file
                                s = f.readline()
                                rtime = s.split('=')[1].split()[0]
                                jsres['rtime'].append(rtime)
                            except IOError:
                                print 'Cannot open', tr_file
                            ljsres.append(jsres)

        i += 1

    pprint.pprint(ljsres)