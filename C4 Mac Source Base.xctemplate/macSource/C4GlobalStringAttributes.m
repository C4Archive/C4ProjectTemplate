
//
//  C4GlobalStringAttributes.m
//  C4ARebuild
//
//  Created by moi on 11-04-05.
//  Copyright 2011 mediart. All rights reserved.
//

#import "C4GlobalStringAttributes.h"
static C4GlobalStringAttributes *shareC4GlobalStringAttributes = nil;

@implementation C4GlobalStringAttributes
@synthesize pdfContext,drawStringsToPDF,isClean;

#pragma mark Singleton

-(id) init
{
    if((self = [super init]))
    {
    }
    
    return self;
}

+ (C4GlobalStringAttributes*)sharedManager
{
    if (shareC4GlobalStringAttributes == nil) {
        static dispatch_once_t once;
        dispatch_once(&once, ^ { shareC4GlobalStringAttributes = [[super allocWithZone:NULL] init]; 
        });
        return shareC4GlobalStringAttributes;
        
        
    }
    return shareC4GlobalStringAttributes;
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
