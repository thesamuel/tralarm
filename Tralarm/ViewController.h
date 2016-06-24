//
//  ViewController.h
//  Tralarm
//
//  Created by Sam Gehman on 5/17/16.
//  Copyright © 2016 Sam Gehman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlarmModel.h"
#import "SpeechModel.h"
#import "CommuteModel.h"
#import "CalendarModel.h"
#import "WeatherModel.h"
#import "RadioModel.h"

@interface ViewController : UIViewController<AlarmModelDelegate, CommuteModelDelegate>

// Models
@property (strong,nonatomic) AlarmModel *alarm;
@property (strong, nonatomic) SpeechModel *speaker;
@property (strong, nonatomic) CommuteModel *commuter;
@property (strong, nonatomic) CalendarModel *calendar;
@property (strong, nonatomic) WeatherModel *weather;
@property (strong, nonatomic) RadioModel *radio;

// Views
@property (strong,nonatomic) UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITextField *timeField;
@property (weak, nonatomic) IBOutlet UILabel *myLabel;
@property (weak, nonatomic) IBOutlet UITextField *addressBox;
@property (weak, nonatomic) IBOutlet UILabel *nprLabel;

// Buttons
- (IBAction)testFireButton:(id)sender;
- (IBAction)commuteAction:(id)sender;
- (IBAction)weatherAction:(id)sender;
- (IBAction)downloadAction:(id)sender;

// Delegate Methods
- (void)changeTimeFieldTo:(NSDate*)alarmDate withFormat:(NSDateFormatter*)dateFormat;
- (void)speakCommuteDuration:(NSUInteger)duration;
- (void)speakWeather:(NSDictionary*)weatherDictionary;
- (void)updateAlarmButtonTitle:(NSString*)title;

@end
