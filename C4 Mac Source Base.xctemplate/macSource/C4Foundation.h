//
//  C4Foundation.h
//  Created by Travis Kirton
//

#import <Cocoa/Cocoa.h>

@interface C4Foundation : C4Object {
    NSComparator floatSortComparator;
}

#pragma mark Singleton
+(C4Foundation *)sharedManager;
+(NSComparator)floatComparator;
-(NSComparator)floatComparator;

#pragma mark Foundation 
void C4Log(NSString *logString,...);
NSInteger basicSort(id obj1, id obj2, void *context);
@end
