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
contours = sorted(contours, key = cv2.contourArea, reverse = True)[:10]
# print(list(contours[0]))
# c = cv2.drawContours(im, contours, -1, (0,255,0), 3)
rows,cols = im.shape[:2]
[vx,vy,x,y] = cv2.fitLine((contours[0]), cv2.DIST_L2,0,0.01,0.01)
print([vx,vy,x,y])
lefty = int((-x*vy/vx) + y)
righty = int(((cols-x)*vy/vx)+y)
im = cv2.line(im,(cols-1,righty),(0,lefty),(0,255,0),1)

# imageCenter = int(cols / 2)
# bufferWidth = int(cols/20) # Buffer of "OK" image section (middle tenth of image)
# figureCenter = int(lefty) + int((righty-lefty)/2)
# if(figureCenter < imageCenter - bufferWidth:
#   print("Move right!")
# elif figureCenter > imageCenter + bufferWidth: 
#   print("Move left!")

# Print the diagnostic file for output
cv2.imwrite(sys.argv[2], im)

