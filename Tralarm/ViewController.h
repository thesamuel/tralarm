//
//  ViewController.h
//  Tralarm
//
//  Created by Sam Gehman on 5/17/16.
//  Copyright © 2016 Sam Gehman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "NSString+URLEncoding.h"
@import EventKit;
@import AVFoundation;

@interface ViewController : UIViewController<CLLocationManagerDelegate>

@property (strong, nonatomic) NSTimer *alarmTimer;
@property (strong,nonatomic) UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITextField *timeField;
@property (weak, nonatomic) IBOutlet UILabel *myLabel;

// The database with calendar events and reminders
@property (strong, nonatomic) EKEventStore *eventStore;

// Indicates whether app has access to event store.
@property (nonatomic) BOOL isAccessToEventStoreGranted;

@property (copy, nonatomic) NSArray *reminders;

@property (strong, nonatomic) EKCalendar *calendar;
@property (strong, nonatomic) AVAudioPlayer *backgroundMusicPlayer;
- (IBAction)testFireButton:(id)sender;

@property (strong, nonatomic) AVSpeechSynthesizer *synthesizer;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UITextField *addressBox;
- (IBAction)mapsTest:(id)sender;

@property (strong, nonatomic) NSMutableArray *nprAudioData;
- (IBAction)downloadAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *nprLabel;
@property (strong, nonatomic) AVQueuePlayer *player;
@property (strong, nonatomic) NSURL *directoryURL;
- (IBAction)weatherAction:(id)sender;
@property (strong, nonatomic) CLLocation *location;


@end

