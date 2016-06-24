//
//  WeatherModel.m
//  Tralarm
//
//  Created by Sam Gehman on 6/24/16.
//  Copyright © 2016 Sam Gehman. All rights reserved.
//

#import "WeatherModel.h"

@implementation WeatherModel

- (void)weather {
    NSString *urlString = [NSString stringWithFormat:@"http://forecast.weather.gov/MapClick.php?lat=%@&lon=%@&FcstType=json", [NSString stringWithFormat:@"%f", _locator.latitude], [NSString stringWithFormat:@"%f", _locator.longitude]];
    //NSLog(@"URL String=%@", urlString);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString: urlString]];
        [self performSelectorOnMainThread:@selector(weatherFetchedData:) withObject:data waitUntilDone:YES];
    });
}

- (void)weatherFetchedData:(NSData *)responseData {
    //JSON Dump Debug
    NSString *jsonString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"Response JSON=%@", jsonString);
    
    NSDictionary *json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:NSJSONReadingMutableContainers
                          error:nil];
    
    NSDictionary *currentObs = json[@"currentobservation"];
    NSString *name = currentObs[@"name"]; // this
    NSString *temp = currentObs[@"Temp"]; // this
    NSString *desc = currentObs[@"Weather"]; // this
    NSDictionary *data = json[@"data"];
    NSArray *futureTemps = data[@"temperature"];
    NSString *tonightTemp = futureTemps[0]; // this
    if ([desc isEqualToString:@"NA"]) {
        desc = @"clear";
    }
    NSDictionary *weatherDictionary = [[NSDictionary alloc] initWithObjectsAndKeys: name, @"name", temp, @"temp", desc, @"desc", tonightTemp, @"tonightTemp", nil];
    [_delegate speakWeather:weatherDictionary];
}

@end
