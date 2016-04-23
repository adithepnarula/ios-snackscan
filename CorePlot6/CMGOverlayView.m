//
//  CMGOverlayView.m
//  CorePlot6
//
//  Created by Adithep Narula on 4/13/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import "CMGOverlayView.h"

@implementation CMGOverlayView

- (id)init
{
    self = [super init];
    if (self) {
        ((CAShapeLayer *) self.layer).lineWidth = 1;
        ((CAShapeLayer *) self.layer).strokeColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.5].CGColor;
        ((CAShapeLayer *) self.layer).fillColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.2].CGColor;
        
    }
    return self;
}

+ (Class)layerClass {
    return [CAShapeLayer class];
}

@end
