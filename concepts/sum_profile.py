import numpy as np
from scipy import ndimage, misc, stats
from PIL import Image
import sys
import matplotlib.pyplot as plt
from skimage.filters.rank import median
from skimage.morphology import disk
from skimage import img_as_float
from scipy import ndimage

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


if __name__ == "__main__":
    input_path = sys.argv[1]
    output_path = sys.argv[2]

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
    img = ndimage.imread(input_path, flatten=True)
    # img = median(img, disk((60)))
    img = ndimage.gaussian_filter(img, sigma=3)

    # Get the profile for each axis.
    vProfile = sumProfile(img, 0) # Horizontal profile
    hProfile = sumProfile(img, 1) # Vertical profile

    # Horizontal plot
    plt.figure(0)
    plt.plot(hProfile, label='original')
    plt.title('Horizontal Profile')
    # Save the plot if the user gave a filename for it.
    if(plotPath):
        plt.savefig('images/results/sumProfile/H' + plotPath)

    # Vertical plot
    plt.figure(1)
    plt.plot(vProfile, label='original')
    plt.title('Vertical Profile')
    # Save the plot if the user gave a filename for it
    if(plotPath):
        plt.savefig('images/results/sumProfile/V' + sys.argv[3])
    plt.show()
