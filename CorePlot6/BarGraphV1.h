//
//  BarGraphV1.h
//  CorePlot6
//
//  Created by Adithep Narula on 4/14/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

@class CMGViewController;
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CorePlot/CorePlot-CocoaTouch.h>
#import <GLKit/GLKit.h>


@interface BarGraphV1 : NSObject <CPTBarPlotDataSource, CPTBarPlotDelegate>

@property (nonatomic, strong) IBOutlet CPTGraphHostingView *hostView;
@property (nonatomic, strong) CPTPlotSpaceAnnotation *priceAnnotation;
@property(nonatomic, strong) CMGViewController *mainVC;

-(void)initPlot;
-(void)configureGraph;
-(void)configurePlots;
-(void)configureAxes;
-(void)initializeGraph;
-(void)saveFood;
- (void)initializePlot:(NSDictionary*)json firstTime: (BOOL) flag;
-(void)generateData: (NSDictionary*)json;
-(void) removeGraphFromSuperview;
-(void)addGraphToSubview;

@end
