//
//  C4DevelopmentAppDelegate.h
//  C4Development
//
//  Created by moi on 11-04-05.
//  Copyright 2011 mediart. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "C4Canvas.h"
#import "C4OpenGLView.h"

#if (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_5)
@interface ___PACKAGENAME___AppDelegate : NSObject {
#else
	@interface ___PACKAGENAME___AppDelegate : NSObject <NSApplicationDelegate> {
#endif
		NSWindow *window;
		IBOutlet C4Canvas *_C4Canvas;
    }
    
    @property (assign) IBOutlet NSWindow *window;
	
    @end