# http://docs.opencv.org/3.2.0/d4/d73/tutorial_py_contours_begin.html

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
c = cv2.drawContours(im, contours, -1, (0,255,0), 3)
# Print the diagnostic file for output
cv2.imwrite(sys.argv[2], c)

