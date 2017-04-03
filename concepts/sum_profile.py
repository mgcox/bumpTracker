import numpy as np
from scipy import ndimage, misc, stats
from PIL import Image
import sys
import matplotlib.pyplot as plt
from skimage.filters.rank import median
from skimage.morphology import disk
from skimage import img_as_float
from scipy import ndimage
from subprocess import call

HORIZONTAL = 0
VERTICAL = 1

def sumProfile(img, axis=0):
    img = toGray(img)
    return img.sum(axis=axis)

def toGray(img):
    if len(img.shape) == 2 or img.shape[2] == 1:
        #Already gray
        return img
    r, g, b = img[:,:,0], img[:,:,1], img[:,:,2]

    gray = 0.2989 * r + 0.5870 * g + 0.1140 * b
    return gray

'''Shifts profile over profile2 to find the minimum difference between them, returns the shift amount.'''
def getShift(profile, profile2):
    profile1length = profile.shape[0]
    profile1half = int(profile1length/2)
    profile2length = profile2.shape[0]
    # print('Profile 1 length: ', profile1length, ' profile 2 length: ', profile2length)
    minLength = min(profile1length, profile2length)
    # print('Min length: ', minLength)
    minSum = sum(np.abs(np.subtract(profile[:minLength], profile2[:minLength])))
    print('Initial sum: ', minSum)
    result = 0
    # From left to center
    for x in range(profile1half):
        shiftedProfile = np.lib.pad(profile[profile1half - x: profile1length], (0,profile1half - x), 'constant', constant_values=(0,0))
        diff =  sum(np.abs(np.subtract(shiftedProfile[:minLength], profile2[:minLength])))
        if(min(minSum, diff) == diff):
            print('Got a new sum: ', profile1half - x, ' with sum ', diff)
            result = profile1half - x
            minSum = diff

    # From center to right
    for x in range(profile1half):
        shiftedProfile = np.lib.pad(profile[0: profile1length - x], (x,0), 'constant', constant_values=(0,0))
        diff =  sum(np.abs(np.subtract(shiftedProfile[:minLength], profile2[:minLength])))
        print(x, '2 sum: ', diff)
        if(min(minSum, diff) == diff):
            print('2 Got a new sum: ', x, ' with sum ', diff)
            result = x
            minSum == diff
    # return sum(np.abs(np.subtract(profile, profile2)))
    return result


if __name__ == "__main__":
    inputPath1 = sys.argv[1]
    inputPath2 = sys.argv[2]

    # Only use argument 3 if it exists.
    try:
        plotPath = sys.argv[3]

        if(plotPath.split('.')[-1] != 'png'):
            raise ValueError('Output path for the plot must end with \".png\"')
    except ValueError:
        print('Something')
    except:
        pass


    # Transform the original image using a median filter of radius 22px.
    img = ndimage.imread(inputPath1, flatten=True)
    img2 = ndimage.imread(inputPath2, flatten=True)
    # img = median(img, disk((60)))
    img = ndimage.gaussian_filter(img, sigma=3)
    img2 = ndimage.gaussian_filter(img2, sigma=3)

    # Get the profile for each axis.
    vProfile = sumProfile(img, 0) # Horizontal profile
    hProfile = sumProfile(img, 1) # Vertical profile

    vProfile2 = sumProfile(img2, 0) # Horizontal profile
    hProfile2 = sumProfile(img2, 1) # Vertical profile

    # TODO: switch the axes and superimpose image behind it.
    
    # Horizontal plot 1
    plt.figure(0)
    plt.plot(hProfile, label='original 1')
    plt.plot(hProfile2, label='original 2')
    plt.legend()
    plt.plot(np.abs(np.subtract(hProfile, hProfile2)), label='difference')
    plt.title('Horizontal Profile')
    # Save the plot if the user gave a filename for it.
    try:
        plt.savefig('images/results/sumProfile/h.' + plotPath)
    except:
        pass

    # Vertical plot 1
    plt.figure(1)
    n = 4
    minLength = (min(vProfile.shape[0], vProfile2.shape[0]))

    getShiftResult = getShift(vProfile, vProfile2)
    print('Result is: ', getShiftResult)

    if(getShiftResult < 1):
        padded = np.lib.pad(vProfile[getShiftResult:minLength + getShiftResult], (0, -getShiftResult), 'constant', constant_values=(0,0))
        plt.plot(padded, label='Shifted 1')
    else:
        padded = np.lib.pad(vProfile[0:minLength - getShiftResult], (getShiftResult, 0), 'constant', constant_values=(0,0))
        plt.plot(padded, label='Shifted 1')
    plt.plot(vProfile[:minLength], label='original 1')
    plt.plot(vProfile2[:minLength], label='original 2')
    plt.legend()
    plt.title('Vertical Profile')
    try:
        plt.savefig('images/results/sumProfile/v2.' + plotPath)
    except:
        pass

    call('open ' + sys.argv[1], shell=True)
    call('open ' + sys.argv[2], shell=True)
    plt.show()
