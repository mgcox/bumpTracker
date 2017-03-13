#include "opencv2/opencv.hpp" 
 
using namespace cv;
using namespace std;
 
int main( int argc, char** argv)
{
    // Read source image.
    Mat im_src = imread("week1.jpg");
    // Four corners of the book in source image
    vector<Point2f> pts_src;
    pts_src.push_back(Point2f(294, 168));
    pts_src.push_back(Point2f(272, 285));
    pts_src.push_back(Point2f(284, 450));
    pts_src.push_back(Point2f(238, 81));
 
 
    // Read destination image.
    Mat im_dst = imread("week6.jpg");
    // Four corners of the book in destination image.
    vector<Point2f> pts_dst;
    pts_dst.push_back(Point2f(320, 193));
    pts_dst.push_back(Point2f(284, 322));
    pts_dst.push_back(Point2f(288, 507));
    pts_dst.push_back(Point2f(258, 81));
 
    // Calculate Homography
    Mat h = findHomography(pts_src, pts_dst);
 
    // Output image
    Mat im_out;
    // Warp source image to destination based on homography
    warpPerspective(im_src, im_out, h, im_dst.size());
 
    // Display images
    imshow("Source Image", im_src);
    imshow("Destination Image", im_dst);
    imshow("Warped Source Image", im_out);
 
    waitKey(0);
}
