//
//  C4Speech.h
//  C4A
//
//  Created by Travis Kirton on 11-02-02.
//  Copyright 2011 Travis Kirton. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface C4Voice : C4Object {
	NSSpeechSynthesizer *synth;
}

-(id)init;
-(id)initWithVoice:(id)voice;
+(C4Voice *)initWithVoice:(id)voice;

-(C4String *)voice;
-(void)setVoice:(id)voice;
-(CGFloat)rate;
-(void)setRate:(CGFloat)rate;
-(CGFloat)volume;
-(void)setVolume:(CGFloat)volume;

+(NSArray *)availableVoices;
+(BOOL)isAnyApplicationSpeaking;

+(void)speak:(id)sentence;
+(void)speak:(id)sentence withVoice:(id)voice;
-(void)speak:(id)sentence;
-(void)speak:(id)sentence withVoice:(id)voice;
-(BOOL)isSpeaking;
-(void)pause:(int)pauseBoundary;
-(void)continueSpeaking;
-(void)stopSpeaking;
-(void)stopSpeaking:(int)stopBoundary;
@end