//
//  C4GlobalStringAttributes.h
//  C4ARebuild
//
//  Created by moi on 11-04-05.
//  Copyright 2011 mediart. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface C4GlobalStringAttributes : C4Object {
    CGContextRef pdfContext;
    BOOL drawStringsToPDF;
    BOOL isClean;

}

+(C4GlobalStringAttributes *)sharedManager;

@property(readwrite) BOOL drawStringsToPDF, isClean;
@property(readwrite) CGContextRef pdfContext;
@end
