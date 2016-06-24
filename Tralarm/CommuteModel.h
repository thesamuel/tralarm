//
//  CommuteModel.h
//  Tralarm
//
//  Created by Sam Gehman on 6/23/16.
//  Copyright © 2016 Sam Gehman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationModel.h"

@protocol CommuteModelDelegate <NSObject>
@required
- (void)speakCommuteDuration:(NSUInteger)duration;
@end

@interface CommuteModel : NSObject

@property (nonatomic, weak) id<CommuteModelDelegate> delegate;
@property (strong, nonatomic) LocationModel *locator;
- (void)calculateCommuteWithAddress:(NSString*) address;

@end
