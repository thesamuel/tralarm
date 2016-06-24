//
//  RadioModel.h
//  Tralarm
//
//  Created by Sam Gehman on 6/24/16.
//  Copyright © 2016 Sam Gehman. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AVFoundation;

@interface RadioModel : NSObject

@property (strong, nonatomic) AVQueuePlayer *player;
@property (strong, nonatomic) NSURL *directoryURL;
@property (strong, nonatomic) NSMutableArray *nprAudioData;
@property (strong, nonatomic) AVAudioPlayer *backgroundMusicPlayer;

- (void)playNPR;

@end
