//
//  SpeechModel.m
//  Tralarm
//
//  Created by Sam Gehman on 6/23/16.
//  Copyright © 2016 Sam Gehman. All rights reserved.
//

#import "SpeechModel.h"

@implementation SpeechModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _synthesizer = [[AVSpeechSynthesizer alloc] init];
    }
    return self;
}

- (void)speakString:(NSString*)speechString {
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:speechString];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
    [_synthesizer speakUtterance:utterance];
}

@end
