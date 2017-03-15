'''
This was a test to inspect the moments of a given image from its contours.

This method was not selected because of the decentralizing of the image that using
the moments would cause.
'''


import numpy as np
import cv2
import sys 

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

M = cv2.moments(contours[0])
print(M)
cx = int(M['m10']/M['m00'])
cy = int(M['m01']/M['m00'])
print(cx)
print(cy)
im[cy][cx] = [0, 255, 0]
im[cy+1][cx] = [0, 255, 0]
im[cy][cx+1] = [0, 255, 0]
im[cy+1][cx+1] = [0, 255, 0]
print(im[cx][cy])


