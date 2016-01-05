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
    root_dir = "/home/david/AA-work/bench-results"

    machines = ['M-KVM-01', 'M-Phys-01', 'M-Phys-02', 'M-Phys-04', 'M-Dock-02']
    tot_cpus = [24, 24, 8, 24, 8]
    cases = ['RNA-polymerase-II', 'PRE5-PUP2-complex']
    angles = ['5.0', '10.0']
    voxspac = ['1', '2']
    types = ['GPU', 'CPU']
    lrunsG = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10']
    lrunsC = ['1', '2', '3']
    ljsres = []
    laggrRes = []

    i = 0 # index of machine type matches the index of total number of cores
    for mach in machines:
        if mach == 'M-Dock-01' or mach == 'M-Dock-02':
            initName = 'time-docker-'
        else:
            initName = 'time-'
        lncores = [x for x in range(tot_cpus[i], 0, -2)]
        lncores.append(1)
        print lncores
        for cs in cases:
            for ang in angles:
                for vs in voxspac:
                    m = np.empty( [tot_cpus[i]/2+1,], dtype=float )
                    s = np.empty( [tot_cpus[i]/2+1,], dtype=float )
                    h = np.array([1])
                    t = np.array(range(2, tot_cpus[i]+1, 2))
                    n = np.concatenate([h, t])
                    aggrRes = {'machine': mach, 'case': cs, 'angle': ang,
                               'voxspac': vs,
                               'GPU': {'mean': None, 'stdev': None},
                               'CPU': {'mean': m, 'stdev': s, 'ncores': n}}
                    laggrRes.append(aggrRes)
                    jsres = {'machine': mach, 'case': cs, 'angle': ang,
                             'voxspac': vs, 'type': 'GPU', 'rtime': []}
                    for n in lrunsG:
                        tr_file = root_dir + os.sep + mach + os.sep + \
                            initName + cs + os.sep + 'tr_ang-' + ang + \
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
                                 'totCPU': tot_cpus[i],
                                 'ncores': ncores, 'rtime': []}
                        for n in lrunsC:
                            tr_file = root_dir + os.sep + mach + os.sep + \
                                initName + cs + os.sep + 'tr_ang-' + ang + \
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

    for jsres in ljsres:
        jsres['rtime'] = np.array(jsres['rtime'])
        jsres['mean'] = np.mean(jsres['rtime'])
        jsres['stdev'] = np.std(jsres['rtime'])
        print jsres['case'], jsres['machine'], jsres['angle'], jsres['voxspac'], jsres['type']

    for j in ljsres:
        for a in laggrRes:
            if j['case'] == a['case'] and j['machine'] == a['machine'] and \
               j['angle'] == a['angle'] and j['voxspac'] == a['voxspac']:
                if j['type'] == 'GPU':
                    a['GPU']['mean'] = j['mean']
                    a['GPU']['stdev'] = j['stdev']
                if j['type'] == 'CPU':
                    if j['ncores'] == 1:
                        a['CPU']['mean'][0] = j['mean']
                        a['CPU']['stdev'][0] = j['stdev']
                    else:
                        a['CPU']['mean'][j['ncores']/2] = j['mean']
                        a['CPU']['stdev'][j['ncores']/2] = j['stdev']

    for a in laggrRes:
        if not np.isnan(a['CPU']['mean'][0]):
            print a

    print '--------------------------------------'
    print 'Case\tMachine\tAngle\tVoxSpac\tTimeGPU (sec)\tTimeCPU 1 core\tNCores Mintime\tTimeCPUmin'
    for a in laggrRes:
        if not np.isnan(a['CPU']['mean'][0]):
            #plt.plot(a['CPU']['ncores'], a['CPU']['mean'], 'ro')
            #plt.show
            print '%s\t%s\t%s\t%s\t%5.1f\t%5.1f\t%d\t%5.1f' % \
                (a['case'], a['machine'], a['angle'], a['voxspac'],
                 a['GPU']['mean'], a['CPU']['mean'][0], a['CPU']['ncores'][np.argmin(a['CPU']['mean'])],
                 np.min(a['CPU']['mean']))



    #plt.plot(x1, mPRE_MP01_a5_vs1, 'ro')
    #plt.plot(x2, mPRE_MP02_a5_vs1, 'bo')
    #plt.show
