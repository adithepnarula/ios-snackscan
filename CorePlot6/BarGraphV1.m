//
//  BarGraphV1.m
//  CorePlot6
//
//  Created by Adithep Narula on 4/14/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import "BarGraphV1.h"
#import "CMGViewController.h"

@interface BarGraphV1()

@property (nonatomic, strong)NSDictionary *data;
@property (nonatomic, strong)NSDictionary *sets;
@property (nonatomic, strong)NSArray *nutrients;
@property (nonatomic, strong)CPTGraph *graph;
@property (nonatomic, strong)CPTXYPlotSpace *plotSpace;
@property (nonatomic, strong)NSMutableArray *plotArray;
@property (nonatomic, strong)NSMutableDictionary *guideIntake;
@property (nonatomic, strong)NSMutableDictionary *userIntake;
@property (nonatomic, strong)NSMutableDictionary *maybeIntake;

@end

@implementation BarGraphV1

CGFloat const CPDBarWidth = 0.25f;
CGFloat const CPDBarInitialX = 0.25f;

//fill userIntake
float UProtein = 0;
float UCarbs = 0;
float USugars = 0;
float USodium = 0;
float UFibre = 0;
float UFattyAcids = 0;
float UFat = 0;


#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return 7;
}

-(void)initializeUserIntake{
    //initialize userIntake dictionary (stack 1)
    self.userIntake = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                       [NSNumber numberWithFloat: UProtein], @"protein",
                       [NSNumber numberWithFloat: UFat], @"fat",
                       [NSNumber numberWithFloat: UCarbs], @"carbs",
                       [NSNumber numberWithFloat: USugars], @"sugars",
                       [NSNumber numberWithFloat: USodium], @"sodium",
                       [NSNumber numberWithFloat: UFibre], @"fibre",
                       [NSNumber numberWithFloat: UFattyAcids], @"fatty acids", nil];
}

-(void)generateData: (NSDictionary *)json{
   

    //fill maybeIntake
    float protein = 0;
    float carbs = 0;
    float sugars = 0;
    float sodium = 0;
    float fibre = 0;
    float fattyAcids = 0;
    float fat = 0;
    
    for (NSDictionary *allergies in json[@"product"][@"nutrients"]) {
        
        NSString *key = [NSString stringWithFormat: @"%@", allergies[@"nutrient_name"]];
        
        if(![allergies[@"nutrient_value" ] isEqualToString:@""]){
            float value = [allergies[@"nutrient_value"] floatValue];
            
            
            if ((value > 0)) {
                NSLog(@"nutrient_name: %@", key);
                NSLog(@"nutrient_value: %ld", (long)value);
            }
            
            if([key isEqualToString:@"Protein"]){
                protein = value;
            }else if([key isEqualToString:@"Total Carbohydrate"]){
                carbs = value;
            }else if([key isEqualToString:@"Total Fat"]){
                fat = value;
            }else if([key isEqualToString:@"Dietary Fiber"]){
                fibre = value;
            }else if([key isEqualToString:@"Saturated Fat"]){
                fattyAcids = value;
            }else if([key isEqualToString:@"Sodium"]){
                sodium = value * 0.001; //convert
            }else if([key isEqualToString:@"Sugars"]){
                sugars = value;
            }
            
        }
      
        
    }//end for

    //set maybeIntake dictionary (stack 2)
    self.maybeIntake = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithFloat: protein], @"protein",
                        [NSNumber numberWithFloat: fat], @"fat",
                        [NSNumber numberWithFloat: carbs], @"carbs",
                        [NSNumber numberWithFloat: sugars], @"sugars",
                        [NSNumber numberWithFloat: sodium], @"sodium",
                        [NSNumber numberWithFloat: fibre], @"fibre",
                        [NSNumber numberWithFloat: fattyAcids], @"fatty acids", nil];
    
    //fill guideIntake
    float gProtein = 50.0f - protein - [self.userIntake[@"protein"] floatValue];
    float gCarbs = 310.f - carbs - [self.userIntake[@"carbs"] floatValue];
    float gSugars = 90.0f - sugars - [self.userIntake[@"sugars"] floatValue];
    float gSodium = 2.3f - sodium - [self.userIntake[@"sodium"] floatValue];
    float gFibre = 30.0f - fibre - [self.userIntake[@"fibre"] floatValue];
    float gFattyAcids = 24.4f - fattyAcids - [self.userIntake[@"fatty acids"] floatValue];
    float gFat = 70.0f - fat - [self.userIntake[@"fat"]floatValue];
    
    //initialize dailyIntake dictionary (stack 3)
    self.guideIntake = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithFloat: gProtein], @"protein",
                        [NSNumber numberWithFloat: gFat], @"fat",
                        [NSNumber numberWithFloat: gCarbs], @"carbs",
                        [NSNumber numberWithFloat: gSugars], @"sugars",
                        [NSNumber numberWithFloat: gSodium], @"sodium",
                        [NSNumber numberWithFloat: gFibre], @"fibre",
                        [NSNumber numberWithFloat: gFattyAcids], @"fatty acids", nil];
    
    
    
    NSLog(@"----------------- stack 1 values---------------------\n");
    NSLog(@"pr = %f, carb = %f, sugar = %f, sodium = %f, fibre = %f, fatty = %f, fat = %f\n", [self.userIntake[@"protein"] floatValue], [self.userIntake[@"carbs"] floatValue], [self.userIntake[@"sugars"] floatValue], [self.userIntake[@"sodium"] floatValue], [self.userIntake[@"fibre"] floatValue], [self.userIntake[@"fatty acids"] floatValue], [self.userIntake[@"fat"]floatValue]);
    
    NSLog(@"----------------- stack 2 values---------------------\n");
    NSLog(@"pr = %f, carb = %f, sugar = %f, sodium = %f, fibre = %f, fatty = %f, fat = %f\n", protein, carbs, sugars, sodium, fibre, fattyAcids, fat);

    NSLog(@"---------------- stack 3 values ---------------------\n");
    NSLog(@"pr = %f, carb = %f, sugar = %f, sodium = %f, fibre = %f, fatty = %f, fat = %f\n", gProtein, gCarbs, gSugars, gSodium, gFibre, gFattyAcids, gFat);

    
    NSMutableDictionary *dataTemp = [[NSMutableDictionary alloc] init];
    
    //Array containing all the dates that will be displayed on the X axis
    self.nutrients = [NSArray arrayWithObjects:@"protein", @"fat", @"carbs",
             @"sugars", @"sodium", @"fibre", @"fatty acids", nil];
    
    //Dictionary containing the name of the two sets and their associated color
    //used for the demo
    self.sets = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:0.18f green: 0.28f blue:0.38f alpha:1.0f], @"Plot 1",
            [UIColor colorWithRed:0.35f green:0.56f blue:0.64f alpha:1.0f], @"Plot 2", [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.2f], @"Plot 3",nil];
    
    
    //for each nutrient
    for (NSString *nutrient in self.nutrients) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        //int count = 0;
        for (NSString *set in self.sets) {
            NSNumber *num;
            
            //plot 1 = what the user has saved
            if([set isEqualToString:@"Plot 1"]){
                num = self.userIntake[nutrient];
            }
            
            //plot 2 = what the user is scanning
            else if([set isEqualToString:@"Plot 2"]){
                num = self.maybeIntake[nutrient];
                NSLog(@"%@ = %@\n",nutrient,num);
            }
            
            //plot 3 = what the target is
            else if([set isEqualToString:@"Plot 3"]){
                num = self.guideIntake[nutrient];
            }
            //num = [NSNumber numberWithInt:50];
            [dict setObject:num forKey:set];
            //count++;
        }
        [dataTemp setObject:dict forKey:nutrient];
        
    }
    
    
    //data
    //key = nutrient_name
    //object = Dictionary (key is set... plot1, plot2, plot3 and object is the number)
    
    self.data = [dataTemp copy];
    NSLog(@"%@", self.data);
    
}

-(void)GraphFromSuperview{
    [self.hostView removeFromSuperview];
    
}

//each plot is passed in
//fieldNUm represents x axis when fieldNum = 0 and y axis when fieldNum = 1.
- (double)doubleForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    double num = NAN;
    
    //X Value
    if (fieldEnum == 0) {
        num = index;
    }
    
    else {
        double offset = 0;
        //plot 1 fails if statement, so its offset is 0
        if (((CPTBarPlot *)plot).barBasesVary) {
            //if plot 2, plot3 - loop through set
            for (NSString *set in [[self.sets allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]) {
                //if (plot1 plot1), (plot2 polot2) (plot3 plot3) break
                if ([plot.identifier isEqual:set]) {
                    break;
                }
                offset += [[[self.data objectForKey:[self.nutrients objectAtIndex:index]] objectForKey:set] floatValue];
                NSLog(@"plot = %@ || offset = %f", plot.identifier,offset);
            }
        }
        //NSLog(@"plot = %@ || offset = %f", plot.identifier,offset);
        
        //Y Value
        if (fieldEnum == 1) {
            //get carbs (plot1)'s value and add it to offset
            num = [[[self.data objectForKey:[self.nutrients objectAtIndex:index]] objectForKey:plot.identifier] floatValue] + offset;
        }
        
        //Offset for stacked bar
        else {
            num = offset;
        }
    }
    
    //plot 2 is incorrect! need to go from 50 to 100
    NSLog(@"plot = %@ || num = %f\n", plot.identifier, num);
    
    return num;
}

#pragma mark - Chart behavior
-(void)initializePlot: (NSDictionary *)json firstTime: (BOOL) flag {
    self.hostView.allowPinchScaling = NO;
    //initialize array
    self.plotArray = [[NSMutableArray alloc]initWithCapacity:3];
    
    if(flag) {
        //initialize the rest
        [self initializeUserIntake];
        
    }
    
    NSLog(@"---------------------USER INTAKE BEFORE INITIALIZED---------------------\n");
    NSLog(@"pr = %f, carb = %f, sugar = %f, sodium = %f, fibre = %f, fatty = %f, fat = %f\n", [self.userIntake[@"protein"] floatValue], [self.userIntake[@"carbs"] floatValue], [self.userIntake[@"sugars"] floatValue], [self.userIntake[@"sodium"] floatValue], [self.userIntake[@"fibre"] floatValue], [self.userIntake[@"fatty acids"] floatValue], [self.userIntake[@"fat"]floatValue]);

    [self generateData: json];
    [self configureHost];
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
    [self configureBarChart];
    
}

-(void) configureHost{
    CGRect parentRect = self.mainVC.view.bounds;
    parentRect = CGRectMake(parentRect.origin.x,
                            parentRect.origin.y,
                            parentRect.size.width,
                            parentRect.size.height);
    // 2 - Create host view
    self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:parentRect];
    self.hostView.allowPinchScaling = NO;
    [self.mainVC.view addSubview:self.hostView];
}

-(void)configureGraph {
    // 1 - Create the graph
    //self.graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    self.graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    self.graph.plotAreaFrame.masksToBorder = NO;
    self.hostView.hostedGraph = self.graph;
    
    // 2 - Configure the graph
    [self.graph applyTheme:[CPTTheme themeNamed:kCPTPlainBlackTheme]];
    self.graph.paddingBottom = 0.0f;
    self.graph.paddingLeft  = 0.0f;
    self.graph.paddingTop    = 0.0f;
    self.graph.paddingRight  = 0.0f;
    
    // 3 - Set up styles
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor whiteColor];
    titleStyle.fontName = @"Helvetica-Bold";
    titleStyle.fontSize = 16.0f;
    
    //4 - set up plot area frames
    //CPTMutableLineStyle *borderLineStyle    = [CPTMutableLineStyle lineStyle];
    //borderLineStyle.lineColor               = [CPTColor clearColor];
    //borderLineStyle.lineWidth               = 0.01f;
    //self.graph.plotAreaFrame.borderLineStyle     = borderLineStyle;
    self.graph.plotAreaFrame.paddingTop          = 10.0;
    self.graph.plotAreaFrame.paddingRight        = 10.0;
    self.graph.plotAreaFrame.paddingBottom       = -1.0;
    self.graph.plotAreaFrame.paddingLeft         = -1.0;
    
    
    // 5 - Set up plot space
    CGFloat xMin = -1.0f;
    CGFloat xMax = 8.0f;
    CGFloat yMin = 0.0f;
    CGFloat yMax = 400.0f;  // should determine dynamically based on max price
    
    //6 - add plot space
    /*
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) self.graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xMin) length:CPTDecimalFromFloat(xMax)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(yMin) length:CPTDecimalFromFloat(yMax)];*/
    
    //Add plot space
    self.plotSpace       = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    self.plotSpace.delegate              = self;
    self.plotSpace.xRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xMin)
                                                                   length:CPTDecimalFromInt(xMax)];
    self.plotSpace.yRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(yMin)
                                                                   length:CPTDecimalFromInt(yMax)];
}


-(void)configurePlots {
    
    // 2 - Set up line style
    CPTMutableLineStyle *barLineStyle = [[CPTMutableLineStyle alloc] init];
    barLineStyle.lineColor = [CPTColor lightGrayColor];
    barLineStyle.lineWidth = 0.01;
    
    // 3 - Add plots to graph
    CPTGraph *graph = self.hostView.hostedGraph;
    
    //4 - make graph transparent
    graph.fill = [CPTFill fillWithColor: [CPTColor clearColor]];
    graph.plotAreaFrame.fill = [CPTFill fillWithColor:[CPTColor clearColor]];
    
}

-(void)configureAxes {
    
    //Grid line styles
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth            = 0.0;
    majorGridLineStyle.lineColor            = [[CPTColor clearColor] colorWithAlphaComponent:0.1];
    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth            = 0.0;
    minorGridLineStyle.lineColor            = [[CPTColor clearColor] colorWithAlphaComponent:0.1];
    
    //Axises
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.graph.axisSet;
    
    //X axis
    
    
    CPTXYAxis *x                    = axisSet.xAxis;
    x.orthogonalCoordinateDecimal   = CPTDecimalFromInt(4);
    x.majorIntervalLength           = CPTDecimalFromInt(4);
    x.minorTicksPerInterval         = 2;
    x.labelingPolicy                = CPTAxisLabelingPolicyNone;
    x.majorGridLineStyle            = majorGridLineStyle;
    x.axisConstraints               = [CPTConstraints constraintWithLowerOffset:0.0];
    
    
    //Y axis
    CPTXYAxis *y            = axisSet.yAxis;
    y.title                 = @"Value";
    y.titleOffset           = 50.0f;
    y.labelingPolicy        = CPTAxisLabelingPolicyAutomatic;
    y.majorGridLineStyle    = majorGridLineStyle;
    y.minorGridLineStyle    = minorGridLineStyle;
    y.axisConstraints       = [CPTConstraints constraintWithLowerOffset:0.0];
    
}

-(void)configureBarChart{
    //Create a bar line style
    /*
    CPTMutableLineStyle *barLineStyle   = [[CPTMutableLineStyle alloc] init];
    barLineStyle.lineWidth              = 0.1;
    barLineStyle.lineColor              = [CPTColor blueColor];
    CPTMutableTextStyle *whiteTextStyle = [CPTMutableTextStyle textStyle];
    whiteTextStyle.color                = [CPTColor clearColor];
    */
    
    
    //Plot
    BOOL firstPlot = YES;
    int count = 0;
    //for each level of bar, do the following:
    for(NSString *set in self.sets){
       // CPTColor *myColor = [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.2f];
        
        
        CPTBarPlot *plot        = [CPTBarPlot tubularBarPlotWithColor:[CPTColor blueColor] horizontalBars:NO];
        
        //add plot to array (use to remove animation later)
        self.plotArray[count] = plot;
        
        plot.lineStyle          = nil; //barLineStyle;
        CGColorRef color        = ((UIColor *)[self.sets objectForKey:set]).CGColor;
        plot.fill               = [CPTFill fillWithColor:[CPTColor colorWithCGColor:color]];
        
        plot.identifier         = set;
        
        if([plot.identifier isEqual:@"Plot 1"]){
            //first flot bar not vary
            plot.barBasesVary   = NO;
            //set flag to NO after
            firstPlot           = NO;
        } else{
            plot.barBasesVary = YES;
        }
        
        /*
        if (firstPlot) {
            //first flot bar not vary
            plot.barBasesVary   = NO;
            //set flag to NO after
            firstPlot           = NO;
        } else {
            //plot 2, plot 3 will vary
            plot.barBasesVary   = YES;
        }*/
        
        plot.barWidth           = CPTDecimalFromFloat(0.8f);
        plot.barsAreHorizontal  = NO;
        plot.dataSource         = self;
        
        //delegate method recordIndex gets called when user presses the plot
        plot.delegate = self;
      
    
        
        NSLog(@"Plot = %@ || color = %@\n", plot.identifier, color);
        
        
        //<<< if bar is 1 (mid bar) add animation
        
        if([set isEqualToString:@"Plot 2"]){
            NSLog(@"In ANIMATION!!!!!!!!!!!!!!!!!!!!\n");
            CABasicAnimation *fadeInAndOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
            fadeInAndOut.duration = 0.7;
            fadeInAndOut.autoreverses = YES;
            fadeInAndOut.fromValue = [NSNumber numberWithFloat:0.2];
            fadeInAndOut.toValue = [NSNumber numberWithFloat:1.0];
            fadeInAndOut.repeatCount = HUGE_VALF;
            fadeInAndOut.fillMode = kCAFillModeBoth;
            [plot addAnimation:fadeInAndOut forKey:@"myanimation"];
            NSLog(@"PLOT NUMBER: %@\n", plot.identifier);
        }
        count++;
        NSLog(@"Count: %d\n", count);
        ///////////
        
        
        [self.graph addPlot:plot toPlotSpace:self.plotSpace];
        
    }
    
  
    NSLog(@"configureBarChart called!\n");
    
}

//when user press save, remove the animation from middle part and make it a solid color
-(void)saveFood{
    
    //stop animation
    int i;
    for(i = 0; i < 3; i ++){
         CPTXYGraph *tempPlot = self.plotArray[i];
        if( [tempPlot.identifier isEqual:@"Plot 2"]){
            [tempPlot removeAllAnimations];
        }
    }
    
    
    //save food
    //loop through self.userIntake and add each elemement and set maybe to 0
    for(NSString *key in [self.userIntake allKeys]){
        self.userIntake[key] = @([self.userIntake[key] floatValue] + [self.maybeIntake[key] floatValue]);
        self.maybeIntake[key] = [NSNumber numberWithFloat:0.0f];
    }
    
    
    NSLog(@"SaveFood pressed!\n");
}

-(void)addGraphToSubview{
    [self.mainVC.view addSubview:self.hostView];
}

-(void)removeGraphFromSuperview{
    NSLog(@"remove graph from superview in bargraph in called!\n");
    [self.hostView removeFromSuperview];
}

#pragma mark - CPTBarPlotDelegate methods
-(void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)index {
    NSLog(@"barWasSelectedAtRecordIndex called: %lu\n", (unsigned long)index);
}


@end
