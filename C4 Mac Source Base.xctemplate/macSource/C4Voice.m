//
//  C4Speech.m
//  C4A
//
//  Created by Travis Kirton on 11-02-02.
//  Copyright 2011 Travis Kirton. All rights reserved.
//

#import "C4Voice.h"


@implementation C4Voice
+(void)load {
	if(VERBOSELOAD) printf("C4Voice\n");
}

-(id)init {
	return [self initWithVoice:ALEX];
}

-(id)initWithVoice:(id)voice {
	if(!(self = [super init])){
		return nil;
	}
	synth = [[[NSSpeechSynthesizer alloc] init] retain];
	[synth setUsesFeedbackWindow:NO];
	
	[synth setVoice:[C4String nsStringFromObject:voice]];
	return self;
}

+(C4Voice *)initWithVoice:(id)voice {
	return [[[C4Voice alloc] initWithVoice:voice] autorelease];
}

-(C4String *)voice {
	return [C4String stringWithString:[synth voice]];
}

-(void)setVoice:(id)voice {
	[synth setVoice:[C4String nsStringFromObject:voice]];
}

-(CGFloat)rate {
	return synth.rate;
}

-(void)setRate:(CGFloat)rate {
	synth.rate = rate;
}

-(CGFloat)volume {
	return synth.volume;
}

-(void)setVolume:(CGFloat)volume {
	synth.volume = volume;
}

+(NSArray *)availableVoices {
	return [NSArray arrayWithObjects:@"AGNES",@"ALBERT",@"ALEX",@"BADNEWS",@"BAHH",@"BELLS",@"BOING",
			@"BRUCE",@"BUBBLES",@"CELLOS",@"DERANGED",@"FRED",@"GOODNEWS",@"HYSTERICAL",@"JUNIOR",@"KATHY",
			@"ORGAN",@"PRINCESS",@"RALPH",@"TRINOIDS",@"VICKI",@"VICTORIA",@"WHISPER",@"ZARVOX",nil];
}

+(BOOL)isAnyApplicationSpeaking {
	return [NSSpeechSynthesizer isAnyApplicationSpeaking];
}

+(void)speak:(id)sentence {
	C4Voice *temporarySynth = [[[C4Voice alloc] init] autorelease];
	[temporarySynth speak:sentence];
}

+(void)speak:(id)sentence withVoice:(id)voice {
	C4Voice *temporarySynth = [[[C4Voice alloc] initWithVoice:voice] autorelease];
	[temporarySynth speak:sentence];
}

-(void)speak:(id)sentence {
	[synth startSpeakingString:[C4String nsStringFromObject:sentence]];
}

-(void)speak:(id)sentence withVoice:(id)voice {
	[self setVoice:voice];
	[synth startSpeakingString:[C4String nsStringFromObject:sentence]];
}

-(BOOL)isSpeaking {
	return [synth isSpeaking];
}

-(void)pause:(int)pauseBoundary {
	[synth pauseSpeakingAtBoundary:pauseBoundary];
}

-(void)continueSpeaking {
	[synth continueSpeaking];
}

-(void)stopSpeaking {
	[synth stopSpeakingAtBoundary:IMMEDIATELY];
}

-(void)stopSpeaking:(int)stopBoundary  {
	[synth stopSpeakingAtBoundary:stopBoundary];
}
@end
