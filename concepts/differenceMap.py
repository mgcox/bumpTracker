# http://docs.opencv.org/3.2.0/d4/d73/tutorial_py_contours_begin.html

import numpy as np
import cv2
import sys 
from datetime import datetime

startTime = datetime.now()
# Read the image
im = cv2.imread(sys.argv[1])
# Create a b&w image
imgray = cv2.cvtColor(im,cv2.COLOR_BGR2GRAY)
# Threshold the image so we can have a simple binarized image.
ret,thresh = cv2.threshold(imgray,127,255,0)
# Find the contours using openCV
im2, contours, hierarchy = cv2.findContours(thresh,cv2.RETR_TREE,cv2.CHAIN_APPROX_SIMPLE)
# Draw the contours for visual feedback
contours = sorted(contours, key = cv2.contourArea, reverse = True)[:10]
# print(list(contours[0]))

[vx,vy,x,y] = cv2.fitLine((contours[0]), cv2.DIST_L2,0,0.01,0.01)
# print('Center x: {0}'.format(x + (vx/2)))
center = (x + (vx/2))
contours[0] = list(filter(lambda el: el[0][0] > center, contours[0]))
# contours[0] = [el if el[0][0] > center for el in contours[0]]
# print(contours[0])
c = cv2.drawContours(im, contours[0], -1, (0,255,0), 3)

cv2.imwrite(sys.argv[2], im)
print('Script took a total time of {0}'.format(datetime.now() - startTime))
