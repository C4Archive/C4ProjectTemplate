//
//  C4Quartz.h
//  C4
//
//  Created by moi on 11-06-24.
//  Copyright 2011 mediart. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface C4Quartz : C4Object {
    @private
    QCRenderer *patchRenderer;
    NSMutableDictionary *patchArguments;
}

+(C4Quartz *)patchWithName:(id)patchName;
-(id)initWithPatchName:(id)patchName;
-(void)render;
-(void)renderWithArguments:(NSDictionary *)arguments;

@end