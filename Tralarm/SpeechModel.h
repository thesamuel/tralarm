//
//  SpeechModel.h
//  Tralarm
//
//  Created by Sam Gehman on 6/23/16.
//  Copyright © 2016 Sam Gehman. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AVFoundation;

@interface SpeechModel : NSObject

@property (strong, nonatomic) AVSpeechSynthesizer *synthesizer;
- (void)speakString:(NSString*)speechString;

@end
