#########################################################################
# Developed in the framework of INDIGO project,
#
# Author: Mario David <mariojmdavid@gmail.com>
#########################################################################

import os
import h5py
import math
import numpy as np
import numpy.ma as ma
import matplotlib.pyplot as plt


def std_ratio(m1, m2, s1, s2):
    """
    :param m1: mean numerator
    :param m2: mean denominator
    :param s1: stdev numerator
    :param s2: stdev denominator
    :return: stdev of the ratio
    """
    sq_ratio = (s1*s1)/(m1*m1) + (s2*s2)/(m2*m2)
    sr = m1/m2 * math.sqrt(sq_ratio)
    return sr


def is_outlier(points, thresh=3.5):
    """
    Returns a boolean array with True if points are outliers and False
    otherwise.
    Parameters:
    -----------
        points : An numobservations by numdimensions array of observations
        thresh : The modified z-score to use as a threshold. Observations with
            a modified z-score (based on the median absolute deviation) greater
            than this value will be classified as outliers.
    Returns:
    --------
        mask : A numobservations-length boolean array.
    References:
    ----------
        Boris Iglewicz and David Hoaglin (1993), "Volume 16: How to Detect and
        Handle Outliers", The ASQC Basic References in Quality Control:
        Statistical Techniques, Edward F. Mykytka, Ph.D., Editor.
    """
    if len(points.shape) == 1:
        points = points[:, None]
    median = np.median(points, axis=0)
    diff = np.sum((points - median)**2, axis=-1)
    diff = np.sqrt(diff)
    med_abs_deviation = np.median(diff)
    modified_z_score = 0.6745 * diff / med_abs_deviation

    return modified_z_score > thresh


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

    machshort = {'QK5200': ['Phys-C7', 'Dock-C7', 'Dock-U16', 'UDock-C7', 'UDock-U16'],
                 'TK40': ['VM-U16', 'Dock-C7', 'Dock-U16', 'UDock-C7', 'UDock-U16']}

    lrunsG = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10']
    initName = 'time-'

    nbars = 5
    index = np.arange(nbars)
    bar_width = 0.6
    error_config = {'ecolor': '#000000', 'lw': 2, 'capsize': 5, 'capthick': 2}

    with h5py.File(fout, 'w') as f:
        for case in cases['disvis']:
            for angle in angles:
                for vs in voxspac:
                    for nv in nvidia:
                        list_mean = []
                        list_stdev = []
                        for mach in machs[nv]:
                            grp_name = 'disvis' + '/' +\
                                       case + '-' + angle + '-' + vs + '/' +\
                                       nv + '/' + mach
                            grp1 = f.create_group(grp_name)
                            npres = np.arange(10, dtype=float)
                            for n in lrunsG:
                                tr_file = root_dir + os.sep + mach + os.sep + \
                                          initName + case + os.sep + 'tr_ang-' + angle + \
                                          '-vs-' + vs + '-type-GPU' + '-n-' + n + '.txt'
                                try:
                                    fraw = open(tr_file)
                                    npres[int(n)-1] = float(fraw.readline())
                                except IOError:
                                    print 'Cannot open', tr_file

                            npres.sort()
                            outl_mask = is_outlier(npres, 3.5)
                            npres_ma = ma.masked_array(npres, mask=outl_mask)
                            res = grp1.create_dataset("runtime", data=npres)
                            res.attrs['mean'] = np.mean(npres)
                            res.attrs['stdev'] = np.std(npres)
                            res.attrs['mean_mask'] = np.mean(npres_ma)
                            res.attrs['stdev_mask'] = np.std(npres_ma)
                            res.attrs['n_masked'] = np.sum(outl_mask)
                            list_mean.append(np.mean(npres_ma))
                            list_stdev.append(np.std(npres_ma))

                        ymin = np.amin(list_mean) - 1.5*np.amax(list_stdev)
                        ymax = np.amax(list_mean) + 1.5*np.amax(list_stdev)
                        fig = plt.figure()
                        plt.bar(index, list_mean, bar_width,
                                color=['#8DADC0', '#ECBDA3', '#ECBDA3', '#ECBDA3', '#ECBDA3'],
                                yerr=list_stdev,
                                error_kw=error_config,
                                label='Time (s)')
                
                        plt.xlabel('Machine')
                        plt.ylabel('Run time (sec)')
                        plt.ylim((ymin, ymax))
                        plt.title('Disvis: case = ' + case + '\n Angle = ' + angle +
                                  ' Voxelspacing = ' + vs + ' GPU = ' + nv)
                        plt.xticks(index, machshort[nv])
                        plt.grid(b=None, which='major', axis='y')
                        plt.legend()
                        plt.savefig(root_dir + '/plots/' + 'disvis ' + case + '-' + angle + '-' + vs + '-' + nv + '.png')
                        plt.close(fig)

                        # ratio of run time of machine with the runtime of the baremetal (Phys or VM)
                        r_baremetal = list_mean / list_mean[0]
                        stdev_ratio = []
                        for i in range(len(list_mean)):
                            stdr = std_ratio(list_mean[i], list_mean[0], list_stdev[i], list_stdev[0])
                            stdev_ratio.append(stdr)
                        ymin = np.amin(r_baremetal) - 1.5 * np.amax(stdev_ratio)
                        ymax = np.amax(r_baremetal) + 1.5 * np.amax(stdev_ratio)
                        fig = plt.figure()
                        plt.bar(index, r_baremetal, bar_width,
                                color=['#8DADC0', '#ECBDA3', '#ECBDA3', '#ECBDA3', '#ECBDA3'],
                                yerr=stdev_ratio,
                                error_kw=error_config,
                                label='Ratio')

                        plt.xlabel('Machine')
                        plt.ylabel('Ratio Run time')
                        plt.ylim((ymin, ymax))
                        plt.title('Disvis: case = ' + case + '\n Angle = ' + angle +
                                  ' Voxelspacing = ' + vs + ' GPU = ' + nv)
                        plt.xticks(index, machshort[nv])
                        plt.grid(b=None, which='major', axis='y')
                        plt.legend()
                        plt.savefig(root_dir + '/plots/' + 'ratio-disvis ' +
                                    case + '-' + angle + '-' + vs + '-' + nv + '.png')
                        plt.close(fig)

        for case in cases['powerfit']:
            for nv in nvidia:
                list_mean = []
                list_stdev = []
                for mach in machs[nv]:
                    grp_name = 'powerfit' + '/' + case + '/' + nv + '/' + mach
                    grp1 = f.create_group(grp_name)
                    npres = np.arange(10, dtype=float)
                    for n in lrunsG:
                        tr_file = root_dir + os.sep + mach + os.sep + initName + case + os.sep + 'tr_ang-4.71' + \
                                  '-type-GPU' + '-n-' + n + '.txt'
                        try:
                            fraw = open(tr_file)
                            npres[int(n) - 1] = float(fraw.readline())
                        except IOError:
                            print 'Cannot open', tr_file

                    npres.sort()
                    outl_mask = is_outlier(npres, 3.5)
                    npres_ma = ma.masked_array(npres, mask=outl_mask)
                    res = grp1.create_dataset("runtime", data=npres)
                    res.attrs['mean'] = np.mean(npres)
                    res.attrs['stdev'] = np.std(npres)
                    res.attrs['mean_mask'] = np.mean(npres_ma)
                    res.attrs['stdev_mask'] = np.std(npres_ma)
                    res.attrs['n_masked'] = np.sum(outl_mask)
                    list_mean.append(np.mean(npres_ma))
                    list_stdev.append(np.std(npres_ma))

                ymin = np.amin(list_mean) - 1.5*np.amax(list_stdev)
                ymax = np.amax(list_mean) + 1.5*np.amax(list_stdev)
                fig = plt.figure()
                plt.bar(index, list_mean, bar_width,
                        color=['#8DADC0', '#ECBDA3', '#ECBDA3', '#ECBDA3', '#ECBDA3'],
                        yerr=list_stdev,
                        error_kw=error_config,
                        label='Time (s)')
                
                plt.xlabel('Machine')
                plt.ylabel('Run time (sec)')
                plt.ylim((ymin, ymax))
                plt.title('Powerfit: Case = ' + case + '\n GPU = ' + nv)
                plt.xticks(index, machshort[nv])
                plt.grid(b=None, which='major', axis='y')
                plt.legend()
                plt.savefig(root_dir + '/plots/' + 'powerfit ' + case + '-' + nv + '.png')
                plt.close(fig)

                # ratio of run time of machine with the runtime of the baremetal (Phys or VM)
                r_baremetal = list_mean / list_mean[0]
                stdev_ratio = []
                for i in range(len(list_mean)):
                    stdr = std_ratio(list_mean[i], list_mean[0], list_stdev[i], list_stdev[0])
                    stdev_ratio.append(stdr)
                ymin = np.amin(r_baremetal) - 1.5 * np.amax(stdev_ratio)
                ymax = np.amax(r_baremetal) + 1.5 * np.amax(stdev_ratio)
                fig = plt.figure()
                plt.bar(index, r_baremetal, bar_width,
                        color=['#8DADC0', '#ECBDA3', '#ECBDA3', '#ECBDA3', '#ECBDA3'],
                        yerr=stdev_ratio,
                        error_kw=error_config,
                        label='Ratio')

                plt.xlabel('Machine')
                plt.ylabel('Ratio Run time')
                plt.ylim((ymin, ymax))
                plt.title('Powerfit: Case = ' + case + '\n GPU = ' + nv)
                plt.xticks(index, machshort[nv])
                plt.grid(b=None, which='major', axis='y')
                plt.legend()
                plt.savefig(root_dir + '/plots/' + 'ratio-powerfit ' + case + '-' + nv + '.png')
                plt.close(fig)
