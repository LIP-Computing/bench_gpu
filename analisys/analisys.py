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

    i = 0 # index of machine type matches the index of total number of cores
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
                            rtime = float(s.split('=')[1].split()[0])
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
                                rtime = float(s.split('=')[1].split()[0])
                                jsres['rtime'].append(rtime)
                            except IOError:
                                print 'Cannot open', tr_file
                        ljsres.append(jsres)
        i += 1

    #pprint.pprint(ljsres)
    for jsres in ljsres:
        jsres['rtime'] = np.array(jsres['rtime'])
        jsres['mean'] = np.mean(jsres['rtime'])
        jsres['stdev'] = np.std(jsres['rtime'])
        print jsres['case'], jsres['machine'], jsres['angle'], jsres['voxspac'], jsres['type']
    #pprint.pprint(ljsres)
    print len(ljsres)


#    laggRes = []
#    for jsres in ljsres:
#        aggRes = {'machine': jsres['machine'], 'case': jsres['case'],
#                  'angle': jsres['angle'], 'voxspac': jsres['voxspac']}





    mPRE_MP01_a5_vs1 = np.empty([14,], dtype=float)
    print '------ PRE_MP01_a5_vs1'
    print len(mPRE_MP01_a5_vs1)
    for jsres in ljsres:
        if jsres['case'] == 'PRE5-PUP2-complex' and \
           jsres['machine'] == 'M-Phys-01' and \
           jsres['angle'] == '5.0' and \
           jsres['voxspac'] == '1':
            if jsres['type'] == 'GPU':
                mPRE_MP01_a5_vs1[13] = jsres['mean']
            if jsres['type'] == 'CPU':
                if jsres['ncores'] == 1:
                    mPRE_MP01_a5_vs1[0] = jsres['mean']
                else:
                    mPRE_MP01_a5_vs1[jsres['ncores']/2] = jsres['mean']

    print mPRE_MP01_a5_vs1

    mPRE_MK01_a5_vs1 = np.empty([14,], dtype=float)
    print '------ PRE_MK01_a5_vs1'
    print len(mPRE_MK01_a5_vs1)
    for jsres in ljsres:
        if jsres['case'] == 'PRE5-PUP2-complex' and \
           jsres['machine'] == 'M-KVM-01' and \
           jsres['angle'] == '5.0' and \
           jsres['voxspac'] == '1':
            if jsres['type'] == 'GPU':
                mPRE_MK01_a5_vs1[13] = jsres['mean']
            if jsres['type'] == 'CPU':
                if jsres['ncores'] == 1:
                    mPRE_MK01_a5_vs1[0] = jsres['mean']
                else:
                    mPRE_MK01_a5_vs1[jsres['ncores']/2] = jsres['mean']

    print mPRE_MK01_a5_vs1

    mPRE_MP02_a5_vs1 = np.empty([6,], dtype=float)
    print '------ PRE_MP02_a5_vs1'
    print len(mPRE_MP02_a5_vs1)
    for jsres in ljsres:
        if jsres['case'] == 'PRE5-PUP2-complex' and \
           jsres['machine'] == 'M-Phys-02' and \
           jsres['angle'] == '5.0' and \
           jsres['voxspac'] == '1':
            if jsres['type'] == 'GPU':
                mPRE_MP02_a5_vs1[5] = jsres['mean']
            if jsres['type'] == 'CPU':
                if jsres['ncores'] == 1:
                    mPRE_MP02_a5_vs1[0] = jsres['mean']
                else:
                    mPRE_MP02_a5_vs1[jsres['ncores']/2] = jsres['mean']

    print mPRE_MP02_a5_vs1





    x1 = np.array ([0, 1, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24])
    x2 = np.array ([0, 1, 2, 4, 6, 8])

    plt.plot(x1, mPRE_MP01_a5_vs1, 'ro')
    plt.plot(x2, mPRE_MP02_a5_vs1, 'bo')
    plt.show
