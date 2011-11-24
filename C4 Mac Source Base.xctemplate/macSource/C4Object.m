//
//  C4Object.m
//  C4A
//
//  Created by moi on 11-02-20.
//  Copyright 2011 Travis Kirton. All rights reserved.
//

#import "C4Object.h"

@interface C4Object () {}
-(void)checkFrameCountAndUpdate;
@end

@implementation C4Object

-(void)dealloc {
    [self stopUpdating];
    [updateTimer release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

-(void)listenFor:(NSString *)aNotification andRunMethod:(NSString *)aMethodName{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:NSSelectorFromString(aMethodName) name:aNotification object:nil];
}

-(void)stopListeningFor:(NSString *)aMethodName {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:aMethodName object:nil];
}

-(void)postNotification:(NSString *)aNotification {
	[[NSNotificationCenter defaultCenter] postNotificationName:aNotification object:self];
}

-(void)update {
}

-(void)updateAutomaticallyUsingSeconds:(CGFloat)seconds {
    [self stopUpdating];
    if(seconds > 0.001f) {
        updatingBySeconds = YES;
        updateTimer = [NSTimer timerWithTimeInterval:seconds
                                              target:self
                                            selector:@selector(update)
                                            userInfo:nil
                                             repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:updateTimer forMode:NSDefaultRunLoopMode];
    } else {
        C4Log(@"seconds must be greater than 0");
    }
}

-(void)updateAutomaticallyUsingFrames:(NSInteger)frames {
    [self stopUpdating];
    if(frames >=1) {
        frameCountMeasure = frames;
        updatingByFrames = YES;
        [self listenFor:@"frameCountUpdated" andRunMethod:@"checkFrameCountAndUpdate"];
    } else {
        C4Log(@"frame count must be greater than 1");
    }
}

-(void)stopUpdating {
    if(updatingBySeconds) {
        updatingBySeconds = NO;
        [updateTimer invalidate];
    }
    if(updatingByFrames) {
        updatingByFrames = NO;
        [self stopListeningFor:@"frameCountUpdated"];
    }
}

-(BOOL)isUpdating {
    if(updatingByFrames || updatingBySeconds) return YES;
    return NO;
}

-(void)checkFrameCountAndUpdate {
    int actualFrameCount = (int)[C4Canvas getFrameCount];
    if(actualFrameCount%frameCountMeasure == 0) [self update];
}
@end
