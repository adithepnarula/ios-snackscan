//
//  ViewController.m
//  CorePlot6
//
//  Created by Adithep Narula on 4/3/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import "ViewController.h"
#import <GLKit/GLKit.h>

@interface ViewController ()

@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *themeButton;
@property (nonatomic, strong) CPTGraphHostingView *hostView;
@property (nonatomic, strong) CPTTheme *selectedTheme;
@property(nonatomic, strong) NSMutableArray *pieData;


@end

@implementation ViewController

- (void)viewDidLoad {
 
    //set up
    
    [super viewDidLoad];
    
    //set pie data
    self.pieData=  [NSMutableArray arrayWithObjects:[NSNumber numberWithDouble:90.0],
                    [NSNumber numberWithDouble:20.0],
                    [NSNumber numberWithDouble:30.0],
                    [NSNumber numberWithDouble:40.0],
                    [NSNumber numberWithDouble:50.0], [NSNumber numberWithDouble:60.0], nil];
    
    

    //fade in/out animation
    
    /*
    CABasicAnimation *fadeInAndOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAndOut.duration = 5.0;
    fadeInAndOut.autoreverses = YES;
    fadeInAndOut.fromValue = [NSNumber numberWithFloat:0.0];
    fadeInAndOut.toValue = [NSNumber numberWithFloat:1.0];
    fadeInAndOut.repeatCount = HUGE_VALF;
    fadeInAndOut.fillMode = kCAFillModeBoth;
    [pieChart addAnimation:fadeInAndOut forKey:@"myanimation"];
    */
    
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    // The plot is initialized here, since the view bounds have not transformed for landscape until now
    [self initPlot];
}

#pragma mark - Chart behavior
-(void)initPlot {
    [self configureHost];
    [self configureGraph];
    [self configureChart];
    [self configureLegend];
}

-(void)configureHost {
    // 1 - Set up view frame
    CGRect parentRect = self.view.bounds;
    parentRect = CGRectMake(parentRect.origin.x,
                            parentRect.origin.y,
                            parentRect.size.width,
                            parentRect.size.height);
    // 2 - Create host view
    self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:parentRect];
    self.hostView.allowPinchScaling = NO;
    [self.view addSubview:self.hostView];
    
}

-(void)configureGraph {
    // 1 - Set up view frame
    CGRect parentRect = self.view.bounds;
    //take the parent view bounds and calculate bounds for a smaller view
    parentRect = CGRectMake(parentRect.origin.x,
                            parentRect.origin.y,
                            parentRect.size.width,
                            parentRect.size.height);
    
    // 2 - Create host view and add it to parent view
    //hostview is siply a container view for CPTgraph
    self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:parentRect];
    self.hostView.allowPinchScaling = NO;
    [self.view addSubview:self.hostView];
    
    
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
}

-(void)configureChart {
    
    // 1 - Get reference to graph
    CPTGraph *graph = self.hostView.hostedGraph;
    graph.fill = [CPTFill fillWithColor: [CPTColor clearColor]];
    graph.plotAreaFrame.fill = [CPTFill fillWithColor:[CPTColor clearColor]];
    
    
    // 2 - Create chart
    CPTPieChart *pieChart = [[CPTPieChart alloc] init];
    pieChart.dataSource = self;
    pieChart.delegate = self;
    pieChart.pieRadius = (self.hostView.bounds.size.height * 0.3) / 2;
    pieChart.identifier = graph.title;
    pieChart.startAngle = M_PI_4;
    pieChart.sliceDirection = CPTPieDirectionClockwise;
    
    // 3 - Create gradient
    /*
    CPTGradient *overlayGradient = [[CPTGradient alloc] init];
    overlayGradient.gradientType = CPTGradientTypeRadial;
    overlayGradient = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.0] atPosition:0.9];
    overlayGradient = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.4] atPosition:1.0];
    pieChart.overlayFill = [CPTFill fillWithGradient:overlayGradient];*/
    
    
    //animate out
    pieChart.startAngle = M_PI;
    
    [CPTAnimation animate:pieChart
                 property:@"endAngle"
                     from:-M_PI
                       to:M_PI
                 duration:5.0];
    
    // 4 - Add chart to graph    
    [graph addPlot:pieChart];

}

-(void)configureLegend {
    // 1 - Get graph instance
    CPTGraph *graph = self.hostView.hostedGraph;
    // 2 - Create legend
    CPTLegend *theLegend = [CPTLegend legendWithGraph:graph];
    // 3 - Configure legend
    theLegend.numberOfColumns = 1;
    theLegend.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];
    theLegend.borderLineStyle = [CPTLineStyle lineStyle];
    theLegend.cornerRadius = 5.0;
    // 4 - Add legend to graph
    graph.legend = theLegend;
    graph.legendAnchor = CPTRectAnchorRight;
    CGFloat legendPadding = -(self.view.bounds.size.width / 8);
    graph.legendDisplacement = CGPointMake(legendPadding, 0.0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return [self.pieData count];
}

//method receives plot to be drawn as well as index for the record to be displayed
-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    return [self.pieData objectAtIndex:index];
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index {
    // 1 - Define label text style
    static CPTMutableTextStyle *labelText = nil;
    if (!labelText) {
        labelText= [[CPTMutableTextStyle alloc] init];
        labelText.color = [CPTColor grayColor];
    }
  
 
    // 4 - Set up display label
    NSString *labelValue = [NSString stringWithFormat:@"$%0.2f USD (%0.1f %%)", 123.2,  (2*100.0f)];
    // 5 - Create and return layer with label text
    return [[CPTTextLayer alloc] initWithText:labelValue style:labelText];
}

-(NSString *)legendTitleForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index {
    return @"N/A";
}

-(CPTFill *)sliceFillForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index{
    CPTFill *fill;
    
    if(index == 0){
        fill = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:1.0f green:0.0f blue:0.0f alpha:0.25f]];
    }else{
        fill = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:0.0f green:1.0f blue:0.0f alpha:0.25f]];
    }
 
    return fill;
    
}


@end
