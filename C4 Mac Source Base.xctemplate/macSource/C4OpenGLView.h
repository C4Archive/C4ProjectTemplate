//
//  C4OpenGLView.h
//  Created by Travis Kirton.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/CVDisplayLink.h>

@interface C4OpenGLView : NSOpenGLView {
	
	BOOL keyIsPressed, mouseIsPressed;
	NSUInteger keyChar, keyCode, mouseButton;
	NSPoint mousePos, prevMousePos;

	BOOL isClean;
    
    BOOL readyToDraw;
    BOOL backgroundShouldDraw;
    BOOL flipped;
    BOOL isSetup;
    BOOL drawToPDF;
    
    CFURLRef pdfURL;
    CGContextRef pdfContext;
    CGDataConsumerRef pdfConsumer;
    
    NSRect	backgroundRect;
    NSTimer *animationTimer;
    NSDictionary *fullScreenOptions;

	@private
    NSPoint centerPos;
	NSRect canvasRect;
	NSSize canvasSize, screenSize;
	CGFloat canvasWidth, canvasHeight, screenWidth, screenHeight;	
	//C4Color *backgroundColor;
	NSString *exportDir, *exportFileName, *exportFileType, *appName;
	NSUInteger frameCount, currentDrawStyle;
	CGFloat frameRate;
    C4Color *backgroundColor;
    
    CVDisplayLinkRef displayLink;
	NSOpenGLPixelFormat *pixelFormat;
}

#pragma mark Singleton
+(C4OpenGLView *)sharedManager;

#pragma mark Structure
-(void)setup;
-(void)draw;
-(void)redraw;
-(void)windowWidth:(int)width andHeight:(int)height;
-(void)flipCoordinates;
-(void)nativeCoordinates;
-(void)drawStyle:(int)style;
-(void)setFrameRate:(CGFloat)aRate;
-(void)update;
-(void)setupDisplayLink;
-(void)setupAndStartDisplayLink;
-(void)stopDisplayLink;

#pragma mark Environment
-(void)cursor;
-(void)noCursor;
-(void)enterFullScreen;
-(void)exitFullScreen;
-(void)borderlessWindow;
-(void)borderedWindow;
-(void)toggleBorderlessWindow;
-(void)windowTitle:(id)title;
-(NSRect)visibleCanvasRect;
+(CGFloat)getScreenWidth;
+(CGFloat)getScreenHeight;
+(CGFloat)getCanvasWidth;
+(CGFloat)getCanvasHeight;
+(NSRect)getCanvasRect;
+(NSRect)getVisibleCanvasRect;
+(NSPoint)getMousePos;
+(NSUInteger)getMouseButton;
+(CGFloat)getFrameRate;
+(NSUInteger)getFrameCount;

#pragma mark Background
-(void)drawBackground;
-(void)background:(float)grey;
-(void)background:(float)grey alpha:(float)alpha;
-(void)backgroundRed:(float)red green:(float)green blue:(float)blue;
-(void)backgroundRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;
-(void)backgroundColor:(id)color;
-(void)backgroundImage:(C4Image *)bgImage;

#pragma mark Input
-(void)keyPressed;
-(void)keyReleased;
-(void)mousePressed;
-(void)mouseReleased;
-(void)mouseDragged;
-(void)mouseMoved;
-(void)mouseClicked;
-(void)mouseDoubleClicked;

#pragma mark Output
-(void)setupPDF;
-(void)endPDF;

#pragma mark Screen Shots
-(C4Image *)screenShot;
-(C4Image *)canvasShot;
-(C4Image *)screenShotFromRect:(NSRect)aRect;
-(void)saveScreenShot;
-(void)saveCanvasShot;
-(void)saveScreenShotFromRect:(NSRect)aRect;

@property(readonly) BOOL keyIsPressed, mouseIsPressed;
@property(readonly) NSUInteger keyChar, keyCode, mouseButton, frameCount, currentDrawStyle;
@property(readonly) NSPoint mousePos, prevMousePos, centerPos;
@property(readonly) NSSize canvasSize, screenSize;
@property(readonly) NSRect canvasRect;
@property(readonly) CGFloat canvasWidth, canvasHeight, screenWidth, screenHeight;
@property(readonly) CGFloat frameRate;

@property(readwrite,retain) C4Color *backgroundColor;
@property(readwrite,retain) NSString *exportDir;
@property(readwrite,retain) NSString *exportFileName;
@property(readwrite,retain) NSString *exportFileType;
@property(readwrite,retain) NSString *appName;

@end

@interface C4OpenGLView (private)
-(void)prepareOpenGL;
-(void)setAnimationTimer:(CGFloat)framerate;
-(void)stopAnimating;
-(void)checkClickCount:(NSEvent *)theEvent;
-(void)setupRect;
-(void)addTrackingArea;
-(CGImageRef)screenImageFromRect:(NSRect)aRect;
@end
