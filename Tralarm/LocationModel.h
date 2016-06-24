//
//  LocationModel.h
//  Tralarm
//
//  Created by Sam Gehman on 6/23/16.
//  Copyright © 2016 Sam Gehman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "NSString+URLEncoding.h"

@interface LocationModel : NSObject<CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;
@property (nonatomic) CLLocationDegrees longitude;
@property (nonatomic) CLLocationDegrees latitude;
@property (strong, nonatomic) NSString *coordinatesString;


@end
