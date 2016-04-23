//
//  CMGViewController.h
//  CorePlot6
//
//  Created by Adithep Narula on 4/13/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMGOverlayView.h"
#import "PieChartV1.h"
#import "BarGraphV1.h"
#import <AVFoundation/AVFoundation.h>

@interface CMGViewController : UIViewController<AVCaptureMetadataOutputObjectsDelegate>

-(void)setLabel;

@end
