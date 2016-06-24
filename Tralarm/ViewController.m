//
//  ViewController.m
//  Tralarm
//
//  Created by Sam Gehman on 5/17/16.
//  Copyright © 2016 Sam Gehman. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _alarm = [AlarmModel new];
    _alarm.delegate = self;
    
    _commuter = [CommuteModel new];
    _commuter.delegate = self;
    
    _speaker = [SpeechModel new];
    
    _calendar = [CalendarModel new];
    
    [self setupDatePicker];
}

- (void)setupDatePicker {
    _datePicker = [[UIDatePicker alloc] init];
    _datePicker.date = [NSDate date];
    _datePicker.datePickerMode = UIDatePickerModeTime;
    [_datePicker addTarget:self action:@selector(alarmSet:) forControlEvents:UIControlEventValueChanged];
    [_timeField setInputView:_datePicker];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

#pragma mark - Alarm
- (IBAction)testFireButton:(id)sender {
    [self alarmFire:nil];
}

- (void)alarmSet:(UIDatePicker *)datePicker {
    NSDate *alarmDate = datePicker.date;
    [_alarm alarmSet:alarmDate];
}

- (void)changeTimeFieldTo:(NSDate*)alarmDate withFormat:(NSDateFormatter*)dateFormat {
    _timeField.text = [NSString stringWithFormat:@"%@",[dateFormat  stringFromDate:alarmDate]];
}

- (void)updateAlarmButtonTitle:(NSString*)title {
    // Create a button first!
}

- (void) alarmFire:(NSTimer *)timer {
    _myLabel.text = @"ALARM";
    
    NSString *remindersString = [_calendar stringFromReminders];
    [_speaker speakString:remindersString];
    
    [self commuteAction:nil];
}

#pragma mark - Commute
- (IBAction)commuteAction:(id)sender {
    [_commuter calculateCommuteWithAddress:_addressBox.text];
}

- (void)speakCommuteDuration:(NSUInteger)duration {
    NSString *durationString = [NSString stringWithFormat: @"%ld", (long)duration];
    NSArray *speechArray = [[NSArray alloc] initWithObjects:@"Your commute time will take approximately: ", durationString, @"minutes", nil];
    [_speaker speakString:[speechArray componentsJoinedByString:@" "]];
}

#pragma mark - Weather
- (IBAction)weatherAction:(id)sender {
    [_weather weather];
}

- (void)speakWeather:(NSDictionary*)weatherDictionary {
    NSArray *speechArray = @[@"It's about", [weatherDictionary objectForKey:@"temp"],
                             @"degrees Fahrenheit and", [weatherDictionary objectForKey:@"desc"],
                             @"here in beautiful", [weatherDictionary objectForKey:@"name"],
                             @",and tonight it will be about", [weatherDictionary objectForKey:@"tonightTemp"],
                             @"degrees."];
    [_speaker speakString:[speechArray componentsJoinedByString:@" "]];
}

#pragma mark - Radio
- (IBAction)downloadAction:(id)sender {
    [_radio playNPR];
}

// TODO: Figure out why I put this here
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
