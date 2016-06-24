//
//  AlarmModel.h
//  Tralarm
//
//  Created by Sam Gehman on 6/23/16.
//  Copyright © 2016 Sam Gehman. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AlarmModelDelegate <NSObject>
@required
- (void)alarmFire:(NSTimer *)timer;
- (void)changeTimeFieldTo:(NSDate*)alarmDate withFormat:(NSDateFormatter*)dateFormat;
- (void)updateAlarmButtonTitle:(NSString*)title;
@end

@interface AlarmModel : NSObject

@property (weak, nonatomic) id<AlarmModelDelegate> delegate;
@property (strong, nonatomic) NSTimer *alarmTimer;
@property (nonatomic) BOOL alarmOn;

- (void)alarmSet:(NSDate *)alarmDate;
- (void) cancelAlarm;

@end
