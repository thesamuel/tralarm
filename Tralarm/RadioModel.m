//
//  RadioModel.m
//  Tralarm
//
//  Created by Sam Gehman on 6/24/16.
//  Copyright © 2016 Sam Gehman. All rights reserved.
//

#import "RadioModel.h"

static NSString *const NPR_API_KEY = @"MDIwMDE5ODU5MDE0NjM3MzYyMDc3NmE4MQ000";

@implementation RadioModel

- (void)playNPR {
//    // Test URL
//    NSURL *url = [NSURL URLWithString: @"http://api.npr.org/query?id=3&date=2016-05-30&dateType=story&output=JSON&apiKey=MDIwMDE5ODU5MDE0NjM3MzYyMDc3NmE4MQ000"];
    
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat: @"https://api.npr.org/query?id=3&output=JSON&apiKey=%@", NPR_API_KEY]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData* nprData = [NSData dataWithContentsOfURL:url];
        [self performSelectorOnMainThread:@selector(nprFetchedData:) withObject:nprData waitUntilDone:YES];
    });
}

- (void)nprFetchedData:(NSData *)responseData {
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
    
    NSMutableArray *audioURLs = [[NSMutableArray alloc] init];
    NSDictionary *list = json[@"list"];
    NSArray *stories = list[@"story"];
    for (NSDictionary *story in stories) {
        NSArray *audioArray = story[@"audio"];
        NSDictionary *audioObject = audioArray[0];
        NSDictionary *formatObject = audioObject[@"format"];
        NSArray *mp3Array = formatObject[@"mp3"];
        NSDictionary *mp3Object = mp3Array[0];
        NSString *mp3URL = mp3Object[@"$text"];
        NSLog(@"NPR MP3 URL:%@", mp3URL);
        [audioURLs addObject:mp3URL];
    }
    
    _player = [[AVQueuePlayer alloc] init];
    _directoryURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]] isDirectory:YES];
    [[NSFileManager defaultManager] createDirectoryAtURL:_directoryURL withIntermediateDirectories:YES attributes:nil error:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i < audioURLs.count; i++) {
            NSLog(@"Loading url: %@", audioURLs[i]);

            NSString *fileName = [NSString stringWithFormat:@"%@_%@", [[NSProcessInfo processInfo] globallyUniqueString], @"audio.mp3"];
            NSData* data = [NSData dataWithContentsOfURL: [NSURL URLWithString: audioURLs[i]]];
            NSURL *fileURL = [_directoryURL URLByAppendingPathComponent:fileName];
            [data writeToURL:fileURL options:NSDataWritingAtomic error:nil];
            
            AVPlayerItem *pl = [[AVPlayerItem alloc] initWithURL:fileURL];
            [_player insertItem:pl afterItem:nil];
            [_player play];
            if (i == (audioURLs.count - 1)) {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:pl];
            }
        }
    });
}

- (void)itemDidFinishPlaying:(NSNotification *) notification {
    NSLog(@"Deleting files at: %@", _directoryURL);
    [[NSFileManager defaultManager] removeItemAtURL:_directoryURL error:nil];
}

@end
