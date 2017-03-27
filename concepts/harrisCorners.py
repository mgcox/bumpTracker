import cv2
import numpy as np
import sys

img = cv2.imread(sys.argv[1])
gray = cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)

gray = np.float32(gray)
dst = cv2.cornerHarris(gray,2,3,0.04)

#result is dilated for marking the corners, not important
dst = cv2.dilate(dst,None)
print(dst[0])

imCpy = img.copy()
imCpy[:] = (255, 255, 255)
# Threshold for an optimal value, it may vary depending on the image.
imCpy[dst>0.01*dst.max()]=[0,0,255]

maxVal = dst.max()
# l = list(filter(lambda el: el[0]>0.01*maxVal, dst))
# print(l)
cv2.imwrite(sys.argv[2], imCpy)