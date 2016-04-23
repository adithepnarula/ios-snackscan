//
//  CMGViewController.m
//  BarCodeReader
//
//  Created by Chris Greening on 01/10/2013.
//  Copyright (c) 2013 Chris Greening. All rights reserved.
//

#import "CMGViewController.h"
#import "Request.h"

@interface CMGViewController ()

@property(nonatomic, strong) AVCaptureSession *session;
@property(nonatomic, strong) UIView *previewView;
@property(nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property(nonatomic, strong) IBOutlet UILabel *barcode;

//extra properties added by Adi
@property(nonatomic, strong) UIImageView *glutenView;
@property (nonatomic, strong) IBOutlet UILabel *scanLabel;
@property (nonatomic, strong) PieChartV1 *pieObject;
@property(nonatomic, strong) BarGraphV1 *graphObject;
@property(nonatomic, strong)NSDictionary *jsonCopy;
@property(nonatomic, strong)UIButton *butCal;
@property (nonatomic, strong)UIButton *but;
@property(nonatomic, strong) CAShapeLayer *circle1;
@property(nonatomic, strong) CAShapeLayer *circle2;
@property(nonatomic, strong) CAShapeLayer *circle3;

//extra properties added by Adisa
@property(nonatomic, strong) NSMutableDictionary *allergens;
@property(nonatomic, strong) NSMutableArray *picture;
@property(nonatomic, strong) IBOutlet UILabel *label;
@property(nonatomic, strong) Request *r;
@property (nonatomic, assign) int recognize;
@property(nonatomic, strong) UIImageView *blur;
@property(nonatomic, strong)  CAShapeLayer *shape;


/*additional images*/
@property(nonatomic, strong) UIImageView *scanner;
@property(nonatomic, strong) IBOutlet UILabel *all_label;
@property(nonatomic, strong) IBOutlet UILabel *product;

/* adding sound */
@property(nonatomic, strong) AVAudioPlayer *audio;


@end

@implementation CMGViewController

int numLeftSwipes;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //<<<<<<<<DI'S CUSTOM CODE>>>>>>>>>>>>>>>>
    //allocate allergy array
    self.allergens = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                      @"corn-free.png", @"Corn",
                      @"egg-free.png", @"Egg",
                      @"lactose-free.png", @"Lactose",
                      @"dairy-free.png", @"Milk",
                      @"nut-free.png", @"Tree Nuts",
                      @"fish-free.png", @"Fish",
                      //@"gluten-free copy.png", @"Gluten",
                      @"soy-free.png", @"Soybean",
                      @"peanut-free.png", @"Peanuts",
                      @"sugar-free.png", @"Sugar",
                      //@"wheat-free.png", @"Wheat",
                      nil];
    
    //add background tap
    self.picture = [[NSMutableArray alloc]init];
    self.recognize = 0;
    
    //initialize left swipe
    numLeftSwipes = 0;
    
    [self addSound];
    
    //<<<<<<< END DI's CUSTOM >>>>>>>>>>>>>>>>>

    
    //start working with the camera
    self.session = [[AVCaptureSession alloc] init];
    
    // create the preview layer (use to display video on the view)
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.previewView = [[UIView alloc] init];
    self.previewView.translatesAutoresizingMaskIntoConstraints = NO;
    
    //add preview layer to the view
    [self.view addSubview:self.previewView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_previewView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_previewView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_previewView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_previewView)]];
    
    
    //add preview layer as sublayer
    [self.previewView.layer addSublayer:self.previewLayer];
    
    //Di's code
    
    //self.label = [[UILabel alloc] init];
    [self setLabel];
    
    
    // draw the scanner image - additional code
    // initialize photo and set frame
    [self initializeScannerPhoto];
    
    
    //end di's code
    
    
    self.previewLayer.videoGravity = AVLayerVideoGravityResize;
    //    previewLayer.orientation = AVCaptureVideoOrientationLandscapeLeft;
    
    
    // This method returns the camera used to capture the video
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *camera = nil; //[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    for(camera in devices) {
        if(camera.position == AVCaptureDevicePositionBack) {
            break;
        }
    }
    //testing if camera works OK
    NSError *error = nil;
    [camera lockForConfiguration:&error];
    if([camera isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        [camera setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
    }
    if([camera isAutoFocusRangeRestrictionSupported]) {
        [camera setAutoFocusRangeRestriction:AVCaptureAutoFocusRangeRestrictionNear];
    }
    [camera unlockForConfiguration];
    if(error) {
        NSLog(@"Erorr locking for configuration, %@", error);
    }
    
    // Create a AVCaptureInput with the camera device - this object used to capture input
    AVCaptureDeviceInput *cameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:camera error:&error];
    if (cameraInput == nil) {
        NSLog(@"Error to create camera capture:%@",error);
    }
    // Add the input and output
    [self.session addInput:cameraInput];
    
    // Create a VideoDataOutput and add it to the session
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [self.session addOutput:output];
    
    // see what types are supported (do this after adding otherwise the output reports nothing supported
    NSSet *potentialDataTypes = [NSSet setWithArray:@[AVMetadataObjectTypeAztecCode,
                                                      AVMetadataObjectTypeCode128Code,
                                                      AVMetadataObjectTypeCode39Code,
                                                      AVMetadataObjectTypeCode39Mod43Code,
                                                      AVMetadataObjectTypeCode93Code,
                                                      AVMetadataObjectTypeEAN13Code,
                                                      AVMetadataObjectTypeEAN8Code,
                                                      AVMetadataObjectTypePDF417Code,
                                                      //                                                      AVMetadataObjectTypeQRCode,
                                                      AVMetadataObjectTypeUPCECode]];
    
    NSMutableArray *supportedMetaDataTypes = [NSMutableArray array];
    for(NSString *availableMetadataObject in output.availableMetadataObjectTypes) {
        if([potentialDataTypes containsObject:availableMetadataObject]) {
            [supportedMetaDataTypes addObject:availableMetadataObject];
        }
    }
    
    [output setMetadataObjectTypes:supportedMetaDataTypes];
    
    //<<<<<<<<<<<<<< CUSTOM CODE >>>>>>>>>>>>>>>>
    
    //Create three images (gluten, nuts, acid) and add them as subview, but hide them
    //add overlay image as a subview
    self.glutenView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"glutenfree.png"]];
    [self.glutenView setFrame:CGRectMake(30, 100, 260, 200)];
    [[self view] addSubview:self.glutenView];
    self.glutenView.hidden = YES;
    
    //add action to the image - make image disappear when user touches it
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(glutenTapDetected)];
    singleTap.numberOfTapsRequired = 1;
    [self.glutenView setUserInteractionEnabled:YES];
    [self.glutenView addGestureRecognizer:singleTap];
    
    //add label
    /*
    self.scanLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 300, 250, 40)];
    self.scanLabel.text = @"Scan a food product's barcode to display valuable nutritional and diet information";
    self.scanLabel.textColor=[UIColor blackColor];
    self.scanLabel.font = [UIFont fontWithName:@"Marker Felt" size:17];
    [[self view] addSubview:self.scanLabel];
    */
    
    UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeHandle:)];
    rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [rightRecognizer setNumberOfTouchesRequired:1];
    
    //add the your gestureRecognizer , where to detect the touch..
    [self.view addGestureRecognizer:rightRecognizer];
    
    UISwipeGestureRecognizer *leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeHandle:)];
    leftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [leftRecognizer setNumberOfTouchesRequired:1];
    
    [self.view addGestureRecognizer:leftRecognizer];

    //<<<<<<<<<<<<<< END CUSTOM CODE >>>>>>>>>>>>>
    
    // Get called back everytime something is recognised
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Start the session running
    [self.session startRunning];
    
    
}

-(void)initializeScannerPhoto{
    
    self.scanner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Scan.png"]];
    [self.scanner setFrame:CGRectMake(30, self.view.bounds.size.height/2-90, self.view.bounds.size.width-70, 200)];
    [self.view addSubview:self.scanner];
    self.scanner.alpha = 0.7;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    if(metadataObjects.count > 0) {
        //passes work back to the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString *detected = [[NSString alloc] init];
            
            AVMetadataMachineReadableCodeObject *recognizedObject = metadataObjects.firstObject;
            if (recognizedObject.stringValue != nil){
                
                [self.label setFont: [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:20]];
                
                /* changing label */
                detected = recognizedObject.stringValue;
                self.label.text = @"Barcode detected";
                self.recognize += 1;
                
            } else {
                [self setLabel];
            }
            //make request object and call request
            //do the request only once
            if (self.recognize <= 1) {
                
                /*play sound when barcode is recognized - additional code */
                [self.audio play];
                
                self.r = [[Request alloc] initRequest];
                [self.r makeRequest:detected done:^(NSDictionary *json) {
                    //make global pointer
                    self.jsonCopy = json;
                    
                    NSLog(@"json: %@", json);
                    //data stored in json
                    
                    //print all of the allergies
                    for (NSDictionary *allergies in json[@"product"][@"allergens"]) {
                        
                        //get key and value - make sure image of allergen is there
                        NSInteger value = [allergies[@"allergen_value"] intValue];
                        NSString *key = [NSString stringWithFormat: @"%@", allergies[@"allergen_name"]];
                        
                        if ((value == 0) && (self.allergens[key] != nil)) {
                            //                            NSLog(@"free: %@", self.allergens[key]);
                            [self.picture addObject:[[UIImageView alloc] initWithImage: [UIImage imageNamed:self.allergens[key]]]];
                        }
                    }
                    
                    // additional code - remove scanner image from view
                    [self blurBackground];
                    
                    /* add animation to make the transition nicer*/
                    
                    [UIView animateWithDuration:0.5
                                          delay:0.0
                                        options:UIViewAnimationOptionCurveEaseOut
                                     animations:^{
                                         self.scanner.alpha = 0;
                                         self.label.alpha = 0;
                                     }
                                     completion:^(BOOL finished){
                                         
                                         /*remove from view*/
                                         [self.scanner removeFromSuperview];
                                         [self.label removeFromSuperview];
                                         
                                     }];
                    
                    [self setImage: self.picture];
                    
                    [self setAllergenLabel];
                    [self setProductName:json[@"product"][@"product_name"]];
                    
                    /*add three dots - custom code*/
                    [self addThreeDots];
                    [self changeDotsColor:0];
                    
                    /*add animation - custom code*/
                    [UIView animateWithDuration:2.0
                                          delay:0.0
                                        options:UIViewAnimationOptionCurveEaseIn
                                     animations:^{
                                         self.all_label.alpha = 1;
                                         self.product.alpha = 1;
                                     }
                                     completion:nil];
                    [self drawLine];
                    
                 
                    
                    // end additional code
                    //all data is available at this point
                    
                    /*
                     self.pieObject = [[PieChartV1 alloc] initWithData:json];
                     self.pieObject.mainVC = self;
                     */
                    
                }];//end async call
            }
        });
        
        /*find another way to keep the camera going*/
        /*[self.session stopRunning];*/
    }
}
//<<<<<< CUSTOM METHODS ADI >>>>>>>
-(void)glutenTapDetected{
    self.glutenView.hidden = YES;
}

/*
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.pieObject animatePieOut];
    [self.pieObject animateLegendOut];
    
}*/

-(void) buttonClicked:(UIButton*)sender
{
    
    [self.graphObject saveFood];
    NSLog(@"button pressed!\n");
}

-(void) buttonClickedPie:(UIButton*)sender{
    [self.pieObject saveFood];
}

- (void)rightSwipeHandle:(UISwipeGestureRecognizer*)gestureRecognizer
{
    NSLog(@"rightSwipeHandle");

}


//switch to graph when user swipes right
- (void)leftSwipeHandle:(UISwipeGestureRecognizer*)gestureRecognizer
{
    /*
    //animation
    CATransition *animation = [CATransition animation]; //creates and returns a new animation instance
    animation.duration = 0.20f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = kCATransitionPush;
    animation.subtype = gestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft ? kCATransitionFromRight : kCATransitionFromLeft;
    [self.view.layer addAnimation:animation forKey:@"animation"];
    */
    
    //switch from allergens to pie
    if(numLeftSwipes == 0){
        NSLog(@"leftSwipeHandle\n");
        
        //remove all ui objects from current view
        [self.label removeFromSuperview];
        [self removeIcon];
        [self.all_label removeFromSuperview];
        
        //change dot color
        [self changeDotsColor:1];
        
        //add pie chart
        [self addPieChart];
   
    }
    //switch from pie to graph
    else if(numLeftSwipes == 1){
        //remove pie
        [self.pieObject animatePieOut];
        [self.pieObject removePieFromSuperview];
        //[self.butCal removeFromSuperview];
        
        //change dot color
        [self changeDotsColor:2];
        
        //add bar graph
        [self addBarGraph];
        
    }else if(numLeftSwipes == 2){
        //remove bar graph
        
        NSLog(@"numLeftSwipes 2 called!\n");
        
        [self.graphObject removeGraphFromSuperview];
        [self.but removeFromSuperview];
        
        //change dot color
        [self changeDotsColor:0];
        
        
        //restart session
        [self restartSession];
        
        //remove food title, dots, line, and page title
        [self restartScanPageLook];
    
        
        
        numLeftSwipes = -1;
    }
    numLeftSwipes++;
    
}


-(void)restartScanPageLook{
    
    //remove food title, dots, line, and page title
    [self.all_label removeFromSuperview];
    [self.shape removeFromSuperlayer];
    [self.circle1 removeFromSuperlayer];
    [self.circle2 removeFromSuperlayer];
    [self.circle3 removeFromSuperlayer];
    [self.product removeFromSuperview];
    
    
    //set scanner photo and labels
    [self initializeScannerPhoto];
    [self setLabel];
    
}

-(void)addPieChart{
    //if graph has not been initialized yet
    if(self.pieObject == nil){
        //add pie object
        self.pieObject = [[PieChartV1 alloc] init];
        self.pieObject.mainVC = self;
    }
    [self.pieObject initializePieChart: self.jsonCopy];
    
    
    //add button to save
    //add button to save
    
    self.butCal = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.butCal addTarget:self action:@selector(buttonClickedPie:) forControlEvents:UIControlEventTouchUpInside];
    
    //Di's addition - changing button
    [self.butCal setFrame:CGRectMake(200, 400, 200, 60)];
    [self.butCal setTitle:@"Add Cal" forState:UIControlStateNormal];
    [self.butCal setTitleColor:[UIColor colorWithRed:0.18f green: 0.28f blue:0.38f alpha:1.0f] forState:UIControlStateNormal];
    [self.butCal setExclusiveTouch:YES];
    
    //make the button bigger
    //[self.view addSubview:self.butCal];

}

-(void) restartSession{
    //reset label and start another session
    self.recognize = 0;
    [self setLabel];
    [self.blur removeFromSuperview];
    [self.view addSubview:self.label];
    [self.picture removeAllObjects];
    [self.session startRunning];
    
}

-(void) addBarGraph{
    
    //if graph object has not been initialized yet
    if(self.graphObject == nil) {
        //add graph object
        self.graphObject = [[BarGraphV1 alloc]init];
        self.graphObject.mainVC = self;
        [self.graphObject initializePlot: self.jsonCopy firstTime: YES];
    }
    //already been initialized so pass only new json
    else{
        [self.graphObject initializePlot:self.jsonCopy firstTime:NO];
    }
    
    //add button to save
    self.but= [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.but addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    //Di's addition - changing button
    [self.but setFrame:CGRectMake(75, 30, 235, 60)];
    [self.but setTitle:@"Add Food" forState:UIControlStateNormal];
    [self.but setTitleColor:[UIColor colorWithRed:0.18f green: 0.28f blue:0.38f alpha:1.0f] forState:UIControlStateNormal];
    [self.but setExclusiveTouch:YES];
    
    //make the button bigger
    [self.view addSubview:self.but];
    
}

-(void) addThreeDots{
    self.circle1 = [CAShapeLayer layer];
    [self.circle1 setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(self.view.bounds.size.width-70, self.view.bounds.size.height-550, 10, 10)] CGPath]];
    [self.view.layer addSublayer:self.circle1];
    
    self.circle2 = [CAShapeLayer layer];
    [self.circle2 setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(self.view.bounds.size.width-50, self.view.bounds.size.height-550, 10, 10)] CGPath]];
    [self.view.layer addSublayer:self.circle2];
    
    self.circle3 = [CAShapeLayer layer];
    [self.circle3 setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(self.view.bounds.size.width-30, self.view.bounds.size.height-550, 10, 10)] CGPath]];
    [self.view.layer addSublayer:self.circle3];
}

-(void)changeDotsColor: (int) viewNum{
    if(viewNum == 0){
        [self.circle1 setStrokeColor:[[UIColor blackColor] CGColor]];
        [self.circle1 setFillColor:[[UIColor whiteColor] CGColor]];
        
        [self.circle2 setStrokeColor:[[UIColor clearColor] CGColor]];
        [self.circle2 setFillColor:[[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.4f] CGColor]];
        
        [self.circle3 setStrokeColor:[[UIColor clearColor] CGColor]];
        [self.circle3 setFillColor:[[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.4f] CGColor]];
        
    }else if(viewNum == 1){
        [self.circle1 setStrokeColor:[[UIColor clearColor] CGColor]];
        [self.circle1 setFillColor:[[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.4f] CGColor]];
        
        [self.circle2 setStrokeColor:[[UIColor blackColor] CGColor]];
        [self.circle2 setFillColor:[[UIColor whiteColor] CGColor]];
        
        [self.circle3 setStrokeColor:[[UIColor clearColor] CGColor]];
        [self.circle3 setFillColor:[[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.4f] CGColor]];
        
    }else if(viewNum == 2){
        [self.circle1 setStrokeColor:[[UIColor clearColor] CGColor]];
        [self.circle1 setFillColor:[[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.4f] CGColor]];
        
        [self.circle2 setStrokeColor:[[UIColor clearColor] CGColor]];
        [self.circle2 setFillColor:[[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.4f] CGColor]];
        
        [self.circle3 setStrokeColor:[[UIColor blackColor] CGColor]];
        [self.circle3 setFillColor:[[UIColor whiteColor] CGColor]];
    }
    
}

//<<<<<<< END CUSTOM METHODS >>>>>>>


-(void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.previewLayer.frame = self.previewView.bounds;
}


//<<<<< ADISA'S CUSTOM METHODS >>>>>>>

-(void) setLabel{
    //initialize label and draw a rectangle around it as a frame
    //find the label into the frame
    self.label = [[UILabel alloc] init];
    self.label.frame = CGRectMake(0, self.view.bounds.size.height-80, self.view.bounds.size.width, 80);
    self.label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.label.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.65];
    self.label.textColor = [UIColor whiteColor];
    self.label.textAlignment = NSTextAlignmentCenter;
    [self.label setFont: [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:20]];
    self.label.text = @"Scan a food product's code to display valuable nutritional and diet information";
    self.label.lineBreakMode = NSLineBreakByWordWrapping;
    self.label.numberOfLines = 0;
    
    [self.view addSubview:self.label];
    [self.view bringSubviewToFront:self.label];
    /* NSLog(@"Set label in main is called!\n"); */
}

-(void) setImage: (NSMutableArray *)allergens {
    
    NSInteger x = 15;
    CGFloat y = self.view.bounds.size.height/2-165;
    int icon = 0; //count the number of icon on the page
    
    for (UIImageView *allergen in allergens) {
        
        /*change location of y*/
        [allergen setFrame:CGRectMake(x, y, 80, 80)];
        allergen.alpha = 0.0;
        
        [UIView animateWithDuration:2 animations:^{
            allergen.alpha = 1.0;
        }completion:^(BOOL finished) {}];
        
        //add to subview
        [[self view] addSubview:allergen];
        icon+=1;
        x+= 90; //move x axis
        
        if (icon % 4 == 0) {
            y+= 100; //if there's already 4 icons on that row
            x = 15; //reset x
        }
    }
}

-(void) removeIcon {
    
    for (UIImageView *allergen in self.picture) {
        [allergen removeFromSuperview];
    }
    
}

-(void) setProductName: (NSString *) name
{
    self.product = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height/2-310, self.view.bounds.size.width, 80)];
    
    //create a new label
    /*hardcoding the value for now */
    self.product.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.product setFont: [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:40]];
    self.product.text = name;
    self.product.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.product.textAlignment = NSTextAlignmentCenter;
    self.product.adjustsFontSizeToFitWidth = YES;
    
    /*initially set alpha to 0 - custom code*/
    self.product.alpha = 0;
    
    [self.view addSubview:self.product];
}

-(void) setAllergenLabel
{
    //create a new label
    /*hardcoding the value for now */
    
    //(self.mainVC.view.bounds.size.width-370, self.mainVC.view.bounds.size.height-565
     
    self.all_label = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-370, self.view.bounds.size.height-565, 350, 40)];
    self.all_label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.all_label setFont: [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:30]];
    self.all_label.text = @"This product is free of";
    
    
    /*additional code - set alpha to 0*/
    self.all_label.alpha = 0;
    
    [self.view addSubview:self.all_label];
    
}


-(void) blurBackground {
    
    //initialize imageview
    self.blur = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,self.view.bounds.size.width, self.view.bounds.size.height)];
    self.blur.alpha = 0; //set alpha to 0
    
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualView.frame = self.blur.bounds;
    
    [self.blur addSubview:visualView];
    [self.view addSubview:self.blur];
    
    //add animation block
    [UIView animateWithDuration:3.0
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.blur.alpha = 1.0; //blur background in
                     }
                     completion:nil];
}

-(void) drawLine
{
    /*initialize path*/
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 100)];
    [path addLineToPoint:CGPointMake(self.view.bounds.size.width, 100)];
    
    //create a CSShapeLayer that uses UIBezierPath
    
    self.shape = [CAShapeLayer layer];
    self.shape.path = [path CGPath];
    self.shape.lineWidth = 3.0;
    self.shape.strokeColor = [[UIColor blackColor]CGColor];
    self.shape.fillColor = [[UIColor blackColor]CGColor];
    
    [self.view.layer addSublayer:self.shape];
    
    CABasicAnimation *stroke = [CABasicAnimation animationWithKeyPath:@"opacity"];
    stroke.duration = 2.0;
    stroke.autoreverses = NO;
    stroke.removedOnCompletion = NO;
    stroke.fromValue = [NSNumber numberWithFloat:0.0];
    stroke.toValue = [NSNumber numberWithFloat:1.0];
    stroke.repeatCount = 0;
    stroke.fillMode = kCAFillModeBoth;
    
    [self.shape addAnimation:stroke forKey:@"opacityIN"];
}

/* method initiliazes sund url*/
 
 -(void) addSound
{
    NSLog(@"init sound");
    //construct URL to sound file
    NSString *path = [NSString stringWithFormat:@"%@/scanner.mp3",[[NSBundle mainBundle] resourcePath]];
    NSURL *sound = [NSURL fileURLWithPath:path];
    
    NSError *error = nil;
    
    //create audio player object and init with URL to sound
    self.audio = [[AVAudioPlayer alloc] initWithContentsOfURL:sound error:&error];
    //    NSLog(@"Error: %@", [error localizedDescription]);
}
//<<<<<<<<< END ADISA'S CUSTOM METHOD >>>>>>>>>>>>>


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
