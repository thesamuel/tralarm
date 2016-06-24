//
//  CalendarModel.m
//  Tralarm
//
//  Created by Sam Gehman on 6/24/16.
//  Copyright © 2016 Sam Gehman. All rights reserved.
//

#import "CalendarModel.h"

@implementation CalendarModel

- (instancetype)init{
    self = [super init];
    if (self) {
        [self updateAuthorizationStatusToAccessEventStore];
        [self fetchReminders];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fetchReminders)
                                                     name:EKEventStoreChangedNotification object:nil];
    }
    return self;
}

- (NSString*)stringFromReminders {
    NSMutableString *remindersString = [NSMutableString new];
    int count = 1;
    for (EKReminder *r in _reminders) {
        NSString *countString = [NSString stringWithFormat: @"%d", count];
        if (count % 10 == 1) {
            countString = [countString stringByAppendingString:@"st reminder: "];
        } else if (count % 10 == 2) {
            countString = [countString stringByAppendingString:@"nd reminder: "];
        } else if (count % 10 == 3) {
            countString = [countString stringByAppendingString:@"rd reminder: "];
        } else {
            countString = [countString stringByAppendingString:@"th reminder: "];
        }
        [remindersString appendString:[countString stringByAppendingString:r.title]];
        count++;
    }
    return remindersString;
}

- (EKEventStore *)eventStore {
    if (!_eventStore) {
        _eventStore = [[EKEventStore alloc] init];
    }
    return _eventStore;
}

- (void) updateAuthorizationStatusToAccessEventStore {
    EKAuthorizationStatus authorizationStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    switch (authorizationStatus) {
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
            
        case EKAuthorizationStatusAuthorized:
            self.isAccessToEventStoreGranted = YES;
            //[self.tableView reloadData];
            break;
            
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

//- (EKCalendar *)calendar {
//    if (!_calendar) {
//        return self.eventStore.defaultCalendarForNewReminders;
//    }
//    return nil;
//}

- (EKCalendar *)calendar {
    if (!_calendar) {
        NSArray *calendars = [self.eventStore calendarsForEntityType:EKEntityTypeReminder];
        NSString *calendarTitle = @"Reminders";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title matches %@", calendarTitle];
        NSArray *filtered = [calendars filteredArrayUsingPredicate:predicate];
        if ([filtered count]) {
            _calendar = [filtered firstObject];
        } else {
            _calendar = [EKCalendar calendarForEntityType:EKEntityTypeReminder eventStore:self.eventStore];
            _calendar.title = @"Reminders"; // TODO: Make this SELECTABLE
            _calendar.source = self.eventStore.defaultCalendarForNewReminders.source;
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
        NSPredicate *predicate = [self.eventStore predicateForRemindersInCalendars:@[self.calendar]];
        [self.eventStore fetchRemindersMatchingPredicate:predicate completion:^(NSArray *reminders) {
            self.reminders = reminders;
        }];
    }
}

@end
