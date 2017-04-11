////
////  OpenCVWrapper.m
////  BumpTracker
////
////  Created by Garrett Cox on 4/6/17.
////  Copyright © 2017 GNiOS Applications. All rights reserved.
////
//#import <opencv2/opencv.hpp>
//#import "OpenCVWrapper.h"
//
//
//
//
//
//@implementation OpenCVWrapper
//
//using namespace std;
//
//using namespace cv;
//
//- (void) isThisWorking {
//    cout << "Hey" << endl;
//}
//
//- (void) processPhoto {
//    VideoCapture cap(CV_CAP_ANY);
//    cap.set(CV_CAP_PROP_FRAME_WIDTH, 320);
//    cap.set(CV_CAP_PROP_FRAME_HEIGHT, 240);
//    if (!cap.isOpened())
//        exit;
//        //return -1;
//    
//    Mat img;
//    HOGDescriptor hog;
//    hog.setSVMDetector(HOGDescriptor::getDefaultPeopleDetector());
//    
////    namedWindow("video capture", CV_WINDOW_AUTOSIZE);
////    while (true)
////    {
////        cap >> img;
////        if (!img.data)
////            continue;
////        
////        vector<cv::Rect> found, found_filtered;
////        hog.detectMultiScale(img, found, 0, cv::Size(8,8), cv::Size(32,32), 1.05, 2);
////        
////        size_t i, j;
////        for (i=0; i<found.size(); i++)
////        {
////            cv::Rect r = found[i];
////            for (j=0; j<found.size(); j++)
////                if (j!=i && (r & found[j])==r)
////                    break;
////            if (j==found.size())
////                found_filtered.push_back(r);
////        }
////        for (i=0; i<found_filtered.size(); i++)
////        {
////            cv::Rect r = found_filtered[i];
////            r.x += cvRound(r.width*0.1);
////            r.width = cvRound(r.width*0.8);
////            r.y += cvRound(r.height*0.06);
////            r.height = cvRound(r.height*0.9);
////            rectangle(img, r.tl(), r.br(), cv::Scalar(0,255,0), 2);
////        }
////        imshow("video capture", img);
////        if (waitKey(20) >= 0)
////            break;
////    }
//    //return 0;
//}
//
//@end
