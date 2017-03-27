import numpy as np
import cv2
import sys 
from datetime import datetime


def getRightContours(im):
    # Create a b&w imag
    imgray = cv2.cvtColor(im, cv2.COLOR_BGR2GRAY)
    # Threshold the image so we can have a simple binarized image.
    ret,thresh = cv2.threshold(imgray,127,255,0)
    # Find the contours using openCV
    im2, contours, hierarchy = cv2.findContours(thresh,cv2.RETR_TREE,cv2.CHAIN_APPROX_SIMPLE)
    # Draw the contours for visual feedback
    contours = sorted(contours, key = cv2.contourArea, reverse = True)[:10]

    [vx,vy,x,y] = cv2.fitLine((contours[0]), cv2.DIST_L2,0,0.01,0.01)
    # print('Center x: {0}'.format(x + (vx/2)))
    center = (x + (vx/2))
    # Remake the contours to be only the right side.
    contours[0] = list(filter(lambda el: el[0][0] > center, contours[0]))
    
    return contours

startTime = datetime.now()
# Read the image
im = cv2.imread(sys.argv[1])
im2 = cv2.imread(sys.argv[2])

contours1 = getRightContours(im)
contours2 = getRightContours(im2)

# Get the max Y value for each right contour
maxY1 = max(list(map(lambda el: el[0][1], contours1[0])))
maxY2 = max(list(map(lambda el: el[0][1], contours2[0])))

print(str(maxY1) + ' compared to ' + str(maxY2))

# This is the amount image 2 will need to be moved in the Y direction to be matched
yDiff = maxY1 - maxY2
print('Shift image two down by ' + str(yDiff) + ' pixels.')

# # print(contours[0])
# c = cv2.drawContours(im, contours1, -1, (0,255,0), 3)
# # c = cv2.drawContours(im, contours2, -1, (0,255,0), 3)

# cv2.imwrite(sys.argv[3], im)
print('Script took a total time of {0}'.format(datetime.now() - startTime))