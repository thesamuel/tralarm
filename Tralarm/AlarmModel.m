//
//  AlarmModel.m
//  Tralarm
//
//  Created by Sam Gehman on 6/23/16.
//  Copyright © 2016 Sam Gehman. All rights reserved.
//

#import "AlarmModel.h"

@implementation AlarmModel

- (instancetype)init {
    self = [super init];
    if (self) {
        //do something?
    }
    return self;
}

- (void)alarmSet:(NSDate *)alarmDate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.timeStyle = NSDateFormatterShortStyle;
    [self.delegate changeTimeFieldTo:alarmDate withFormat:dateFormat];
    
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
    
    NSTimer *alarmTimer = [[NSTimer alloc] initWithFireDate:alarmDate interval:0 target:self.delegate selector:@selector(alarmFire:) userInfo:nil repeats:NO];
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    [runner addTimer:alarmTimer forMode: NSDefaultRunLoopMode];
    _alarmOn = TRUE;
}

- (void) cancelAlarm {
    [_alarmTimer invalidate];
    _alarmTimer = nil;
    _alarmOn = FALSE;
}

@end
