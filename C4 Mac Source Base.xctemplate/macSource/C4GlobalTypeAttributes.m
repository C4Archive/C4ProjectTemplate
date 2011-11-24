//
//  C4GlobalTypeAttributes.m
//  C4A
//
//  Created by Travis Kirton on 11-01-30.
//  Copyright 2011 Travis Kirton. All rights reserved.
//

#import "C4GlobalTypeAttributes.h"

static C4GlobalTypeAttributes *sharedC4GlobalTypeAttributes = nil;

@implementation C4GlobalTypeAttributes

@synthesize attributes;

+(void)load {
	if(VERBOSELOAD) printf("C4GlobalTypeAttributes\n");
}

-(void)setObject:(id)object forKey:(NSString *)key {
	[self.attributes setObject:object forKey:key];
}

-(void)setValue:(id)object forKey:(NSString *)key {
	[self.attributes setValue:object forKey:key];	
}

-(void)removeObjectForKey:(NSString *)key {
	[self.attributes removeObjectForKey:key];
}

-(id)objectForKey:(NSString *)key {
	return [self.attributes objectForKey:key];
}

-(C4String *)description {
	return [C4String stringWithString:[self.attributes description]];
}

-(CFDictionaryRef)attributesAsCFDictionaryRef {
	return [self CFDictionaryRefFrom:self.attributes];
}
-(CFDictionaryRef)CFDictionaryRefFrom:(NSDictionary *)dictionary {
	CFMutableDictionaryRef mDict = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, NULL, NULL);
	NSArray *keys = [dictionary allKeys];
    NSInteger count = [keys count];
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply(count, queue,
                   ^(size_t i) {
                       if([[keys objectAtIndex:i] isEqualTo:NSFontAttributeName]) {
                           CTFontRef font = (CTFontRef)[dictionary objectForKey:[keys objectAtIndex:i]];
                           CFDictionaryAddValue(mDict, kCTFontAttributeName, font);
                       }
                       else if([[keys objectAtIndex:i] isEqualTo:NSKernAttributeName]) {
                           CGFloat value[1]; 
                           value[0] = [[dictionary objectForKey:[keys objectAtIndex:i]] floatValue];
                           CFNumberRef kernValue = CFNumberCreate(kCFAllocatorDefault, kCFNumberFloatType, &value[0]);
                           CFDictionaryAddValue(mDict, kCTKernAttributeName, kernValue);
                           CFRelease(kernValue);
                       }
                       else if([[keys objectAtIndex:i] isEqualTo:NSForegroundColorAttributeName]) {
                           CGColorRef colorRef = [C4Color NSColorToCGColor:[dictionary objectForKey:[keys objectAtIndex:i]]];
                           CFDictionaryAddValue(mDict, kCTForegroundColorAttributeName, colorRef);
                       }
                       else if([[keys objectAtIndex:i] isEqualTo:NSStrokeWidthAttributeName]) {
                           CGFloat value[1]; 
                           value[0] = [[dictionary objectForKey:[keys objectAtIndex:i]] floatValue];
                           CFNumberRef strokeWidthValue = CFNumberCreate(kCFAllocatorDefault, kCFNumberFloatType, &value[0]);
                           CFDictionaryAddValue(mDict, kCTStrokeWidthAttributeName, strokeWidthValue);
                           CFRelease(strokeWidthValue);
                       }
                       else if([[keys objectAtIndex:i] isEqualTo:NSStrokeColorAttributeName]) {
                           CGColorRef colorRef = [C4Color NSColorToCGColor:[dictionary objectForKey:[keys objectAtIndex:i]]];
                           CFDictionaryAddValue(mDict, kCTStrokeColorAttributeName, colorRef);
                       }
                       else if([[keys objectAtIndex:i] isEqualTo:NSUnderlineStyleAttributeName]) {
                           int32_t value[1]; 
                           value[0] = [(NSNumber *)[dictionary objectForKey:[keys objectAtIndex:i]] intValue];
                           CFNumberRef underlineStyleValue = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &value[0]);
                           CFDictionaryAddValue(mDict, kCTUnderlineStyleAttributeName, underlineStyleValue);
                           CFRelease(underlineStyleValue);
                       }
                       else if([[keys objectAtIndex:i] isEqualTo:NSUnderlineColorAttributeName]) {
                           CGColorRef colorRef = [C4Color NSColorToCGColor:[dictionary objectForKey:[keys objectAtIndex:i]]];
                           CFDictionaryAddValue(mDict, kCTUnderlineColorAttributeName, colorRef);
                       }
                   });
            return mDict;
}

#pragma mark Singleton

-(id) init
{
    if((self = [super init]))
    {
        self.attributes = [[[NSMutableDictionary alloc] initWithCapacity:0] retain];
        
        //Default attributes
        [self.attributes setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
        [self.attributes setObject:[NSFont systemFontOfSize:14.0f] forKey:NSFontAttributeName];
    }
    
    return self;
}

+ (C4GlobalTypeAttributes*)sharedManager
{
    if (sharedC4GlobalTypeAttributes == nil) {
        static dispatch_once_t once;
        dispatch_once(&once, ^ { sharedC4GlobalTypeAttributes = [[super allocWithZone:NULL] init]; 
        });
        return sharedC4GlobalTypeAttributes;
        
        
    }
    return sharedC4GlobalTypeAttributes;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedManager] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}
@end
