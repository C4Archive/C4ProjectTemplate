//
//  C4Noise.h
//  Perlin
//
//  Created by moi on 11-04-08.
//  Copyright 2011 mediart. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface C4Noise : C4Object {
@private
    
}

+(C4Noise *)sharedManager;

+(CGFloat)noiseX:(CGFloat)x;
+(CGFloat)noiseX:(CGFloat)x Y:(CGFloat)y;
+(CGFloat)noiseX:(CGFloat)x Y:(CGFloat)y Z:(CGFloat)z;
@end