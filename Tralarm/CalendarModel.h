//
//  CalendarModel.h
//  Tralarm
//
//  Created by Sam Gehman on 6/24/16.
//  Copyright © 2016 Sam Gehman. All rights reserved.
//

#import <Foundation/Foundation.h>
@import EventKit;

@interface CalendarModel : NSObject

// The database with calendar events and reminders
@property (strong, nonatomic) EKEventStore *eventStore;

// Indicates whether app has access to event store.
@property (nonatomic) BOOL isAccessToEventStoreGranted;

@property (copy, nonatomic) NSArray *reminders;
@property (strong, nonatomic) EKCalendar *calendar;

- (NSString*)stringFromReminders;


@end
