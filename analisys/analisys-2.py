#########################################################################
# Developed in the framework of INDIGO project,
#
# Author: Mario David <mariojmdavid@gmail.com>
#########################################################################

import os
import pprint
import numpy as np

if __name__ == '__main__':
    # TODO; this is input arg
    root_dir = "/home/david/Dropbox/AA-work/bench-gpu-results"

    machines = ['Phys-C7-QK5200',
                'VM-U16-TK40',
                'Dock-C7-QK5200',
                'Dock-C7-TK40',
                'Dock-U16-QK5200',
                'Dock-U16-TK40',
                'UDock-C7-QK5200',
                'UDock-U16-QK5200',
                'UDock-C7-TK40',
                'UDock-U16-TK40'
                ]
    cases = ['RNA-polymerase-II', 'PRE5-PUP2-complex']
    angles = ['5.0', '10.0']
    voxspac = ['1', '2']
    types = ['GPU']
    lrunsG = ['1', '2', '3', '4', '5']
    ljsres = []
    laggrRes = []

    i = 0 # index of machine type matches the index of total number of cores
    for mach in machines:
        initName = 'time-'
        for cs in cases:
            for ang in angles:
                for vs in voxspac:
                    aggrRes = {'machine': mach, 'case': cs, 'angle': ang,
                               'voxspac': vs,
                               'GPU': {'mean': None, 'stdev': None}}
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
                            rtime = float(s)
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

    print '--------------------------------------'
    print 'Case\tMachine\tAngle\tVoxSpac\tTimeGPU (sec)\tSTDev (sec)'
    for a in laggrRes:
        print '%s\t%s\t%s\t%s\t%5.1f\t%5.1f' % \
            (a['case'], a['machine'], a['angle'], a['voxspac'], a['GPU']['mean'], a['GPU']['stdev'])

    print '--------------------------------------'
    print '--------------------------------------'
    cases = ['GroEL-GroES', 'RsgA-ribosome']
    lrunsG = ['1', '2', '3', '4', '5']
    ljsres = []
    laggrRes = []
    i = 0  # index of machine type matches the index of total number of cores
    for mach in machines:
        initName = 'time-'
        for cs in cases:
            aggrRes = {'machine': mach, 'case': cs, 'GPU': {'mean': None, 'stdev': None}}
            laggrRes.append(aggrRes)
            jsres = {'machine': mach, 'case': cs, 'type': 'GPU', 'rtime': []}
            for n in lrunsG:
                tr_file = root_dir + os.sep + mach + os.sep + initName + cs + os.sep + 'tr_ang-4.71' + \
                          '-type-GPU' + '-n-' + n + '.txt'
                try:
                    f = open(tr_file)
                    # print '-> File: %s' % tr_file
                    s = f.readline()
                    rtime = float(s)
                    jsres['rtime'].append(rtime)
                except IOError:
                    print 'Cannot open', tr_file
            ljsres.append(jsres)
        i += 1
    
    for jsres in ljsres:
        jsres['rtime'] = np.array(jsres['rtime'])
        jsres['mean'] = np.mean(jsres['rtime'])
        jsres['stdev'] = np.std(jsres['rtime'])
        print jsres['case'], jsres['machine'], jsres['type']
    
    for j in ljsres:
        for a in laggrRes:
            if j['case'] == a['case'] and j['machine'] == a['machine']:
                if j['type'] == 'GPU':
                    a['GPU']['mean'] = j['mean']
                    a['GPU']['stdev'] = j['stdev']
    
    print '--------------------------------------'
    print 'Case\tMachine\tTimeGPU (sec)\tSTDev (sec)'
    for a in laggrRes:
        print '%s\t%s\t%5.1f\t%5.1f' % \
              (a['case'], a['machine'], a['GPU']['mean'], a['GPU']['stdev'])


