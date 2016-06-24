//
//  CommuteModel.m
//  Tralarm
//
//  Created by Sam Gehman on 6/23/16.
//  Copyright © 2016 Sam Gehman. All rights reserved.
//

#import "CommuteModel.h"

static NSString *const GOOGLE_API_KEY = @"AIzaSyD-X_DhihbCFfMav28qrx8ulRr-Q8Y_ISI";

@implementation CommuteModel

- (void)calculateCommuteWithAddress:(NSString*) address {
    NSString *encodedQuery = [address stringByAddingPercentEncodingForFormData:YES];
    //NSLog(@"Encoded Query=%@", encodedQuery);
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=%@&destinations=%@&key=%@", _locator.coordinatesString, encodedQuery, GOOGLE_API_KEY];
    //NSLog(@"URL String=%@", urlString);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString: urlString]];
        [self performSelectorOnMainThread:@selector(commuteFetchedData:) withObject:data waitUntilDone:YES];
    });
}

- (void)commuteFetchedData:(NSData *)responseData {
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
    NSArray *rows = json[@"rows"];
    NSDictionary *row = rows[0];
    NSArray *elements = row[@"elements"];
    NSDictionary *element = elements[0];
    NSDictionary *duration = element[@"duration"];
    NSUInteger durationInt = (NSUInteger) roundf([duration[@"value"] integerValue] / 60.0);
    NSLog(@"duration=%zd", durationInt);
    [_delegate speakCommuteDuration:durationInt];
}

@end
