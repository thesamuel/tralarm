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
    
    // Initialize Voice Synthesizer
    _synthesizer = [[AVSpeechSynthesizer alloc] init];
    
    // Setup Reminders
    [self updateAuthorizationStatusToAccessEventStore];
    [self fetchReminders];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fetchReminders)
                                                 name:EKEventStoreChangedNotification object:nil];
    
    // Setup Date Picker
    _datePicker = [[UIDatePicker alloc] init];
    _datePicker.date = [NSDate date];
    _datePicker.datePickerMode = UIDatePickerModeTime;
    [_datePicker addTarget:self action:@selector(alarmSet:) forControlEvents:UIControlEventValueChanged];
    [_timeField setInputView:_datePicker];
    
    //Setup Location Manager
    _locationManager = [[CLLocationManager alloc]init];
    _locationManager.delegate = self;
    [_locationManager requestWhenInUseAuthorization];
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [_locationManager startUpdatingLocation];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

- (void)alarmSet:(UIDatePicker *)datePicker {
    NSDate *alarmDate = datePicker.date;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.timeStyle = NSDateFormatterShortStyle;
    _timeField.text = [NSString stringWithFormat:@"%@",[dateFormat  stringFromDate:alarmDate]];
    
    NSCalendar *calendar = NSCalendar.currentCalendar;
    NSCalendarUnit preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute);
    NSDateComponents *components = [calendar components:preservedComponents fromDate:alarmDate];
    alarmDate = [calendar dateFromComponents:components];
    
    if( [alarmDate timeIntervalSinceDate:[NSDate date]] < 0 ) {
        NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
        dayComponent.day = 1;
        NSCalendar *theCalendar = [NSCalendar currentCalendar];
        alarmDate = [theCalendar dateByAddingComponents:dayComponent toDate:alarmDate options:0];
        NSLog(@"Alarm moved to next day: %@ ...", alarmDate);
    }
    
    NSTimer *alarmTimer = [[NSTimer alloc] initWithFireDate:alarmDate interval:0 target:self selector:@selector(alarmFire:) userInfo:nil repeats:NO];
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    [runner addTimer:alarmTimer forMode: NSDefaultRunLoopMode];
    
    /* Timer Debugging
     NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
     formatter.dateStyle = NSDateFormatterLongStyle;
     formatter.timeStyle = NSDateFormatterLongStyle;
     NSLog(@"Todays date is %@",[formatter stringFromDate:[NSDate date]]);
     NSLog(@"The other date is %@",[formatter stringFromDate:alarmDate]);
    */
}

- (void) cancelAlarm {
    [_alarmTimer invalidate];
    _alarmTimer = nil;
}

- (void) alarmFire:(NSTimer *)timer {
    _myLabel.text = @"ALARM";
    
    NSInteger count = 1;
    for (EKReminder *r in _reminders) {
        
        NSString *countString = [NSString stringWithFormat: @"%ld", (long)count];
        
        if (count % 10 == 1) {
            countString = [countString stringByAppendingString:@"st reminder: "];
        } else if (count % 10 == 2) {
            countString = [countString stringByAppendingString:@"nd reminder: "];
        } else if (count % 10 == 3) {
            countString = [countString stringByAppendingString:@"rd reminder: "];
        } else {
            countString = [countString stringByAppendingString:@"th reminder: "];
        }
        
        NSString *speechString = [countString stringByAppendingString:r.title];
        AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:speechString];
        utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
        
        [_synthesizer speakUtterance:utterance];
        count++;
    }
    
    [self commuteDataRequest];
    
    /* Unfinished music feature
     self.backgroundMusicPlayer = [[AVAudioPlayer alloc]
     initWithContentsOfURL:backgroundMusicURL error:&error];
     [self.backgroundMusicPlayer prepareToPlay];
     [self.backgroundMusicPlayer play];
    */
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"%@", [locations lastObject]);
}

- (IBAction)mapsTest:(id)sender {
    [self commuteDataRequest];
}

- (IBAction)testFireButton:(id)sender {
    [self alarmFire:nil];
}

- (void)commuteDataRequest {
    CLLocation *location = [_locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    
    NSString *coordinates = [NSString stringWithFormat:@"%@,%@",
                             [NSString stringWithFormat:@"%f", coordinate.latitude],
                             [NSString stringWithFormat:@"%f", coordinate.longitude]];
    NSLog(@"Coordinates=%@", coordinates);
    
    NSString *encodedQuery = [_addressBox.text stringByAddingPercentEncodingForFormData:YES];
    NSLog(@"Encoded Query=%@", encodedQuery);
    
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=%@&destinations=%@&key=AIzaSyD-X_DhihbCFfMav28qrx8ulRr-Q8Y_ISI", coordinates, encodedQuery];
    NSLog(@"URL String=%@", urlString);
    
    NSURL *url = [NSURL URLWithString: urlString];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData* data = [NSData dataWithContentsOfURL:url];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
}

- (void)fetchedData:(NSData *)responseData {
    
    /* JSON Dump Debug
     NSString *jsonString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
     NSLog(@"Response JSON=%@", jsonString);
    */
    
    NSDictionary *json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:NSJSONReadingMutableContainers
                          error:nil];
    
    NSArray *rows = json[@"rows"];
    NSDictionary *row = rows[0];
    NSArray *elements = row[@"elements"];
    NSDictionary *element = elements[0];
    NSDictionary *duration = element[@"duration"];
    NSInteger durationInt = (NSInteger) roundf([duration[@"value"] integerValue] / 60.0);
    NSLog(@"duration=%zd", durationInt);
    
    NSString *durationString = [NSString stringWithFormat: @"%ld", (long)durationInt];
    NSArray *speechArray = [[NSArray alloc] initWithObjects:@"Your commute time will take approximately: ", durationString, @"minutes", nil];
    NSString *speechString = [speechArray componentsJoinedByString:@" "];
    
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:speechString];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
    
    [_synthesizer speakUtterance:utterance];
    
}

- (void)nprApiRequest {
    NSURL *url = [NSURL URLWithString: @"https://api.npr.org/query?id=3&output=JSON&apiKey=MDIwMDE5ODU5MDE0NjM3MzYyMDc3NmE4MQ000"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData* nprData = [NSData dataWithContentsOfURL:url];
        [self performSelectorOnMainThread:@selector(nprFetchedData:) withObject:nprData waitUntilDone:YES];
    });
}

- (void)nprFetchedData:(NSData *)responseData {
    
    NSDictionary *json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:NSJSONReadingMutableContainers
                          error:nil];
    
    /* JSON Dump Debug
     NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
     NSLog(@"NPR JSON=%@", jsonString);
     */
    
    NSMutableArray *audioFiles = [[NSMutableArray alloc] init];
    
    NSDictionary *list = json[@"list"];
    NSArray *stories = list[@"story"];
    for (NSDictionary *story in stories) {
        NSArray *audioArray = story[@"audio"];
        NSDictionary *audioObject = audioArray[0];
        NSDictionary *formatObject = audioObject[@"format"];
        NSArray *mp3Array = formatObject[@"mp3"];
        NSDictionary *mp3Object = mp3Array[0];
        NSString *mp3URL = mp3Object[@"$text"];
        NSLog(@"NPR MP3 URL:%@", mp3URL);
        [audioFiles addObject:mp3URL];
    }
    /*
     NSMutableArray *audioDataArray = [[NSMutableArray alloc] init];
     for (NSString *audioFileString in audioFiles) {
     NSData* data = [NSData dataWithContentsOfURL: [NSURL URLWithString: audioFileString]];
     [audioDataArray addObject:data];
     }
     */
    
    _nprAudioData = audioFiles;
    _nprLabel.text = @"LOADED";
}

- (EKEventStore *)eventStore {
    if (!_eventStore) {
        _eventStore = [[EKEventStore alloc] init];
    }
    return _eventStore;
}

- (void) updateAuthorizationStatusToAccessEventStore {
    // 2
    EKAuthorizationStatus authorizationStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    
    switch (authorizationStatus) {
            // 3
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted: {
            self.isAccessToEventStoreGranted = NO;
            /*
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Access Denied"
                                                                message:@"This app doesn't have access to your Reminders."
                                                               delegate:nil
                                                      cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [alertView show];
            [self.tableView reloadData];
             */
            break;
        }
            
            // 4
        case EKAuthorizationStatusAuthorized:
            self.isAccessToEventStoreGranted = YES;
            //[self.tableView reloadData];
            break;
            
            // 5
        case EKAuthorizationStatusNotDetermined: {
            //__weak RWTableViewController *weakSelf = self;
            [self.eventStore requestAccessToEntityType:EKEntityTypeReminder
                                            completion:^(BOOL granted, NSError *error) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    self.isAccessToEventStoreGranted = granted;
                                                    //[weakSelf.tableView reloadData];
                                                });
                                            }];
            break;
        }
    }
}

/*
- (EKCalendar *)calendar {
    if (!_calendar) {
        return self.eventStore.defaultCalendarForNewReminders;
    }
    return nil;
}
*/

- (EKCalendar *)calendar {
    if (!_calendar) {
        
        // 1
        NSArray *calendars = [self.eventStore calendarsForEntityType:EKEntityTypeReminder];
        
        // 2
        NSString *calendarTitle = @"Reminders";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title matches %@", calendarTitle];
        NSArray *filtered = [calendars filteredArrayUsingPredicate:predicate];
        
        if ([filtered count]) {
            _calendar = [filtered firstObject];
        } else {
            _calendar = [EKCalendar calendarForEntityType:EKEntityTypeReminder eventStore:self.eventStore];
            _calendar.title = @"Reminders";
            _calendar.source = self.eventStore.defaultCalendarForNewReminders.source;
            
            // 4
            NSError *calendarErr = nil;
            BOOL calendarSuccess = [self.eventStore saveCalendar:_calendar commit:YES error:&calendarErr];
            if (!calendarSuccess) {
                // Handle error
            }
        }
    }
    return _calendar;
}

- (void)fetchReminders {
    if (self.isAccessToEventStoreGranted) {
        // 1
        NSPredicate *predicate = [self.eventStore predicateForRemindersInCalendars:@[self.calendar]];
        
        // 2
        [self.eventStore fetchRemindersMatchingPredicate:predicate completion:^(NSArray *reminders) {
            // 3
            self.reminders = reminders;
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (IBAction)downloadAction:(id)sender {
    [self nprApiRequest];
}

- (IBAction)playAction:(id)sender {
    // put playing code here
    NSMutableArray *avArray = [[NSMutableArray alloc] init];
    for (NSString *urlString in _nprAudioData) {
        AVPlayerItem *pl = [[AVPlayerItem alloc] initWithURL: [NSURL URLWithString:urlString]];
        [avArray addObject:pl];
    }
    NSArray *array = [avArray copy];
    AVQueuePlayer *player = [[AVQueuePlayer alloc] initWithItems:array];
    [player play];
}
@end
