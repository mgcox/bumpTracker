import numpy as np
import cv2
import sys 


im = cv2.imread(sys.argv[1])
imgray = cv2.cvtColor(im,cv2.COLOR_BGR2GRAY)
ret,thresh = cv2.threshold(imgray,127,255,0)
im2, contours, hierarchy = cv2.findContours(thresh,cv2.RETR_TREE,cv2.CHAIN_APPROX_SIMPLE)

c = cv2.drawContours(im, contours, -1, (0,255,0), 3)
cv2.imwrite(sys.argv[2], c)

