//
//  C4GlobalTypeAttributes.h
//  C4A
//
//  Created by Travis Kirton on 11-01-30.
//  Copyright 2011 Travis Kirton. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface C4GlobalTypeAttributes : C4Object {
	@private
	NSMutableDictionary	*attributes;
}

+(C4GlobalTypeAttributes *)sharedManager;

-(void)setObject:(id)object forKey:(NSString *)key;
-(void)setValue:(id)object forKey:(NSString *)key;
-(void)removeObjectForKey:(NSString *)key;
-(id)objectForKey:(NSString *)key;
-(C4String *)description;

-(CFDictionaryRef)attributesAsCFDictionaryRef;
-(CFDictionaryRef)CFDictionaryRefFrom:(NSDictionary *)dictionary;

@property(readwrite, retain) NSMutableDictionary *attributes;

@end