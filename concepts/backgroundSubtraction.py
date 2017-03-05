# http://docs.opencv.org/3.2.0/d4/d73/tutorial_py_contours_begin.html

import numpy as np
import cv2
import sys 

# Read the background image
imB = cv2.imread(sys.argv[1])
# Read the foreground image
imF = cv2.imread(sys.argv[2])

diff = cv2.absdiff(imB, imF)
blur = cv2.GaussianBlur(diff,(35,35),0)
ret3,th3 = cv2.threshold(blur,blur.mean(),255,cv2.THRESH_BINARY)
cv2.imwrite(sys.argv[3], th3)
