//
//  DonutChart.h
//  CorePlot6
//
//  Created by Adithep Narula on 4/4/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import "PlotItem.h"
#import <UIKit/UIKit.h>
#import <CorePlot/CorePlot-CocoaTouch.h>

@interface DonutChart : PlotItem <CPTPlotSpaceDelegate, CPTPlotDataSource, CPTAnimationDelegate>

@end
