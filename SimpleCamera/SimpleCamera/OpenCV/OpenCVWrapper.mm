//
//  OpenCVWrapper.mm
//  SimpleCamera
//
//  Created by Biro, Zsolt on 12/02/2018.
//  Copyright © 2018 Biro, Zsolt. All rights reserved.
//

#include <opencv2/opencv.hpp>
#import "OpenCVWrapper.h"
#include <iostream>
#include <cassert>
#include <cmath>
#include <fstream>

using namespace std;
using namespace cv;

// This video stablisation smooths the global trajectory using a sliding average window

const int SMOOTHING_RADIUS = 30; // In frames. The larger the more stable the video, but less reactive to sudden panning
const int HORIZONTAL_BORDER_CROP = 20; // In pixels. Crops the border to reduce the black borders from stabilisation being too noticeable.
// 1. Get previous to current frame transformation (dx, dy, da) for all frames
// 2. Accumulate the transformations to get the image trajectory
// 3. Smooth out the trajectory using an averaging window
// 4. Generate new set of previous to current transform, such that the trajectory ends up being the same as the smoothed trajectory
// 5. Apply the new transformation to the video

struct TransformParam {
    TransformParam() {}
    TransformParam(double _dx, double _dy, double _da) {
        dx = _dx;
        dy = _dy;
        da = _da;
    }
    double dx, dy, da;
};

struct Trajectory {
    Trajectory() {}
    Trajectory(double _x, double _y, double _a) {
        x = _x;
        y = _y;
        a = _a;
    }
    double x, y, a;
};

@implementation OpenCVWrapper
+ (void)stabilizeVideoAtUrl:(NSURL*)inputUrl outputUrl: (NSURL*)outputUrl {
    VideoCapture cap(inputUrl.path.UTF8String);
    if(!cap.isOpened())  // check if we succeeded
        cout << "Failed open";
    
    Mat currentFrame, currentGrey;
    Mat firstFrame, firstGrey;
    vector <Point2f> firstCorners, currentCorner;
    vector <Point2f> goodNew, goodOld;
    vector <uchar> status;
    vector <float> error;
    
    // Step 1 - Get previous to current frame transformation (dx, dy, da) for all frames
    vector <TransformParam> prev_to_cur_transform; // previous to current
    
    int frames=1;
    Mat last_T;
    
    // Take first frame and find corners in it
    cap >> firstFrame;
    cvtColor(firstFrame, firstGrey, COLOR_BGR2GRAY);
    
    
    while(true) {
        cap >> currentFrame;
        
        if(currentFrame.data == NULL) {
            break;
        }
        bilateralFilter( currentFrame, currentGrey, 9, 50, 50 );
        bilateralFilter( firstFrame, firstGrey, 9, 50, 50 );
        
        cvtColor(currentFrame, currentGrey, COLOR_BGR2GRAY);
        
        // vector from prev to cur
        goodFeaturesToTrack(firstFrame, firstCorners, 100, 0.3, 7);
        calcOpticalFlowPyrLK(firstGrey, currentGrey, firstCorners, currentCorner, status, error);
        
        // weed out bad matches
        for(size_t i=0; i < status.size(); i++) {
            if(status[i]) {
                goodNew.push_back(currentCorner[i]);
                goodOld.push_back(firstCorners[i]);
            }
        }
        
        // translation + rotation only
        Mat T = estimateRigidTransform(goodOld, goodNew, false);
        
        // in rare cases no transform is found. We'll just use the last known good transform.
        if(T.data == NULL) {
            last_T.copyTo(T);
        }
        
        T.copyTo(last_T);
        
        // decompose T
        double dx = T.at<double>(0,2);
        double dy = T.at<double>(1,2);
        double da = atan2(T.at<double>(1,0), T.at<double>(0,0));
        
        prev_to_cur_transform.push_back(TransformParam(dx, dy, da));
        
        currentFrame.copyTo(firstFrame);
        currentGrey.copyTo(firstGrey);
        
        frames++;
    }
    
    currentGrey.release();
    firstGrey.release();
    
    // Step 2 - Accumulate the transformations to get the image trajectory
    
    // Accumulated frame to frame transform
    double a = 0;
    double x = 0;
    double y = 0;
    
    vector <Trajectory> trajectory; // trajectory at all frames
    
    for(int i=0; i < prev_to_cur_transform.size(); i++) {
        x += prev_to_cur_transform[i].dx;
        y += prev_to_cur_transform[i].dy;
        a += prev_to_cur_transform[i].da;
        
        trajectory.push_back(Trajectory(x,y,a));
    }
    
    // Step 3 - Smooth out the trajectory using an averaging window
    vector <Trajectory> smoothed_trajectory; // trajectory at all frames
    
    for(int i=0; i < trajectory.size(); i++) {
        double sum_x = 0;
        double sum_y = 0;
        double sum_a = 0;
        int count = 0;
        
        for(int j=-SMOOTHING_RADIUS; j <= SMOOTHING_RADIUS; j++) {
            if(i+j >= 0 && i+j < trajectory.size()) {
                sum_x += trajectory[i+j].x;
                sum_y += trajectory[i+j].y;
                sum_a += trajectory[i+j].a;
                
                count++;
            }
        }
        
        double avg_a = sum_a / count;
        double avg_x = sum_x / count;
        double avg_y = sum_y / count;
        
        smoothed_trajectory.push_back(Trajectory(avg_x, avg_y, avg_a));
    }
    // Step 4 - Generate new set of previous to current transform, such that the trajectory ends up being the same as the smoothed trajectory
    vector <TransformParam> new_prev_to_cur_transform;
    
    // Accumulated frame to frame transform
    a = 0;
    x = 0;
    y = 0;
    
    for(size_t i=0; i < prev_to_cur_transform.size(); i++) {
        x += prev_to_cur_transform[i].dx;
        y += prev_to_cur_transform[i].dy;
        a += prev_to_cur_transform[i].da;
        
        // target - current
        double diff_x = smoothed_trajectory[i].x - x;
        double diff_y = smoothed_trajectory[i].y - y;
        double diff_a = smoothed_trajectory[i].a - a;
        
        double dx = prev_to_cur_transform[i].dx + diff_x;
        double dy = prev_to_cur_transform[i].dy + diff_y;
        double da = prev_to_cur_transform[i].da + diff_a;
        
        new_prev_to_cur_transform.push_back(TransformParam(dx, dy, da));
    }
    
    // Step 5 - Apply the new transformation to the video
    cap.set(CV_CAP_PROP_POS_FRAMES, 0);
    
    double width = 960;
    double height = 540;
    Mat T(2,3,CV_64F);
    
    int vert_border = HORIZONTAL_BORDER_CROP * firstFrame.rows / firstFrame.cols;
    int ex = static_cast<int>(cap.get(CV_CAP_PROP_FOURCC));     // Get Codec Type- Int form
    VideoWriter writer(outputUrl.path.UTF8String, ex, 18, cv::Size(height,width), true);
    
    if (!writer.isOpened()) {
        cout << "Could not open file for writing";
    }
    
    int k=0;
    cap.release();
    
    VideoCapture cap2(inputUrl.path.UTF8String);
    assert(cap2.isOpened());
    
    while(k < frames-1) { // don't process the very last frame, no valid transform
        cap2 >> currentFrame;
        if(currentFrame.data == NULL) {
            break;
        }
        
        T.at<double>(0,0) = cos(new_prev_to_cur_transform[k].da);
        T.at<double>(0,1) = -sin(new_prev_to_cur_transform[k].da);
        T.at<double>(1,0) = sin(new_prev_to_cur_transform[k].da);
        T.at<double>(1,1) = cos(new_prev_to_cur_transform[k].da);
        
        T.at<double>(0,2) = new_prev_to_cur_transform[k].dx;
        T.at<double>(1,2) = new_prev_to_cur_transform[k].dy;
        
        Mat cur2;
        warpAffine(currentFrame, cur2, T, currentFrame.size(),INTER_NEAREST|WARP_INVERSE_MAP, BORDER_CONSTANT);
        
        cur2 = cur2(Range(vert_border, cur2.rows-vert_border), Range(HORIZONTAL_BORDER_CROP, cur2.cols - HORIZONTAL_BORDER_CROP));
        
        transpose(cur2, cur2);
        flip(cur2, cur2, 1);
        resize(cur2, cur2, currentFrame.size());
        double diffx = width * 0.2;
        double diffy = height * 0.2;
        
        cv::Rect myROI((diffx/2),(diffy/2),width-(diffx),height-(diffy));
        Mat fin = cur2(myROI);
        resize(fin, fin, cv::Size(height,width));
        writer.write(fin);
        
        k++;
    }
    currentFrame.release();
    cap2.release();
    writer.release();
    cout << "Video Stabilization Complete";
    //return outputUrl;
}
@end
