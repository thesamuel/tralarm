//
//  WeatherModel.h
//  Tralarm
//
//  Created by Sam Gehman on 6/24/16.
//  Copyright © 2016 Sam Gehman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+URLEncoding.h"
#import "LocationModel.h"

@protocol WeatherModelDelegate <NSObject>
@required
- (void)speakWeather:(NSDictionary*)weatherReportString;
@end

@interface WeatherModel : NSObject

@property (nonatomic, weak) id<WeatherModelDelegate> delegate;
@property (strong, nonatomic) LocationModel *locator;

- (void)weather;

@end
