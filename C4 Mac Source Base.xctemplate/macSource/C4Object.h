//
//  C4Object.h
//  C4A
//
//  Created by moi on 11-02-20.
//  Copyright 2011 Travis Kirton. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface C4Object : NSObject {
@private
    BOOL updatingByFrames;
    BOOL updatingBySeconds;
    NSInteger frameCountMeasure;
    NSTimer *updateTimer;
}

-(void)listenFor:(NSString *)aNotification andRunMethod:(NSString *)aMethodName;
-(void)stopListeningFor:(NSString *)aMethodName;
-(void)postNotification:(NSString *)aNotification;

-(void)update;
-(void)updateAutomaticallyUsingSeconds:(CGFloat)seconds;
-(void)updateAutomaticallyUsingFrames:(NSInteger)frames;
-(void)stopUpdating;

-(BOOL)isUpdating;
@end
