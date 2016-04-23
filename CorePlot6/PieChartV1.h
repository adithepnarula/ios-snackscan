//
//  PieChartV1.h
//  CorePlot6
//
//  Created by Adithep Narula on 4/13/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

@class CMGViewController;
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CorePlot/CorePlot-CocoaTouch.h>
#import <GLKit/GLKit.h>




@interface PieChartV1 : NSObject <CPTPlotDataSource>

@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *themeButton;
@property (nonatomic, strong) CPTGraphHostingView *hostView;
@property (nonatomic, strong) CPTTheme *selectedTheme;
@property(nonatomic, strong) NSMutableArray *pieData;
@property(nonatomic, strong) CMGViewController *mainVC;

@property (nonatomic, strong) CPTBarPlot *aaplPlot;
@property (nonatomic, strong) CPTBarPlot *googPlot;
@property (nonatomic, strong) CPTBarPlot *msftPlot;

-(void)animatePieIn;
-(void)animatePieOut;
-(void)animateLegendIn;
-(void)animateLegendOut;
-(void)removePieFromSuperview;
-(id)initWithData:(NSDictionary*)json;
-(void)initializePieChart: (NSDictionary *) json;
-(void)saveFood;

@end
