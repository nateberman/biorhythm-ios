//
//  NATViewController.m
//  biorhythm
//
//  Created by Nate Berman on 5/12/14.
//  Copyright (c) 2014 Nate Berman. All rights reserved.
//

#import "NATViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface NATViewController () <AVAudioPlayerDelegate, UIGestureRecognizerDelegate>

// secure interface objects

@property (strong, nonatomic) IBOutlet UIView *mainView;

// splash
@property (weak, nonatomic) IBOutlet UIImageView *openingImage;
// title
@property (weak, nonatomic) IBOutlet UILabel *apptitle;
// logo
@property (weak, nonatomic) IBOutlet UIButton *logo;
- (IBAction)logoBtn:(id)sender;
// intro
@property (weak, nonatomic) IBOutlet UILabel *introLabel;
@property (weak, nonatomic) IBOutlet UILabel *introLabel2;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


// biorhythm images and labels
@property (nonatomic) BOOL indicatorsVisible;
@property (nonatomic) CGRect sideOriginalFrame;
// emotional
@property (weak, nonatomic) IBOutlet UIView *emotionalContainer;
@property (weak, nonatomic) IBOutlet UIButton *emotionalBtn;
- (IBAction)emotionalBtn:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *emotionalImage;
@property (weak, nonatomic) IBOutlet UILabel *emotionalLabel;
@property (weak, nonatomic) IBOutlet UIImageView *emotionalSide;
@property float emotionalScore;
// physical
@property (weak, nonatomic) IBOutlet UIView *physicalContainer;
@property (weak, nonatomic) IBOutlet UIButton *physicalBtn;
- (IBAction)physicalBtn:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *physicalImage;
@property (weak, nonatomic) IBOutlet UILabel *physicalLabel;
@property (weak, nonatomic) IBOutlet UIImageView *physicalSide;
@property float physicalScore;
// intellectual
@property (weak, nonatomic) IBOutlet UIView *intelContainer;
@property (weak, nonatomic) IBOutlet UIButton *intelBtn;
- (IBAction)intelBtn:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *intelImage;
@property (weak, nonatomic) IBOutlet UILabel *intelLabel;
@property (weak, nonatomic) IBOutlet UIImageView *intelSide;
@property float intelScore;

// panGestureRecognizer
- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer;

// datepicker
@property (nonatomic) BOOL datepickerVisible;
@property (weak, nonatomic) IBOutlet UIView *datePickerContainer;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
// date components
@property int year;
@property int month;
@property int day;

// bottom button
@property (weak, nonatomic) IBOutlet UIView *bottomButtonContainer;
@property (weak, nonatomic) IBOutlet UIButton *repickDateBtn;
- (IBAction)repickDateBtn:(id)sender;
// http request button
@property (weak, nonatomic) IBOutlet UIButton *httpGetWaveBtn;
- (IBAction)httpGetWaveBtn:(id)sender;
// http response data
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSDictionary *responseJSON;

- (void)showBottomBtn;


// sound properties
@property AVAudioPlayer *player;
@property (nonatomic) SystemSoundID bottomBtnSound;
@property (nonatomic) SystemSoundID first_top_oct;
@property (nonatomic) SystemSoundID fourth_top_oct;
@property (nonatomic) SystemSoundID seventh_top_oct;
@property (nonatomic) SystemSoundID eleventh_top_oct;
@property (nonatomic) SystemSoundID first_bot_oct;
@property (nonatomic) SystemSoundID fourth_bot_oct;
@property (nonatomic) SystemSoundID seventh_bot_oct;
@property (nonatomic) SystemSoundID eleventh_bot_oct;

@end

@implementation NATViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set up viewcontroller objects
    [self configureView];
    // set datepicker to show proper fields
    [self configureDatePicker];
    // prepare sound bank
    [self configureSounds];
    
    // officially launch app
    [self openingAnimation];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark CONFIGURATION
// configure our view
- (void)configureView {
    
    // hide title
    _apptitle.hidden = YES;
    
    // hide activityIndicator
    _activityIndicator.alpha = 0;
    _activityIndicator.hidden = YES;
    
    // construct and hide logo
    _logo.frame = CGRectMake(10, 10, 100, 44);
    [_logo setImage:[UIImage imageNamed:@"logo.png"] forState:UIControlStateNormal];
    _logo.alpha = 0;
    [_mainView insertSubview:_logo aboveSubview:_openingImage];
    
    // set openingImage
    if ([UIScreen mainScreen].bounds.size
        .height == 480 || [UIScreen mainScreen].bounds.size.height == 960) {
        NSLog(@"3.5inch screen");
        NSLog(@"%f", [UIScreen mainScreen].bounds.size.height);
        _openingImage.frame = CGRectMake(0, 0, 320, 480);
        _openingImage.image = [UIImage imageNamed:@"Default.png"];
        _datePickerContainer.frame = CGRectMake(0, 220, [UIScreen mainScreen].bounds.size.width, 200);
    }
    else {
        NSLog(@"4inch screen");
        NSLog(@"%f", [UIScreen mainScreen].bounds.size.height);
        _openingImage.frame = CGRectMake(0, 0, 640, 1136);
        _openingImage.image = [UIImage imageNamed:@"Biorhythm_splash_640x1136.png"];
        _datePickerContainer.frame = CGRectMake(0, 320, [UIScreen mainScreen].bounds.size.width, 200);
    }
    
    // intro text visibility
    _introLabel.alpha = 0;
    _introLabel.frame = CGRectMake(20, 95, 280, 44);
    _introLabel2.alpha = 0;
    _introLabel2.frame = CGRectMake(20, 139, 280, 44);
    
    // set biorhythm attribute initial states
    _indicatorsVisible = NO;
    _emotionalImage.alpha = 1;
    _emotionalLabel.alpha = 0;
    _emotionalBtn.alpha = 0;
    _emotionalSide.alpha = 0;
    _intelImage.alpha = 1;
    _intelLabel.alpha = 0;
    _intelBtn.alpha = 0;
    _intelSide.alpha = 0;
    _physicalImage.alpha = 1;
    _physicalLabel.alpha = 0;
    _physicalBtn.alpha = 0;
    _physicalSide.alpha = 0;
    _sideOriginalFrame = CGRectMake(140, 26, 50, 50);
    
    // position and hide the datePicker
    _datepickerVisible = NO;
    [_datePickerContainer setUserInteractionEnabled:NO];
    _datePickerContainer.alpha = 0;
    
    // bottom button
    [_bottomButtonContainer setUserInteractionEnabled:NO];
    _bottomButtonContainer.alpha = 0;
    _httpGetWaveBtn.alpha = 0;
    _repickDateBtn.alpha = 0;
    _bottomButtonContainer.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 55) / 2, [UIScreen mainScreen].bounds.size.height - 70 , 55, 55);
    
    // biorhythm indicators
    _emotionalContainer.frame = CGRectMake(-325, 65, 320, 102);
    _physicalContainer.frame = CGRectMake(-325, 170, 320, 102);
    _intelContainer.frame = CGRectMake(-325, 275, 320, 102);
}

// set our datepicker mode to year, month, day
- (void)configureDatePicker {
    
    _datePicker.datePickerMode = UIDatePickerModeDate;
    _datePicker.maximumDate = [NSDate date];
}

// set up our sound bank
- (void)configureSounds {
    
    // background music
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"background_drone" ofType:@"caf"];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    _player.numberOfLoops = -1; //infinite
    [_player setVolume:0.4];
    
    [_player play];
    
    // bottomBtn chime
    NSString *bottomBtn_path = [[NSBundle mainBundle]pathForResource:@"bottomBtn" ofType:@"caf"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:bottomBtn_path], &_bottomBtnSound);
    
    // biorhythm tones
    NSString *first_bot_path = [[NSBundle mainBundle]pathForResource:@"1_bot_oct" ofType:@"caf"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:first_bot_path], &_first_bot_oct);
    
    NSString *fourth_bot_path = [[NSBundle mainBundle]pathForResource:@"4_bot_oct" ofType:@"caf"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:fourth_bot_path], &_fourth_bot_oct);
    
    NSString *seventh_bot_path = [[NSBundle mainBundle]pathForResource:@"7_bot_oct" ofType:@"caf"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:seventh_bot_path], &_seventh_bot_oct);
    
    NSString *eleventh_bot_path = [[NSBundle mainBundle]pathForResource:@"11_bot_oct" ofType:@"caf"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:eleventh_bot_path], &_eleventh_bot_oct);
    
    NSString *first_top_path = [[NSBundle mainBundle]pathForResource:@"1_top_oct" ofType:@"caf"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:first_top_path], &_first_top_oct);
    
    NSString *fourth_top_path = [[NSBundle mainBundle]pathForResource:@"4_top_oct" ofType:@"caf"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:fourth_top_path], &_fourth_top_oct);
    
    NSString *seventh_top_path = [[NSBundle mainBundle]pathForResource:@"7_top_oct" ofType:@"caf"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:seventh_top_path], &_seventh_top_oct);
    
    NSString *eleventh_top_path = [[NSBundle mainBundle]pathForResource:@"11_top_oct" ofType:@"caf"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:eleventh_top_path], &_eleventh_top_oct);
}


#pragma mark URL REQUEST
// ensure our URL connection is receiving a response
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse");
    [_responseData setLength:0];
}

// ensure our URL connection did receive data, and store that data
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
    
}

// handle connection errors
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    // stop activityIndicator
    _activityIndicator.hidden = YES;
    _activityIndicator.alpha = 0;
    [_activityIndicator stopAnimating];
    
    // ensure we dont end up locked
    [self performSelector:@selector(showBottomBtn) withObject:self afterDelay:2];
    
     NSLog(@"didFailWithError");
     NSLog(@"Connection failed: %@", [error localizedDescription]);
    
     UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Connection Falure" message: [NSString stringWithFormat:@"The requested feature is inaccessible for the following reason: \n%@" ,[error localizedDescription]]  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
     [alert show];
}

// once our connection has completed convert the responseData to JSON and store it
// then showIndicators and updateBiorhythmImages
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    NSLog(@"Succeeded! Received %d bytes of data",[_responseData length]);
    
    // convert to JSON and store
    NSError *myError = nil;
    _responseJSON = [NSJSONSerialization JSONObjectWithData:_responseData options:NSJSONReadingMutableLeaves error:&myError];
    NSLog(@"%@", _responseJSON);
    
    // stop activityIndicator
    _activityIndicator.hidden = YES;
    _activityIndicator.alpha = 0;
    [_activityIndicator stopAnimating];
    
    // show indicators
    [self showIndicators];
    // update biorhythm images
    [self updateBiorhythmImages];
}


#pragma mark PROCESSING
// based on biorhythm scores update each rhythm's image color and label appropriately
- (void)updateBiorhythmImages {
    
    // iterate through our responseJSON dictionary
    for (id key in _responseJSON) {
        
        id value = _responseJSON[key];
        
        NSString *keyAsString = (NSString *)key; // ensures proper comparison
        NSString *valueAsString = (NSString *)value; // ensures proper conversion
        
        if ([keyAsString  isEqual: @"intellectual"]) {
            _intelScore = [valueAsString floatValue];
            [_intelBtn setBackgroundImage:[self imageForNumber:_intelScore] forState:UIControlStateNormal];
            _intelLabel.text =[NSString stringWithFormat:@"%.2f", _intelScore * 100 ];
        }
        else if ([keyAsString isEqual:@"physical"]) {
            _physicalScore = [valueAsString floatValue];
            [_physicalBtn setBackgroundImage:[self imageForNumber:_physicalScore] forState:UIControlStateNormal];
            _physicalLabel.text = [NSString stringWithFormat:@"%.2f", _physicalScore * 100];
        }
        else if ([keyAsString isEqual:@"emotional"]) {
            _emotionalScore = [valueAsString floatValue];
            [_emotionalBtn setBackgroundImage:[self imageForNumber:_emotionalScore] forState:UIControlStateNormal];
            _emotionalLabel.text = [NSString stringWithFormat:@"%.2f", _emotionalScore * 100];
        }
    }
}

// accept a number, return appropriate biorythm color image
- (UIImage*)imageForNumber:(float)number {
    NSLog(@"calculating color for number: %f", number);
     if (number < 0) {
         NSLog(@"redColor returned");
         return [UIImage imageNamed:@"redpad_102x102.png"];
     }
     else if (number > 0) {
         NSLog(@"yellowColor returned");
         return [UIImage imageNamed:@"yellowpad_102x102.png"];
     }
    NSLog(@"greenColor returned");
    return [UIImage imageNamed:@"greenpad_102x102.png"];
}


#pragma mark ANIMATIONS
// opening animation
- (void)openingAnimation {
    
    // hide opening image
    [UIView animateWithDuration:0.2
                          delay:0.5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         _openingImage.alpha = 0;
                     } completion:^(BOOL finished) {
                         // drop in logo
                         [UIView animateWithDuration:0.4
                                               delay:0.4
                                             options:UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              _logo.alpha = 1;
                                              _logo.frame = CGRectMake(10, 18, 100, 44);
                                          } completion:^(BOOL finished) {
                                              // bounce logo
                                              [UIView animateWithDuration:0.4
                                                                    delay:0
                                                                  options:UIViewAnimationOptionCurveEaseInOut
                                                               animations:^{
                                                                   _logo.frame = CGRectMake(10, 15, 100, 44);
                                                               } completion:^(BOOL finished) {
                                                                   // show intro
                                                               }];
                                              // datepicker
                                              [self showDatePicker];
                                          }];
                     }];
}

// show our datePickerContainer followed by showing our bottomBtn
- (void)showDatePicker {
    
    // set visibility tracker
    _datepickerVisible = YES;
    
    // 3.5inch screen
    if ([UIScreen mainScreen].bounds.size.height == 480 || [UIScreen mainScreen].bounds.size.height == 960) {
        // slide up and fade in
        [UIView animateWithDuration:0.2
                              delay:1
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                                _datePickerContainer.frame = CGRectMake(0, 215, [UIScreen mainScreen].bounds.size.width, 200);
                                _datePickerContainer.alpha = 1;
                         }
                        // bounce
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.4
                                                   delay:0
                                                 options:UIViewAnimationOptionCurveEaseInOut
                                              animations:^{
                                                  _datePickerContainer.frame = CGRectMake(0, 220, [UIScreen mainScreen].bounds.size.width, 200);
                                          } completion:^(BOOL finished) {
                                              // show button
                                              [self showBottomBtn];
                                          }];
                     }];
    }
    // 4inch screen
    else {
        // slide up and fade in
        [UIView animateWithDuration:0.2
                              delay:0.5
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             _datePickerContainer.frame = CGRectMake(0, 315, [UIScreen mainScreen].bounds.size.width, 200);
                             _datePickerContainer.alpha = 1;
                         }
                        // bounce
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.4
                                                   delay:0
                                                 options:UIViewAnimationOptionCurveEaseInOut
                                              animations:^{
                                                  _datePickerContainer.frame = CGRectMake(0, 320, [UIScreen mainScreen].bounds.size.width, 200);
                                              } completion:^(BOOL finished) {
                                                  // show button
                                                  [self showBottomBtn];
                                              }];
                         }];
    }
    
    // enable interaction
    [_datePickerContainer setUserInteractionEnabled:YES];
    
}

// hide bottomBtn, hide our datePickerContainer, show bottomBtn
- (void)hideDatePicker {
    
    // disable picker
    [_datePickerContainer setUserInteractionEnabled:NO];
    
    // set visibility tracker
    _datepickerVisible = NO;
    
    [self hideIntro];
    
    // 3.5inch screen
    if ([UIScreen mainScreen].bounds.size.height == 960 || [UIScreen mainScreen].bounds.size.height == 480) {
    // bounce up
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _datePickerContainer.frame = CGRectMake(0, 215, [UIScreen mainScreen].bounds.size.width, 200);
                         [_datePickerContainer setUserInteractionEnabled:YES];
                     }
                    // slide and hide
                     completion:^(BOOL finished) {
                         
                         // hide bottom button
                         [self hideBottomBtn];
                         
                         [UIView animateWithDuration:0.2
                                               delay:0
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              _datePickerContainer.frame = CGRectMake(0, 220, [UIScreen mainScreen].bounds.size.width, 200);
                                              _datePickerContainer.alpha = 0;
                                          } completion:^(BOOL finished) {}];
                     }];
    }
    // 4inch screen
    else {
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             _datePickerContainer.frame = CGRectMake(0, 315, [UIScreen mainScreen].bounds.size.width, 200);
                             [_datePickerContainer setUserInteractionEnabled:YES];
                         }
                        // slide and hide
                         completion:^(BOOL finished) {
                             
                             // hide bottom button
                             [self hideBottomBtn];
                             
                             [UIView animateWithDuration:0.2
                                                   delay:0
                                                 options:UIViewAnimationOptionCurveEaseInOut
                                              animations:^{
                                                  _datePickerContainer.frame = CGRectMake(0, 320, [UIScreen mainScreen].bounds.size.width, 200);
                                                  _datePickerContainer.alpha = 0;
                                              } completion:^(BOOL finished) {
                                                  //
                                              }];
                         }];
    }
}

// animate bottom button on to view
- (void)showBottomBtn {
    
    NSLog(@"datepicker visible: %hhd", _datepickerVisible);
    
    // set bottom button
    if (_datepickerVisible == 1) {
        [_httpGetWaveBtn setUserInteractionEnabled:YES];
        _httpGetWaveBtn.alpha = 1;
        [_repickDateBtn setUserInteractionEnabled:NO];
        _repickDateBtn.alpha = 0;
    }
    else {
        [_repickDateBtn setUserInteractionEnabled:YES];
        _repickDateBtn.alpha = 1;
        [_httpGetWaveBtn setUserInteractionEnabled:NO];
        _httpGetWaveBtn.alpha = 0;
    }
    
    // ensure frame is proper before animation
    _bottomButtonContainer.alpha = 0;
    _bottomButtonContainer.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 55) / 2, [UIScreen mainScreen].bounds.size.height - 70 , 55, 55);
    
    // show and grow
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         _bottomButtonContainer.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 55) / 2, [UIScreen mainScreen].bounds.size.height - 80 , 55, 55);
                         _bottomButtonContainer.alpha = 1;
                     } completion:^(BOOL finished) {
                         // bounce
                         [UIView animateWithDuration:0.4
                                               delay:0
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              _bottomButtonContainer.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 55) / 2, [UIScreen mainScreen].bounds.size.height - 70 , 55, 55);
                                          } completion:^(BOOL finished) {
                                              // set interaction
                                              [_bottomButtonContainer setUserInteractionEnabled:YES];
                                          }];
                     }];
}

// animate bottom button off of view
- (void)hideBottomBtn {
    
    // disable interaction
    [_bottomButtonContainer setUserInteractionEnabled:NO];
    
    // bouce up
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         _bottomButtonContainer.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 55) / 2, [UIScreen mainScreen].bounds.size.height - 80 , 55, 55);
                     }
                     completion:^(BOOL finished) {
                         // slide and hide
                         [UIView animateWithDuration:0.4
                                               delay:0
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              _bottomButtonContainer.alpha = 0;
                                              _bottomButtonContainer.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 55) / 2, [UIScreen mainScreen].bounds.size.height - 70 , 55, 55);
                                          } completion:^(BOOL finished) {}];
                     }];
}

// animate biorhythm indicators on to view, show bottomBtn
- (void)showIndicators {
    
    // setup
    _emotionalSide.frame = CGRectMake(0, 26, 50, 50);
    _physicalSide.frame = CGRectMake(0, 26, 50, 50);
    _emotionalSide.frame = CGRectMake(0, 26, 50, 50);
    
    // make it feel good
    [self performSelector:@selector(showBottomBtn) withObject:self afterDelay:1];
    
    // step and slide
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         _emotionalContainer.frame = CGRectMake(0, 65, 320, 102);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.3
                                               delay:0
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              _emotionalContainer.frame = CGRectMake(-4, 65, 320, 102);
                                              _physicalContainer.frame = CGRectMake(-90, 160, 320, 102);
                                          } completion:^(BOOL finished) {
                                              [UIView animateWithDuration:0.3
                                                                    delay:0
                                                                  options:UIViewAnimationOptionCurveEaseInOut
                                                               animations:^{
                                                                   _physicalContainer.frame = CGRectMake(-94, 160, 320, 102);
                                                                   _intelContainer.frame = CGRectMake(-20, 275, 320, 102);
                                                               } completion:^(BOOL finished) {
                                                                   [UIView animateWithDuration:0.3
                                                                                         delay:0
                                                                                       options:UIViewAnimationOptionCurveEaseInOut
                                                                                    animations:^{
                                                                                        _intelContainer.frame = CGRectMake(-24, 275, 320, 102);
                                                                                    } completion:^(BOOL finished) {
                                                                                        // color em up
                                                                                        [self colorIndicators];
                                                                                    }];
                                                               }];
                                          }];
                     }];
    
    _indicatorsVisible = YES;
    [self performSelector:@selector(showSides) withObject:self afterDelay:1];
    
}

// animate biorhythm indicators off of view
- (void)hideIndicators {
    
    if (_indicatorsVisible) {
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             _emotionalLabel.alpha = 0;
                             _emotionalContainer.frame = CGRectMake(0, 65, 320, 102);
                         } completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.3
                                                   delay:0
                                                 options:UIViewAnimationOptionCurveEaseInOut
                                              animations:^{
                                                  _physicalLabel.alpha = 0;
                                                  _emotionalContainer.frame = CGRectMake(-325, 65, 320, 102);
                                                  _physicalContainer.frame = CGRectMake(-90, 160, 320, 102);
                                              } completion:^(BOOL finished) {
                                                  [UIView animateWithDuration:0.3
                                                                        delay:0
                                                                      options:UIViewAnimationOptionCurveEaseInOut
                                                                   animations:^{
                                                                       _intelLabel.alpha = 0;
                                                                       _physicalContainer.frame = CGRectMake(-325, 160, 320, 102);
                                                                       _intelContainer.frame = CGRectMake(-20, 275, 320, 102);
                                                                   } completion:^(BOOL finished) {
                                                                       [UIView animateWithDuration:0.3
                                                                                             delay:0
                                                                                           options:UIViewAnimationOptionCurveEaseInOut
                                                                                        animations:^{
                                                                                            _intelContainer.frame = CGRectMake(-325, 274, 320, 102);
                                                                                        } completion:^(BOOL finished) {
                                                                                            // hide buttons
                                                                                            _emotionalBtn.alpha = 0;
                                                                                            _physicalBtn.alpha = 0;
                                                                                            _intelBtn.alpha = 0;
                                                                                            
                                                                                            _emotionalSide.alpha = 0;
                                                                                            _physicalSide.alpha = 0;
                                                                                            _intelSide.alpha = 0;
                                                                                        }];
                                                                   }];
                                              }];
                         }];
        }
    _indicatorsVisible = NO;
}

// add biorhythmic color to the indicators
- (void)colorIndicators {
    
    // animate color on to indicators
    [UIView animateWithDuration:0.1
                          delay:0
                        options:NO
                     animations:^{
                         _emotionalBtn.alpha = 1;
                         _emotionalLabel.alpha = 1;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.1
                                               delay:0.1
                                             options:NO
                                          animations:^{
                                              _physicalBtn.alpha = 1;
                                              _physicalLabel.alpha = 1;
                                          } completion:^(BOOL finished) {
                                              [UIView animateWithDuration:0.1
                                                                    delay:0.1
                                                                  options:NO
                                                               animations:^{
                                                                   _intelBtn.alpha = 1;
                                                                   _intelLabel.alpha = 1;
                                                               } completion:^(BOOL finished) {
                                                                   //
                                                               }];
                                          }];
                     }];
}

// bounce an indicator button
- (void)bounceButtion:(UIButton *)button {
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut animations:^{
                            button.frame = CGRectInset(button.frame, 10, 10);
                        } completion:^(BOOL finished) {
                            [UIView animateWithDuration:0.2
                                                  delay:0
                                                options:UIViewAnimationOptionCurveEaseInOut
                                             animations:^{
                                                 button.frame = CGRectInset(button.frame, -10, -10);
                                             } completion:^(BOOL finished) {
                                                 //
                                             }];
                        }];
}

// show intro
- (void)showIntro {
    [UIView animateWithDuration:0.4
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         _introLabel.frame = CGRectMake(20, 100, 280, 44);
                         _introLabel.alpha = 1;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.4
                                               delay:0
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              _introLabel2.frame = CGRectMake(20, 144, 280, 44);
                                              _introLabel2.alpha = 1;
                                          } completion:^(BOOL finished) {
                                              //
                                          }];
                     }];
}

// hide intro
- (void)hideIntro {
    [UIView animateWithDuration:0.4
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         _introLabel.frame = CGRectMake(20, 95, 280, 44);
                         _introLabel.alpha = 0;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.4
                                               delay:0
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              _introLabel2.frame = CGRectMake(20, 139, 280, 44);
                                              _introLabel2.alpha = 0;
                                          } completion:^(BOOL finished) {
                                              //
                                          }];
                     }];
}

// show indicator asides
- (void)showSides {
    
    // setup
    _emotionalSide.frame = CGRectMake(0, 26, 50, 50);
    _physicalSide.frame = CGRectMake(0, 26, 50, 50);
    _emotionalSide.frame = CGRectMake(0, 26, 50, 50);
    
    // step and slide
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         _emotionalSide.frame = CGRectMake(150, 26, 50, 50);
                         _emotionalSide.alpha = 1;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.3
                                               delay:0
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              _emotionalSide.frame = CGRectMake(140, 26, 50, 50);
                                              _physicalSide.frame = CGRectMake(150, 26, 50, 50);
                                              _physicalSide.alpha = 1;
                                          } completion:^(BOOL finished) {
                                              [UIView animateWithDuration:0.3
                                                                    delay:0
                                                                  options:UIViewAnimationOptionCurveEaseInOut
                                                               animations:^{
                                                                   _physicalSide.frame = CGRectMake(140, 26, 50, 50);
                                                                   _intelSide.frame = CGRectMake(150, 26, 50, 50);
                                                                   _intelSide.alpha = 1;
                                                               } completion:^(BOOL finished) {
                                                                   [UIView animateWithDuration:0.4
                                                                                         delay:0
                                                                                       options:UIViewAnimationOptionCurveEaseInOut
                                                                                    animations:^{
                                                                                        _intelSide.frame = CGRectMake(140, 26, 50, 50);
                                                                                    } completion:^(BOOL finished) {
                                                                                        //
                                                                                    }];
                                                               }];
                                          }];
                     }];
}


#pragma mark ACTIONS
// submit a birthdate, hide the datePickerContainer, make http request, show biorhythm indicators
- (IBAction)httpGetWaveBtn:(id)sender {
    
    AudioServicesPlaySystemSound(_bottomBtnSound);
    
    // capture datepicker date
    NSDate *dateFromPicker = [_datePicker date];
    // configure calendar
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    // specify the units we will be accessing
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    // specify our date components
    NSDateComponents *components = [calendar components: unitFlags fromDate: dateFromPicker];
    // extract date integer values
    _year = [components year];
    _month = [components month];
    _day = [components day];
    
    _responseData = [NSMutableData data];
    
    // format our url request string
    // originally there was a problem with days and months that began with 0 not being recognized.
    // to fix the trouble i updated my urlconf with a more robust regex
    NSString *strURL = [NSString stringWithFormat:@"http://glacial-cliffs-4549.herokuapp.com/makewave/%d/%d/%d", _month, _day, _year];
    
    // generate the URL request
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:strURL]];
    
    // create timing so hiding datePicker and bottomBtn feels good
    [UIView animateWithDuration:0.2
                          delay:0
                        options:NO
                     animations:^{
                         [self hideDatePicker];
                     } completion:^(BOOL finished) {
                         
                         // create the URL connection
                         [UIView animateWithDuration:0.2
                                               delay:0
                                             options:NO
                                          animations:^{
                                              NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
                                              NSLog(@"%@", connection);
                                          } completion:^(BOOL finished) {
                                              
                                              // give our activity indicator room to think about showing or not
                                              [UIView animateWithDuration:0.3
                                                                    delay:0.3
                                                                  options:NO
                                                               animations:^{
                                                                   // start activity indicator
                                                                   _activityIndicator.hidden = NO;
                                                                   [_activityIndicator startAnimating];
                                                                   _activityIndicator.alpha = 1;
                                                                   
                                                               } completion:^(BOOL finished) {
                                                                   //
                                                               }];
                                          }];
                     }];
}

// hide/show bottom button and bring our datepicker back
- (IBAction)repickDateBtn:(id)sender {
    
    AudioServicesPlaySystemSound(_bottomBtnSound);
    
    [_bottomButtonContainer setUserInteractionEnabled:NO];
    
    [self hideBottomBtn];
    [self hideIndicators];
    [self performSelector:@selector(showDatePicker) withObject:self afterDelay:.8];
}

// animate and sound
- (IBAction)emotionalBtn:(id)sender {
    [self bounceButtion:_emotionalBtn];
    [self playSoundForScore:_emotionalScore];
}

//animate and sound
- (IBAction)physicalBtn:(id)sender {
    [self bounceButtion:_physicalBtn];
    [self playSoundForScore:_physicalScore];
}

// animate and sound
- (IBAction)intelBtn:(id)sender {
    [self bounceButtion:_intelBtn];
    [self playSoundForScore:_intelScore];
}

// show useful information about Biorhythm
- (IBAction)logoBtn:(id)sender {
    
    if (_datepickerVisible) {
        AudioServicesPlaySystemSound(_bottomBtnSound);
        [self showIntro];
    }
    else {
        AudioServicesPlaySystemSound(_bottomBtnSound);
        [self hideBottomBtn];
        [self hideIndicators];
        [self performSelector:@selector(showDatePicker) withObject:self afterDelay:.8];
        [self performSelector:@selector(showIntro) withObject:self afterDelay:1];
    }
}

// when an indicator is tapped play appropriate sound
- (void)playSoundForScore:(float)score {
    
    if (score <= -.75) AudioServicesPlaySystemSound(_first_bot_oct); //first bot oct
    else if (score <= -0.5 && score > -0.75) AudioServicesPlaySystemSound(_fourth_bot_oct); //fourth bot oct
    else if (score <= -0.25 && score > -.5) AudioServicesPlaySystemSound(_seventh_bot_oct); //seventh bot oct
    else if (score < 0 && score > -0.25) AudioServicesPlaySystemSound(_eleventh_bot_oct); //eleventh bot oct
    else if (score > 0 && score <= 0.25) AudioServicesPlaySystemSound(_first_top_oct); // first top oct
    else if (score > 0.25 && score <= 0.5) AudioServicesPlaySystemSound(_fourth_top_oct); //fourth top oct
    else if (score > 0.5 && score <= 0.75) AudioServicesPlaySystemSound(_seventh_top_oct); //seventh top oct
    else if (score > 0.75) AudioServicesPlaySystemSound(_eleventh_top_oct); //eleventh top oct
    
    else AudioServicesPlaySystemSound(_first_bot_oct); // score 0 triumph sound
}

// play the inverse octave for the sound sent
- (void)playInverseSoundForScore:(float)score {
    
    if (score <= -.75) AudioServicesPlaySystemSound(_first_top_oct); //first bot oct
    else if (score <= -0.5 && score > -0.75) AudioServicesPlaySystemSound(_fourth_top_oct); //fourth bot oct
    else if (score <= -0.25 && score > -.5) AudioServicesPlaySystemSound(_seventh_top_oct); //seventh bot oct
    else if (score < 0 && score > -0.25) AudioServicesPlaySystemSound(_eleventh_top_oct); //eleventh bot oct
    else if (score > 0 && score <= 0.25) AudioServicesPlaySystemSound(_first_bot_oct); // first top oct
    else if (score > 0.25 && score <= 0.5) AudioServicesPlaySystemSound(_fourth_bot_oct); //fourth top oct
    else if (score > 0.5 && score <= 0.75) AudioServicesPlaySystemSound(_seventh_bot_oct); //seventh top oct
    else if (score > 0.75) AudioServicesPlaySystemSound(_eleventh_bot_oct); //eleventh top oct
    
    else AudioServicesPlaySystemSound(_first_bot_oct); // score 0 triumph sound
}

// restart audio after interruption if there is one
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags {
    [player play];
}


#pragma mark GESTURE CONTROLS
// panning touch control for biorhythm attribute Sides
- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint originalOrigin = CGPointMake(_sideOriginalFrame.origin.x, _sideOriginalFrame.origin.y);
    
    CGPoint translation = [recognizer translationInView:self.view];
    
    if (recognizer.view.frame.origin.x > 155) {
        recognizer.view.frame = CGRectMake(155, 26, recognizer.view.frame.size.width, recognizer.view.frame.size.height);
        recognizer.enabled = NO;
    }
    
    else {
        
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y);
    }
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
    // handle gesture end
    if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        
        [UIView animateWithDuration: 0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             NSLog(@"recognizer: %@", recognizer);
                             recognizer.view.frame = CGRectMake(originalOrigin.x + 15, originalOrigin.y, recognizer.view.frame.size.width, recognizer.view.frame.size.height);
                         } completion:^(BOOL finished){
                             //
                             if (recognizer.view == _emotionalSide) {
                                 [self bounceButtion:_emotionalBtn];
                                 [self playInverseSoundForScore:_emotionalScore];
                             }
                             else if (recognizer.view == _physicalSide) {
                                 [self bounceButtion:_physicalBtn];
                                 [self playInverseSoundForScore:_physicalScore];
                             }
                             else if (recognizer.view == _intelSide) {
                                 [self bounceButtion:_intelBtn];
                                 [self playInverseSoundForScore:_intelScore];
                             }
                             
                             [UIView animateWithDuration:0.4
                                                   delay:0
                                                 options:UIViewAnimationOptionCurveEaseInOut
                                              animations:^{
                                                  recognizer.view.frame = CGRectMake(originalOrigin.x, originalOrigin.y, recognizer.view.frame.size.width, recognizer.view.frame.size.height);
                                              } completion:^(BOOL finished) {
                                                  //
                                                  recognizer.enabled = YES;
                                              }];
                         }];
        
    }
}

@end
