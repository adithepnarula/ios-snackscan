//
//  PieChartV1.m
//  CorePlot6
//
//  Created by Adithep Narula on 4/13/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import "PieChartV1.h"
#import "CMGViewController.h"

@interface PieChartV1()

@property(nonatomic, strong) CPTPieChart *pieChart;
@property(nonatomic, strong) CPTLegend *theLegend;
@property(nonatomic, strong) UILabel *pieLabel;
@property(nonatomic, strong)  UIView *myBox1;
@property(nonatomic, strong)  UIView *myBox2;
@property(nonatomic, strong)  UIView *myBox3;
@property(nonatomic, strong) UILabel *myLabel1;
@property(nonatomic, strong) UILabel *myLabel2;
@property(nonatomic, strong) UILabel *myLabel3;
@property(nonatomic, strong) UILabel *pieTitle;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) CAShapeLayer *circle1;
@property(nonatomic, strong) CAShapeLayer *circle2;
@property(nonatomic, strong) CAShapeLayer *circle3;


@end

@implementation PieChartV1

float caloriesGuide = 2000;
float caloriesIntake = 0;
float caloriesMaybe = 0;


-(void)initializeData: (NSDictionary*)json{
   
    /*
    float protein = 0;
    float carbs = 0;
    float fat = 0;
    float fiber = 0;
     */
    

    
    //get names
    for (NSDictionary *allergies in json[@"product"][@"nutrients"]) {
        
        //get key and value - make sure image of allergen is there
        NSString *key = [NSString stringWithFormat: @"%@", allergies[@"nutrient_name"]];
        NSInteger value = [allergies[@"nutrient_value"] intValue];
        
    
        if ((value > 0)) {
            NSLog(@"nutrient_name: %@", key);
            NSLog(@"nutrient_value: %ld", (long)value);
        }
        
        /*
        if([key isEqualToString:@"Protein"]){
            protein = value;
        }else if([key isEqualToString:@"Total Carbohydrate"]){
            carbs = value;
        }else if([key isEqualToString:@"Total Fat"]){
            fat = value;
        }else if([key isEqualToString:@"Dietary Fiber"]){
            fiber = value;
        }*/
        
        if([key isEqualToString:@"Calories"]){
            caloriesMaybe = value;
        }
        
        NSLog(@"caloriesMaybe = %f\n",caloriesMaybe);
        
    }//end for
    
    
    //leftover calories
    float caloriesLeftOver = caloriesGuide - caloriesIntake - caloriesMaybe;
    
    //set pie data
    self.pieData=  [NSMutableArray arrayWithObjects:[NSNumber numberWithDouble:caloriesLeftOver],
                    [NSNumber numberWithDouble: caloriesIntake],
                    [NSNumber numberWithDouble: caloriesMaybe],
                    nil];
    
    //NSLog(@"caloriesMaybe = %f\n",caloriesMaybe);
    

    NSLog(@"self.pieData = %@\n",self.pieData);
   
}

/*
- (id)initWithData:(NSDictionary*)json
{
    self = [super init];
    if(self) {
        [self initializeData:json];
    }
    return self;
}*/


#pragma mark - Chart behavior
-(void)initializePieChart: (NSDictionary *) json {
    [self initializeData: json];
    [self configureHost];
    [self configureGraph];
    [self configureChart];
    [self addSquareLabels];
    //[self addThreeDots];
   // [self addTitleLine];
    [self addPieTitle];
   // [self addTitle];
    //[self addAnimation];
   // [self configureLegend];
    
    NSLog(@"Bar Chart initialized!\n");
}

-(void) addAnimation{
    CABasicAnimation *fadeInAndOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAndOut.duration = 0.3;
    fadeInAndOut.autoreverses = YES;
    fadeInAndOut.fromValue = [NSNumber numberWithFloat:0.2];
    fadeInAndOut.toValue = [NSNumber numberWithFloat:1.0];
    fadeInAndOut.repeatCount = HUGE_VALF;
    fadeInAndOut.fillMode = kCAFillModeBoth;
    CPTPlot* plot = [self.pieChart.graph plotAtIndex:0];
    plot.identifier = @"Hello";
    NSLog(@"ADDDDDDDDDDING ANIMATION!!!!!!!!\n");
    NSLog(@"plot.identifier = %@\n", plot.identifier);
    [plot addAnimation:fadeInAndOut forKey:@"myanimation"];
}

-(void)configureHost {
    // 1 - Set up view frame
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
    // 1 - Set up view frame
    CGRect parentRect = self.mainVC.view.bounds;
    //take the parent view bounds and calculate bounds for a smaller view
    parentRect = CGRectMake(parentRect.origin.x,
                            parentRect.origin.y,
                            parentRect.size.width,
                            parentRect.size.height);
    
    // 2 - Create host view and add it to parent view
    //hostview is siply a container view for CPTgraph
    self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:parentRect];
    self.hostView.allowPinchScaling = NO;
    [self.mainVC.view addSubview:self.hostView];
    
    
    // 1 - Create and initialize graph
    //CPTGraph encompasses everything you see in graph (title, border, etc.)
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    self.hostView.hostedGraph = graph;
    graph.paddingLeft = 0.0f;
    graph.paddingTop = 0.0f;
    graph.paddingRight = 0.0f;
    graph.paddingBottom = 0.0f;
    graph.axisSet = nil;
    
    // 2 - Set up text style
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color = [CPTColor grayColor];
    textStyle.fontName = @"Helvetica-Bold";
    textStyle.fontSize = 16.0f;
    
    /*
     // 3 - Configure title
     NSString *title = @"Portfoloi Prices: May 1, 2012";
     graph.title = title;
     graph.titleTextStyle = textStyle;
     graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
     graph.titleDisplacement = CGPointMake(0.0f, -12.0f);
     */
    
    
    // 4 - Set theme
    self.selectedTheme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];
    [graph applyTheme:self.selectedTheme];
    
    NSLog(@"configureGraph called!\n");
}




-(void)configureChart {
    
    // 1 - Get reference to graph
    CPTGraph *graph = self.hostView.hostedGraph;
    graph.fill = [CPTFill fillWithColor: [CPTColor clearColor]];
    graph.plotAreaFrame.fill = [CPTFill fillWithColor:[CPTColor clearColor]];
    
    
    // 2 - Create chart
    self.pieChart = [[CPTPieChart alloc] init];
    self.pieChart.dataSource = self;
    self.pieChart.delegate = self;
    self.pieChart.pieRadius = (self.hostView.bounds.size.height * 0.5) / 2;
    self.pieChart.identifier = graph.title;
    self.pieChart.startAngle = M_PI_4;
    self.pieChart.sliceDirection = CPTPieDirectionClockwise;
    
    
    //animate in
    [self animatePieIn];
    
   
    
    // 4 - Add chart to graph
    [graph addPlot:self.pieChart];
    
}

-(void)configureLegend {
    // 1 - Get graph instance
    CPTGraph *graph = self.hostView.hostedGraph;
    
    // 2 - Create legend
    self.theLegend = [CPTLegend legendWithGraph:graph];
    
    // 3 - Configure legend
    self.theLegend.numberOfColumns = 1;
    CPTColor *my_color = [CPTColor colorWithComponentRed:1.0f green:1.0f blue:1.0f alpha:0.2f];
    self.theLegend.fill = [CPTFill fillWithColor: my_color];
    //theLegend.borderLineStyle = [CPTLineStyle lineStyle];
    self.theLegend.cornerRadius = 5.0;
    
    // 4 - Add legend to graph
    graph.legend = self.theLegend;
    graph.legendAnchor = CPTRectAnchorRight;
    CGFloat legendPadding = -(self.mainVC.view.bounds.size.width / 8);
    graph.legendDisplacement = CGPointMake(legendPadding, 0.0);
    NSLog(@"Configure legend called!\n");
    [self animateLegendIn];
}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return [self.pieData count];
}

//method receives plot to be drawn as well as index for the record to be displayed
-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    return [self.pieData objectAtIndex:index];
}

/* uncomment this to add data next to pie chart
-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index {
 
    // 1 - Define label text style
    static CPTMutableTextStyle *labelText = nil;
    if (!labelText) {
        labelText= [[CPTMutableTextStyle alloc] init];
        labelText.color = [CPTColor grayColor];
    }*/
    // 4 - Set up display label
/*
    NSString *labelValue = [NSString stringWithFormat:@"%d", 30];

    // 5 - Create and return layer with label text
    return [[CPTTextLayer alloc] initWithText:labelValue style:labelText];
}*/


-(NSString *)legendTitleForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index {
    return @"N/A";
}

-(CPTFill *)sliceFillForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index{
    CPTFill *fill;
    
    float alphaVal = 1.0f;
    if(index == 0){
        //green
        fill = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:161.0f/255.0f green:218.0f/255.0f blue:177.0f/255.0f alpha:alphaVal]];
    }else if(index == 1){
        //orange
        fill = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:255.0f/255.0f green:185.0f/255.0f blue:87.0f/255.0f alpha:alphaVal]];
    }else if(index == 2){
        //white
        fill = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:255.0f/255.0f green:253.0f/255.0f blue:228.0f/255.0f alpha:alphaVal]];
    }else if(index == 3){
        fill = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:0.87f green:0.86f blue:0.71f alpha:alphaVal]];
    }else{
        fill = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:0.83f green:0.36f blue:0.68f alpha:alphaVal]];
    }
    
    return fill;
    
}

-(void)animatePieIn{
    self.pieChart.startAngle = M_PI;
    
    [CPTAnimation animate:self.pieChart
                 property:@"endAngle"
                     from:-M_PI
                       to:M_PI
                 duration:1.0];
    
}

-(void)animatePieOut{
    self.pieChart.startAngle = M_PI;
    
    [CPTAnimation animate:self.pieChart
                 property:@"endAngle"
                     from:M_PI
                       to:-M_PI
                 duration:1.0];
}

-(void)animateLegendIn{
    
    CABasicAnimation *fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeIn.duration = 2.0;
    //fadeIn.autoreverses = YES;
    fadeIn.fromValue = [NSNumber numberWithFloat:0.0];
    fadeIn.toValue = [NSNumber numberWithFloat:1.0];
    //fadeIn.repeatCount = HUGE_VALF;
    fadeIn.fillMode = kCAFillModeBoth;
    [self.theLegend addAnimation:fadeIn forKey:@"myanimation"];
    NSLog(@"animateLegendIn called...\n");
    
}

-(void)animateLegendOut{
    
    /*
    CABasicAnimation *fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeIn.duration = 2.0;
    fadeIn.autoreverses = YES;
    fadeIn.fromValue = [NSNumber numberWithFloat:1.0];
    fadeIn.toValue = [NSNumber numberWithFloat:0.0];
    //fadeIn.repeatCount = HUGE_VALF;
    fadeIn.fillMode = kCAFillModeBoth;
    [self.theLegend addAnimation:fadeIn forKey:@"myanimation"];
    NSLog(@"animateLegendOut called...\n");*/
    
}

-(void)pieChart:(CPTPieChart *)plot sliceWasSelectedAtRecordIndex:(NSUInteger)idx{
    
    NSLog(@"index selected: %lu\n",(unsigned long)idx);
    //initialize label and draw a rectangle around it as a frame
    //find the label into the frame
    //initialize label and draw a rectangle around it as a frame
    //find the label into the frame
    self.pieLabel.frame = CGRectMake(0, self.mainVC.view.bounds.size.height-80, self.mainVC.view.bounds.size.width, 80);
    self.pieLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.pieLabel.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.65];
    self.pieLabel.textColor = [UIColor whiteColor];
    self.pieLabel.textAlignment = NSTextAlignmentCenter;
    [self.pieLabel setFont: [UIFont fontWithName:@"Helvetica" size:17]];
    self.pieLabel.text = @"Scan a food product's code to display valuable nutritional and diet information";
    self.pieLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.pieLabel.numberOfLines = 0;
    [self.mainVC.view addSubview:self.pieLabel];

}

-(void)saveFood{
    
    caloriesIntake = caloriesIntake + caloriesMaybe;
    caloriesMaybe = 0;
    
    NSLog(@"Self food in pie chart pressed!");
}

-(void)removePieFromSuperview{
    self.pieChart.startAngle = M_PI;
    
    //remove legends
    [self.myBox1 removeFromSuperview];
    [self.myBox2 removeFromSuperview];
    [self.myBox3 removeFromSuperview];
    [self.myLabel1 removeFromSuperview];
    [self.myLabel2 removeFromSuperview];
    [self.myLabel3 removeFromSuperview];
    
    //remove title
    //[self.titleLabel removeFromSuperview];
    [self.pieTitle removeFromSuperview];
    
    //remove view
    [self.hostView removeFromSuperview];
    
}



-(void)addPieTitle{
    // Create LabLael 2
    self.pieTitle = [[UILabel alloc]initWithFrame:CGRectMake(self.mainVC.view.bounds.size.width-370, self.mainVC.view.bounds.size.height-565, 350, 40)];
    [self.pieTitle setBackgroundColor:[UIColor clearColor]];
    [self.pieTitle setFont: [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:30]];
    [self.pieTitle setText:@"Calorie Chart"];
    [self.mainVC.view addSubview:self.pieTitle];
    
}

-(void)addSquareLabels{
    //square 1 and label 1
    self.myBox1  = [[UIView alloc] initWithFrame:CGRectMake(self.mainVC.view.bounds.size.width-320, self.mainVC.view.bounds.size.height-140, 20, 20)];
    self.myBox1.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:253.0f/255.0f blue:228.0f/255.0f alpha:1.0f];
    [self.mainVC.view addSubview:self.myBox1];
    
    // Create Label 1
    self.myLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(self.mainVC.view.bounds.size.width-290, self.mainVC.view.bounds.size.height-150, 350, 40)];
    [self.myLabel1 setBackgroundColor:[UIColor clearColor]];
    [self.myLabel1 setFont: [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:20]];
    [self.myLabel1 setText:@"Scanned Product's Calories"];
    [self.mainVC.view addSubview:self.myLabel1];
   
    
    self.myBox2  = [[UIView alloc] initWithFrame:CGRectMake(self.mainVC.view.bounds.size.width-320, self.mainVC.view.bounds.size.height-100, 20, 20)];
    self.myBox2.backgroundColor = [UIColor colorWithRed:161.0f/255.0f green:218.0f/255.0f blue:177.0f/255.0f alpha:1.0f];
    [self.mainVC.view addSubview:self.myBox2];
    
    // Create Label 2
    self.myLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(self.mainVC.view.bounds.size.width-290, self.mainVC.view.bounds.size.height-110, 350, 40)];
    [self.myLabel2 setBackgroundColor:[UIColor clearColor]];
    [self.myLabel2 setFont: [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:20]];
    [self.myLabel2 setText:@"Daily Calories Consumed"];
    [self.mainVC.view addSubview:self.myLabel2];
    
    //box 3
    self.myBox3  = [[UIView alloc] initWithFrame:CGRectMake(self.mainVC.view.bounds.size.width-320, self.mainVC.view.bounds.size.height-60, 20, 20)];
    self.myBox3.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:185.0f/255.0f blue:87.0f/255.0f alpha:1.0f];
    [self.mainVC.view addSubview:self.myBox3];
    
    // Create Label 3
    self.myLabel3 = [[UILabel alloc]initWithFrame:CGRectMake(self.mainVC.view.bounds.size.width-290, self.mainVC.view.bounds.size.height-70, 350, 40)];
    [self.myLabel3 setBackgroundColor:[UIColor clearColor]];
    [self.myLabel3 setFont: [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:20]];
    [self.myLabel3 setText:@"Your Remaining Calories"];
    [self.mainVC.view addSubview:self.myLabel3];
    
}


-(void) addThreeDots{
    self.circle1 = [CAShapeLayer layer];
    [self.circle1 setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(self.mainVC.view.bounds.size.width-30, self.mainVC.view.bounds.size.height-550, 10, 10)] CGPath]];
    [self.circle1 setStrokeColor:[[UIColor clearColor] CGColor]];
    [self.circle1 setFillColor:[[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.4f] CGColor]];
    [self.mainVC.view.layer addSublayer:self.circle1];
    
    self.circle2 = [CAShapeLayer layer];
    [self.circle2 setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(self.mainVC.view.bounds.size.width-50, self.mainVC.view.bounds.size.height-550, 10, 10)] CGPath]];
    [self.circle2 setStrokeColor:[[UIColor blackColor] CGColor]];
    [self.circle2 setFillColor:[[UIColor whiteColor] CGColor]];
    [self.mainVC.view.layer addSublayer:self.circle2];
    
    self.circle3 = [CAShapeLayer layer];
    [self.circle3 setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(self.mainVC.view.bounds.size.width-70, self.mainVC.view.bounds.size.height-550, 10, 10)] CGPath]];
    [self.circle3 setStrokeColor:[[UIColor clearColor] CGColor]];
    [self.circle3 setFillColor:[[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.4f] CGColor]];
    [self.mainVC.view.layer addSublayer:self.circle3];
}

@end
