
//
//  C4OpenGLView.m
//  Created by Travis Kirton.
//

#import "C4OpenGLView.h"

static C4OpenGLView *sharedC4OpenGLView = nil;

@implementation C4OpenGLView

@synthesize backgroundColor, exportDir, exportFileName, exportFileType, appName;
@synthesize keyIsPressed, mouseIsPressed;
@synthesize keyChar, keyCode, mouseButton, frameCount, frameRate;
@synthesize mousePos, prevMousePos, centerPos;
@synthesize canvasSize, screenSize;
@synthesize canvasRect;
@synthesize canvasWidth, canvasHeight, screenWidth, screenHeight, currentDrawStyle;

+(void)load {
	if(VERBOSELOAD) printf("C4OpenGLView\n");
}

-(void)awakeFromNib {
	readyToDraw = NO;
	backgroundShouldDraw = YES;
	flipped = NO;
	isSetup = NO;
	drawToPDF = NO;
	
	frameCount = 0;
	frameRate = 60.0f;
	currentDrawStyle = SINGLEFRAME;
	
	backgroundRect = NSZeroRect;
	mouseIsPressed = NO;
	isClean = YES;
	screenSize = [[NSScreen mainScreen] frame].size;
	screenWidth = screenSize.width;
	screenHeight = screenSize.height;
	[self setCanDrawConcurrently:YES];
	[self windowWidth:100 andHeight:100];
	fullScreenOptions = [[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]  
													 forKey:NSFullScreenModeAllScreens] retain];
    self.appName = [[NSFileManager defaultManager] displayNameAtPath:[[NSBundle mainBundle] bundlePath]];
    [self windowTitle:self.appName];
    [[self.window contentView] setWantsLayer:YES];
    [self.window makeKeyAndOrderFront:nil];
    
}

#pragma mark Structure
-(void)setupRect{
	[self setup];
	[self addTrackingArea];
	isSetup = YES;
	[self redraw];
}

-(void)setup {
}

-(void)drawRect:(NSRect)dirtyRect {
	if(readyToDraw) {
        glClearColor(0, 0, 0, 0);
        glClear(GL_COLOR_BUFFER_BIT);
		if(isSetup){
			if (backgroundShouldDraw == YES) {
				[self drawBackground];
				backgroundShouldDraw = NO;
			}
			[self draw];
			frameCount++;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"frameCountUpdated" object:self];
		}
	}
    /*
     bad hack...
     i'm doing something that fucks with the drawing of the window...
     it happens after i call setWantsLayer:YES
     so i add this to cover up the drawing in the titlebar
     */
    /*
     I needed this before, because things were drawing over top of the tite bar...
     but now it doesn't seem to be needed (june 17)
     */
    [self.window display];
    //[self.window makeKeyAndOrderFront:nil];
}

-(void)drawStyle:(int)style {
    if(currentDrawStyle != style) {
        if(currentDrawStyle == DISPLAYRATE) [self stopDisplayLink];
        if(currentDrawStyle == ANIMATED) [self stopAnimating];
        currentDrawStyle = style;
        switch (currentDrawStyle) {
            case ANIMATED:
                [self setAnimationTimer:frameRate];
                break;
            case DISPLAYRATE:
                [self setupAndStartDisplayLink];
                break;
            default:
                [self redraw];
                break;
        }
    }
}

- (CVReturn)getFrameForTime:(const CVTimeStamp*)outputTime
{
	// There is no autorelease pool when this method is called because it will be called from a background thread
	// It's important to create one or you will leak objects
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[self redraw];
	[pool release];
    return kCVReturnSuccess;
}


// This is the renderer output callback function
static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime, CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext)
{
    CVReturn result = [(C4OpenGLView*)displayLinkContext getFrameForTime:outputTime];
    return result;
}

- (void) setupDisplayLink
{
	// Create a display link capable of being used with all active displays
	CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);
	
	// Set the renderer output callback function
	CVDisplayLinkSetOutputCallback(displayLink, &MyDisplayLinkCallback, self);
	
	// Set the display link for the current renderer
	CGLContextObj cglContext = [[self openGLContext] CGLContextObj];
	CGLPixelFormatObj cglPixelFormat = [[self pixelFormat] CGLPixelFormatObj];
	CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(displayLink, cglContext, cglPixelFormat);
}

-(void)setupAndStartDisplayLink {
    [self setupDisplayLink];
    if (displayLink && !CVDisplayLinkIsRunning(displayLink))
		CVDisplayLinkStart(displayLink);
}

-(void)stopDisplayLink {
    if(displayLink && CVDisplayLinkIsRunning(displayLink)) 
        CVDisplayLinkStop(displayLink);
}

-(void)setFrameRate:(CGFloat)rate {
	frameRate = rate;
	if (frameRate <= 0.0f) {
		frameRate = 0.001;
	}
	[self setAnimationTimer:frameRate];
}

-(void)setAnimationTimer:(CGFloat)framerate {
	if (animationTimer != nil) [self stopAnimating];
	animationTimer = [NSTimer timerWithTimeInterval:(1.0f/framerate)
											 target:self
										   selector:@selector(redraw)
										   userInfo:nil
											repeats:YES];
	[[NSRunLoop mainRunLoop] addTimer:animationTimer forMode:NSDefaultRunLoopMode];
}

-(void)update {
}

-(void)stopAnimating {
	[animationTimer invalidate];
	animationTimer = nil;
}

-(void)draw {
}

-(void)redraw {
    [self setNeedsDisplay:YES];
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (BOOL)becomeFirstResponder
{
	return  YES;
}

- (BOOL)resignFirstResponder
{
	return YES;
}

-(void)windowWidth:(int)width andHeight:(int)height {
	canvasSize = NSMakeSize(width, height);
	canvasWidth = canvasSize.width;
	canvasHeight = canvasSize.height;
	canvasRect.size = canvasSize;
	canvasRect.origin = NSZeroPoint;
	NSRect contentRect = [NSWindow contentRectForFrameRect:canvasRect 
                                                 styleMask:NSTitledWindowMask];
	float titleBarHeight = height - contentRect.size.height;
	// this centers the window to the screen when it first runs
	[self.window setFrame:NSMakeRect((screenWidth-canvasWidth)/2, (screenHeight-titleBarHeight-canvasHeight) / 2 , canvasWidth, canvasHeight+titleBarHeight) display:YES];
    
    centerPos = NSMakePoint(self.canvasWidth/2.0f, self.canvasHeight/2.0f);
}

-(void)addTrackingArea {
	[self addTrackingArea:[[NSTrackingArea alloc] initWithRect:self.visibleRect options:(NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveInKeyWindow ) owner:self userInfo:nil]];
	backgroundRect = NSMakeRect(self.visibleRect.origin.x-1, self.visibleRect.origin.y-1, self.visibleRect.size.width+2, self.visibleRect.size.height+2);
}

-(void)flipCoordinates {
	flipped = YES;
}

-(void)nativeCoordinates {
	flipped = NO;
}

-(BOOL)isFlipped {
	return flipped;
}

#pragma mark Environment
-(void)cursor {
	[NSCursor unhide];
}

-(void)noCursor {
	[NSCursor hide];
}

+(CGFloat)getScreenWidth {
	return [self sharedManager].screenWidth;
}
+(CGFloat)getScreenHeight {
	return [self sharedManager].screenHeight;
}
+(CGFloat)getCanvasWidth {
	return [self sharedManager].canvasWidth;
}
+(CGFloat)getCanvasHeight {
	return [self sharedManager].canvasHeight;
}
+(NSRect)getCanvasRect {
	return [self sharedManager].canvasRect;
}
+(NSRect)getVisibleCanvasRect {
	return [[self sharedManager] visibleCanvasRect];
}
+(NSPoint)getMousePos {
	return [self sharedManager].mousePos;
}
+(NSUInteger)getMouseButton {
	return [self sharedManager].mouseButton;
}
+(CGFloat)getFrameRate {
	return [self sharedManager].frameRate;
}
+(NSUInteger)getFrameCount {
	return [self sharedManager].frameCount;
}

-(void)enterFullScreen {
	[[NSNotificationCenter defaultCenter] postNotificationName:FULLSCREEN object:self];
	[self enterFullScreenMode:[NSScreen mainScreen] withOptions:fullScreenOptions];
	[self removeTrackingArea:[[self trackingAreas] objectAtIndex:0]];
	[self addTrackingArea];
	canvasSize = screenSize;
	canvasHeight = canvasSize.height;
	canvasWidth = canvasSize.width;
}

-(void)exitFullScreen {
	[[NSNotificationCenter defaultCenter] postNotificationName:FULLSCREEN object:self];
	[self exitFullScreenModeWithOptions:fullScreenOptions];
	[self removeTrackingArea:[[self trackingAreas] objectAtIndex:0]];
	[self addTrackingArea];
	canvasSize = self.visibleRect.size;
	canvasHeight = canvasSize.height;
	canvasWidth = canvasSize.width;
}

-(void)borderlessWindow {
    [self.window setStyleMask:NSBorderlessWindowMask];
}

-(void)borderedWindow {
    [self.window setStyleMask:NSTitledWindowMask];
    [self windowTitle:self.appName];
}

-(void)toggleBorderlessWindow {
    if([self.window styleMask] == NSBorderlessWindowMask) {
        [self borderedWindow];
    } else {
        [self borderlessWindow];
    }
}

-(void)windowTitle:(id)title {
    [self.window setTitle:[C4String nsStringFromObject:title]];  
}

-(NSRect)visibleCanvasRect {
    NSRect visibleRect = [self visibleRect];
    visibleRect.origin = self.window.frame.origin;
    visibleRect.origin.y += 22;
    return visibleRect;
}

#pragma mark Background 
-(void)background:(float)grey {
	[self backgroundRed:grey green:grey blue:grey alpha:1.0f];
}

-(void)background:(float)grey alpha:(float)alpha {
	[self backgroundRed:grey green:grey blue:grey alpha:alpha];
}

-(void)backgroundRed:(float)red green:(float)green blue:(float)blue {
	[self backgroundRed:red green:green blue:blue alpha:1.0f];
}

-(void)backgroundRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha{
	[self setBackgroundColor:[C4Color colorWithRed:red green:green blue:blue alpha:alpha]];
	backgroundShouldDraw = YES;
}

-(void)backgroundColor:(id)color {
	if([color isKindOfClass:[C4Color class]]) {
		[self setBackgroundColor:(C4Color*)color];
	}
	else if([color isKindOfClass:[NSColor class]]) {
		[self setBackgroundColor:[C4Color colorWithNSColor:(NSColor *)color]];
	}
	backgroundShouldDraw = YES;
}

-(void)backgroundImage:(C4Image*)bgImage {
    [self background:0];
    [bgImage setImageMode:CORNER];
	[bgImage drawAt:NSZeroPoint withWidth:canvasWidth andHeight:canvasHeight];
}

-(void)drawBackground {
    glClear(GL_COLOR_BUFFER_BIT);
	[[self backgroundColor] set];
	[NSBezierPath fillRect:backgroundRect];
	if(drawToPDF){
		CGFloat components[4];
		[[[self backgroundColor] nsColor] getRed:&components[0] green:&components[1] blue:&components[2] alpha:&components[3]];
		CGContextSetRGBFillColor(pdfContext,components[0],components[1],components[2],components[3]);
		CGContextFillRect(pdfContext, NSRectToCGRect(backgroundRect));
	}
}

#pragma mark Input
-(void)keyPressed {
}

-(void)keyReleased {
}

-(void)keyDown:(NSEvent *)theEvent {
    [[NSNotificationCenter defaultCenter] postNotificationName:KEYPRESSED object:self userInfo:[NSDictionary dictionaryWithObject:theEvent forKey:@"keyEvent"]];

	keyCode = [theEvent keyCode];
	keyChar = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
	keyIsPressed = YES;
	if(currentDrawStyle == EVENTBASED) [self redraw];
	[self keyPressed];
}

-(void)keyUp:(NSEvent *)theEvent {
	keyIsPressed = NO;
	if(currentDrawStyle == EVENTBASED) [self redraw];
	[self keyReleased];
}

-(void)mousePressed {
}

-(void)mouseReleased {
}

-(void)mouseDragged {
}

-(void)mouseClicked {
}

-(void)mouseDoubleClicked {
}

-(void)mouseMoved{
}

-(void)mouseMoved:(NSEvent *)theEvent {
	[[NSNotificationCenter defaultCenter] postNotificationName:MOUSEMOVED object:self userInfo:[NSDictionary dictionaryWithObject:theEvent forKey:@"mouseEvent"]];
	prevMousePos = mousePos;
	mousePos = [theEvent locationInWindow];
	if([self isFlipped]) {
		mousePos.y *= -1;
		mousePos.y += self.visibleRect.size.height;
	}
	if (currentDrawStyle == EVENTBASED) [self redraw];
	[self mouseMoved];
}

-(void)mouseDown:(NSEvent *)theEvent {
	[[NSNotificationCenter defaultCenter] postNotificationName:MOUSEPRESSED object:self userInfo:[NSDictionary dictionaryWithObject:theEvent forKey:@"mouseEvent"]];
	mouseButton = MOUSELEFT;
	mouseIsPressed = YES;
	if(currentDrawStyle == EVENTBASED) [self redraw];
	[self mousePressed];
}

-(void)mouseDragged:(NSEvent *)theEvent {
	[[NSNotificationCenter defaultCenter] postNotificationName:MOUSEDRAGGED object:self userInfo:[NSDictionary dictionaryWithObject:theEvent forKey:@"mouseEvent"]];
	prevMousePos = mousePos;
	mousePos = [theEvent locationInWindow];
	if([self isFlipped]) {
		mousePos.y *= -1;
		mousePos.y += self.visibleRect.size.height;
	}
	if(currentDrawStyle == EVENTBASED) [self redraw];
	[self mouseDragged];
}

-(void)mouseUp:(NSEvent *)theEvent {
	[[NSNotificationCenter defaultCenter] postNotificationName:MOUSERELEASED object:self userInfo:[NSDictionary dictionaryWithObject:theEvent forKey:@"mouseEvent"]];
	[self checkClickCount:theEvent];
	mouseButton = NOMOUSE;
	mouseIsPressed = NO;
	if(currentDrawStyle == EVENTBASED) [self redraw];
	[self mouseReleased];
}

-(void)rightMouseDown:(NSEvent *)theEvent {
	mouseButton = MOUSERIGHT;
	mouseIsPressed = YES;
	if(currentDrawStyle == EVENTBASED) [self redraw];
	[self mousePressed];
}

-(void)rightMouseUp:(NSEvent *)theEvent {
	[self checkClickCount:theEvent];
	mouseButton = NOMOUSE;
	mouseIsPressed = NO;
	if(currentDrawStyle == EVENTBASED) [self redraw];
	[self mouseReleased];
}

-(void)otherMouseDown:(NSEvent *)theEvent {
	//[[NSNotificationCenter defaultCenter] postNotificationName: object:self];
	mouseButton = ([theEvent buttonNumber] == 2) ? MOUSECENTER : (int)[theEvent buttonNumber];
	mouseIsPressed = YES;
	if(currentDrawStyle == EVENTBASED) [self redraw];
	[self mousePressed];
}

-(void)otherMouseUp:(NSEvent *)theEvent {
	//[[NSNotificationCenter defaultCenter] postNotificationName: object:self];
	[self checkClickCount:theEvent];
	mouseButton = NOMOUSE;
	mouseIsPressed = NO;
	if(currentDrawStyle == EVENTBASED) [self redraw];
	[self mouseReleased];
}

-(void)checkClickCount:(NSEvent*)theEvent {
	if ([theEvent clickCount] == 2) {
		[self mouseDoubleClicked];
	} else if ([theEvent clickCount] == 1) {
		[self mouseClicked];
	}
}

#pragma mark Output

-(void)setupPDF {
	drawToPDF = YES;
	isClean = NO;
    
	NSString *path = nil;
	NSArray	*paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES);
	if([paths count]) {		
		path = [paths objectAtIndex:0];
		path = [path stringByAppendingPathComponent:self.appName];
		
		BOOL isDir;
		NSFileManager *defaultManager = [NSFileManager defaultManager];
		[defaultManager fileExistsAtPath:path isDirectory:&isDir];
		if (!isDir) {
			[defaultManager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
		}
		
		NSDateFormatter *format = [[[NSDateFormatter alloc] init] autorelease];
		[format setDateFormat:@"MMddYY(hhmmss)"];
        
		NSString *fileName = [NSString stringWithFormat:@"%@-%@.pdf",appName,[format stringFromDate:[NSDate date]]];
		pdfURL = (CFURLRef)[NSURL fileURLWithPath:[path stringByAppendingPathComponent:fileName]];
		CFRetain(pdfURL);
		NSMutableData *data = [[[NSMutableData alloc] init] autorelease];
		pdfConsumer = CGDataConsumerCreateWithCFData((CFMutableDataRef)data);
		CGDataConsumerRetain(pdfConsumer);
		CGRect bounds = CGRectMake(0, 0, canvasWidth, canvasHeight);
		pdfContext = CGPDFContextCreateWithURL(pdfURL, &bounds, NULL);
		CGContextRetain(pdfContext);
		CGContextBeginPage(pdfContext, &bounds);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGContextSetFillColorSpace(pdfContext,colorSpace);
		[C4Shape beginDrawShapesToPDFContext:pdfContext];
		[C4String beginDrawStringsToPDFContext:pdfContext];
        CFRelease(colorSpace);
	}
}

-(void)endPDF {
	drawToPDF = NO;
	[C4Shape endDrawShapesToPDFContext];
	[C4String endDrawStringsToPDFContext];
	CGContextEndPage(pdfContext);
	CGPDFContextClose(pdfContext);
	CGDataConsumerRelease(pdfConsumer);
	CFRelease(pdfURL);
	isClean = YES;
}

#pragma mark Screen Shots
-(void)saveScreenShot{
    [self saveScreenShotFromRect:NSRectFromCGRect(CGRectInfinite)];
}

-(void)saveCanvasShot{
    [self saveScreenShotFromRect:[self visibleCanvasRect]];
}

/*
 Add a screenImage & canvasImage function between screenshot & screenShotFromRect
 */

-(C4Image *)screenShot {
    return [C4Image imageWithCGImage:[self screenImageFromRect:[self visibleCanvasRect]]];
}

-(C4Image *)screenShotFromRect:(NSRect)aRect {
    return [C4Image imageWithCGImage:[self screenImageFromRect:aRect]];
}

-(C4Image *)canvasShot {
    return [C4Image imageWithCGImage:[self screenImageFromRect:NSRectFromCGRect(CGRectInfinite)]];
    
}

-(CGImageRef)screenImageFromRect:(NSRect)aRect {
    CGRect aCGRect = NSRectToCGRect(aRect);
    CGImageRef image = (CGImageRef)[(id)CGWindowListCreateImage(aCGRect, kCGWindowListOptionOnScreenOnly, kCGNullWindowID, kCGWindowImageDefault) autorelease];
    return image;
}

-(void)saveScreenShotFromRect:(NSRect)aRect{
    CGImageRef imageRef = [self screenImageFromRect:aRect];
    NSAssert( imageRef != 0, @"cgImageFromPixelBuffer failed");
    
    // Make full pathname to the desktop directory
    NSString *desktopDirectory = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDesktopDirectory, NSUserDomainMask, YES);
    if ([paths count] > 0)  
    {
        desktopDirectory = [paths objectAtIndex:0];
    }
    
    NSMutableString *fullFilePathStr = [NSMutableString stringWithString:desktopDirectory];
    NSAssert( fullFilePathStr != nil, @"stringWithString failed");
    NSDateFormatter *format = [[[NSDateFormatter alloc] init] autorelease];
    [format setDateFormat:@"MM-dd-YY(HH.mm.ss)"];
    
    NSString *formattedDate = [format stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"/%@-%@.tiff",self.appName,formattedDate];
    
    [fullFilePathStr appendString:fileName];
    
    NSString *finalPath = [NSString stringWithString:fullFilePathStr];
    NSAssert( finalPath != nil, @"stringWithString failed");
    
    CFURLRef url = CFURLCreateWithFileSystemPath (
                                                  kCFAllocatorDefault,
                                                  (CFStringRef)finalPath,
                                                  kCFURLPOSIXPathStyle,
                                                  false);
    NSAssert( url != 0, @"CFURLCreateWithFileSystemPath failed");
    
    // Save the image to the file
    CGImageDestinationRef dest = CGImageDestinationCreateWithURL(url, CFSTR("public.tiff"), 1, nil);
    NSAssert( dest != 0, @"CGImageDestinationCreateWithURL failed");
    
    // Set the image in the image destination to be `image' with
    // optional properties specified in saved properties dict.
    CGImageDestinationAddImage(dest, imageRef, nil);
    
    bool success = CGImageDestinationFinalize(dest);
    NSAssert( success != 0, @"Image could not be written successfully");
    
    CFRelease(dest);
    CFRelease(url);
}

#pragma mark OPENGL
-(void)prepareOpenGL {
    [[self openGLContext] makeCurrentContext];
    
    // Synchronize buffer swaps with vertical refresh rate
    GLint swapInt = 1;
    [[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval]; 
    
	
    GLint opacity = 0;
	[[self openGLContext] setValues:&opacity forParameter:NSOpenGLCPSurfaceOpacity];	
	readyToDraw = YES;
}

#pragma mark Singleton

-(id) init
{
    if((self = [super init]))
    {
    }
    
    return self;
}

+ (C4OpenGLView*)sharedManager
{
    if (sharedC4OpenGLView == nil) {
        static dispatch_once_t once;
        dispatch_once(&once, ^ { sharedC4OpenGLView = [[super allocWithZone:NULL] init]; });
        return sharedC4OpenGLView;

        
    }
    return sharedC4OpenGLView;
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