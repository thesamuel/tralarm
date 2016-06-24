//
//  LocationModel.m
//  Tralarm
//
//  Created by Sam Gehman on 6/23/16.
//  Copyright © 2016 Sam Gehman. All rights reserved.
//

#import "LocationModel.h"

static NSString *const GOOGLE_API_KEY = @"AIzaSyD-X_DhihbCFfMav28qrx8ulRr-Q8Y_ISI";

@implementation LocationModel

- (instancetype)init{
    self = [super init];
    if (self) {
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
        [_locationManager startMonitoringSignificantLocationChanges];
    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"%@", [locations lastObject]);
    CLLocation *newLocation = [locations lastObject];
    self.location = newLocation;
    CLLocationCoordinate2D coordinate = [newLocation coordinate];
    self.latitude = coordinate.latitude;
    self.longitude = coordinate.longitude;
    NSString *newCoordinateString = [NSString stringWithFormat:@"%@,%@",
                                    [NSString stringWithFormat:@"%f", coordinate.latitude],
                                    [NSString stringWithFormat:@"%f", coordinate.longitude]];
    _coordinatesString = newCoordinateString;
    NSLog(@"Coordinates=%@", _coordinatesString);
    [self localityWithCoordinateString: newCoordinateString];
}

- (void)localityWithCoordinateString:(NSString*) newCoordinateString {
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?latlng=%@&key=%@", newCoordinateString, GOOGLE_API_KEY];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString: urlString]];
        [self performSelectorOnMainThread:@selector(localityFetchedData:) withObject:data waitUntilDone:YES];
    });
}

- (void)localityFetchedData:(NSData *)responseData {
    //JSON Dump Debug
    NSString *jsonString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"Response JSON=%@", jsonString);
}

@end
