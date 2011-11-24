//
//  C4Movie.m
//  VideoCALayer
//
//  Created by moi on 11-04-10.
//  Copyright 2011 mediart. All rights reserved.
//

#import "C4Movie.h"
@interface C4Movie () {}
-(void)setupVisualContext:(CGLContextObj)glContext withPixelFormat:(CGLPixelFormatObj)pixelFormat;
@end

@implementation C4Movie

@synthesize movie;
+(C4Movie *)movieName:(id)aName {
    NSString *stringName = [C4String nsStringFromObject:aName];
	NSArray *nameComponents = [stringName componentsSeparatedByString:@"."];
	if([nameComponents count] == 2) {    
        return [self movieName:[nameComponents objectAtIndex:0]
                       andType:[nameComponents objectAtIndex:1]];
    }
    return nil;
}

+(C4Movie *)movieName:(id)aName andType:(id)aType {
    return [[[C4Movie alloc] initWithMovieName:aName andType:aType] retain];
}

-(id)initWithMovieName:(id)aName {
    NSString *stringName = [C4String nsStringFromObject:aName];
	NSArray *nameComponents = [stringName componentsSeparatedByString:@"."];
	if([nameComponents count] == 2) {    
        return [self initWithMovieName:[nameComponents objectAtIndex:0]
                               andType:[nameComponents objectAtIndex:1]];
    }
    return nil;
}

-(id)initWithMovieName:(id)aName andType:(id)aType {
    self = [super init];
    if(self) {
        [self setAsynchronous:YES];
        CGColorRef clear = CGColorCreateGenericRGB(0, 0, 0, 0);
        [self setBackgroundColor:clear];
        CFRelease(clear);
        
        NSString *moviePath = [[NSBundle mainBundle] pathForResource:aName ofType:aType];
        [self setMovie:[QTMovie movieWithFile:moviePath error:nil]];
        
        if(movie)
        {
            SetMoviePlayHints([movie quickTimeMovie],hintsHighQuality, hintsHighQuality);	
            [movie gotoBeginning];
            MoviesTask([movie quickTimeMovie], 0);        
        } else {
            return nil;
        }
        NSSize s = [[[movie movieAttributes] valueForKey:QTMovieNaturalSizeAttribute] sizeValue];
        [self setSize:s];
        [self setLocation:NSZeroPoint];
        [self rectMode:CORNER];

        [[[C4Canvas sharedManager].window contentView] setWantsLayer:YES];
        [[[[C4Canvas sharedManager].window contentView] layer] addSublayer:self];
        return self;
    }
    return nil;
}

- (BOOL)canDrawInCGLContext:(CGLContextObj)glContext 
                pixelFormat:(CGLPixelFormatObj)pixelFormat 
               forLayerTime:(CFTimeInterval)timeInterval 
                displayTime:(const CVTimeStamp *)timeStamp
{ 
    // There is no point in trying to draw anything if our
    // movie is not playing.
    if( [movie rate] <= 0.0 )
        return NO;
    
    if( !qtVisualContext )
    {
        // If our visual context for our QTMovie has not been set up
        // we initialize it now
        [self setupVisualContext:glContext withPixelFormat:pixelFormat];
    }
    
    // Check to see if a new frame (image) is ready to be draw at
    // the time specified.
    if(QTVisualContextIsNewImageAvailable(qtVisualContext,timeStamp))
    {
        // Release the previous frame
        CVOpenGLTextureRelease(currentFrame);
        
        // Copy the current frame into our image buffer
        QTVisualContextCopyImageForTime(qtVisualContext,
                                        NULL,
                                        timeStamp,
                                        &currentFrame);
        
        // Returns the texture coordinates for the 
        // part of the image that should be displayed
        CVOpenGLTextureGetCleanTexCoords(currentFrame, 
                                         lowerLeft, 
                                         lowerRight, 
                                         upperRight, 
                                         upperLeft);
        return YES;
    }
    
    return NO;
} 


- (void)drawInCGLContext:(CGLContextObj)glContext 
             pixelFormat:(CGLPixelFormatObj)pixelFormat 
            forLayerTime:(CFTimeInterval)interval 
             displayTime:(const CVTimeStamp *)timeStamp
{
    NSRect bounds = NSRectFromCGRect([self bounds]);
    
    GLfloat minX, minY, maxX, maxY;        
    
    minX = NSMinX(bounds);
    minY = NSMinY(bounds);
    maxX = NSMaxX(bounds);
    maxY = NSMaxY(bounds);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho( minX, maxX, minY, maxY, -1.0, 1.0);
    
    glClearColor(0.0, 0.0, 0.0, 0.0);	     
    glClear(GL_COLOR_BUFFER_BIT);
    
    CGRect imageRect = [self frame];
    imageRect.origin.x = 0;
    imageRect.origin.y = 0;
    // Enable target for the current frame
    glEnable(CVOpenGLTextureGetTarget(currentFrame));
    
    // Bind to the current frame
    // This tells OpenGL which texture we are wanting 
    // to draw so that when we make our glTexCord and 
    // glVertex calls, our current frame gets drawn
    // to the context.
    glBindTexture(CVOpenGLTextureGetTarget(currentFrame), 
                  CVOpenGLTextureGetName(currentFrame));
    glMatrixMode(GL_TEXTURE);
    glLoadIdentity();
    glColor4f(1.0, 1.0, 1.0, 1.0);
    glBegin(GL_QUADS);
    
    // Draw the quads
    glTexCoord2f(upperLeft[0], upperLeft[1]);
    glVertex2f  (imageRect.origin.x, 
                 imageRect.origin.y + imageRect.size.height);
    glTexCoord2f(upperRight[0], upperRight[1]);
    glVertex2f  (imageRect.origin.x + imageRect.size.width, 
                 imageRect.origin.y + imageRect.size.height);
    glTexCoord2f(lowerRight[0], lowerRight[1]);
    glVertex2f  (imageRect.origin.x + imageRect.size.width, 
                 imageRect.origin.y);
    glTexCoord2f(lowerLeft[0], lowerLeft[1]);
    glVertex2f  (imageRect.origin.x, imageRect.origin.y);
    
    glEnd();
    
    // This CAOpenGLLayer is responsible to flush
    // the OpenGL context so we call super
    [super drawInCGLContext:glContext 
                pixelFormat:pixelFormat 
               forLayerTime:interval 
                displayTime:timeStamp];
    
    // Task the context
	QTVisualContextTask(qtVisualContext);
    
}

- (void)setupVisualContext:(CGLContextObj)glContext 
           withPixelFormat:(CGLPixelFormatObj)pixelFormat;
{    
    NSDictionary	    *attributes = nil;
    attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                  [NSDictionary dictionaryWithObjectsAndKeys:
                   [NSNumber numberWithFloat:[self frame].size.width],
                   kQTVisualContextTargetDimensions_WidthKey,
                   [NSNumber numberWithFloat:[self frame].size.height],
                   kQTVisualContextTargetDimensions_HeightKey, nil], 
                  kQTVisualContextTargetDimensionsKey, 
                  [NSDictionary dictionaryWithObjectsAndKeys:
                   [NSNumber numberWithFloat:[self frame].size.width], 
                   kCVPixelBufferWidthKey, 
                   [NSNumber numberWithFloat:[self frame].size.height], 
                   kCVPixelBufferHeightKey, nil], 
                  kQTVisualContextPixelBufferAttributesKey,
                  nil];
    
    // Create our quicktimee visual context
   QTOpenGLTextureContextCreate(NULL,
                                         glContext,
                                         pixelFormat,
                                         (CFDictionaryRef)attributes,
                                         &qtVisualContext);
    
    // Associate it with our movie.
    SetMovieVisualContext([movie quickTimeMovie],qtVisualContext);
}

- (CGLContextObj)copyCGLContextForPixelFormat:(CGLPixelFormatObj)pixelFormat;
{
	SetMovieVisualContext([movie quickTimeMovie], 0);
	QTVisualContextRelease(qtVisualContext);
	qtVisualContext = 0;
	return [super copyCGLContextForPixelFormat:pixelFormat];    
}

-(void)eject {
    [self stop];
    [self removeFromSuperlayer];
}

- (void) dealloc
{
    self.movie = nil;
	CVOpenGLTextureRelease(currentFrame);
	QTVisualContextRelease(qtVisualContext);
	qtVisualContext = 0;
	[super dealloc];
}

-(void)setHeight:(CGFloat)height {
    CGSize newSize = self.bounds.size;
    newSize.height = height;
    [self setSize:NSSizeFromCGSize(newSize)];
}

-(void)setWidth:(CGFloat)width {
    CGSize newSize = self.bounds.size;
    newSize.width = width;
    [self setSize:NSSizeFromCGSize(newSize)];
}

-(void)setWidth:(CGFloat)width andHeight:(CGFloat)height {
    [self setSize:NSMakeSize(width, height)];
}

-(void)rectMode:(NSInteger)mode {
    switch (mode) {
        case CORNER:
            [self setAnchorPoint:CGPointMake(0, 0)];
            break;
        case CENTER:
            [self setAnchorPoint:CGPointMake(0.5, 0.5)];
            break;
        default:
            NSLog(@"movie rect mode must be CENTER or CORNER");
            break;
    }
}

-(void)setSize:(NSSize)newSize {
    newSize.width = newSize.width > 10.0f ? newSize.width : 10.0f;
    newSize.height = newSize.height > 10.0f ? newSize.height : 10.0f;

    // Prepare the animation from the old size to the new size
    CGRect oldBounds = self.bounds;
    CGRect newBounds = oldBounds;
    newBounds.size = NSSizeToCGSize(newSize);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    
    // NSValue/+valueWithRect:(NSRect)rect is available on Mac OS X
    // NSValue/+valueWithCGRect:(CGRect)rect is available on iOS
    // comment/uncomment the corresponding lines depending on which platform you're targeting
    
    // Mac OS X
    animation.fromValue = [NSValue valueWithRect:NSRectFromCGRect(oldBounds)];
    animation.toValue = [NSValue valueWithRect:NSRectFromCGRect(newBounds)];
    // iOS
    //animation.fromValue = [NSValue valueWithCGRect:oldBounds];
    //animation.toValue = [NSValue valueWithCGRect:newBounds];
    animation.duration = 0.001;
    
    // Update the layer's bounds so the layer doesn't snap back when the animation completes.
    self.bounds = newBounds;
    
    // Add the animation, overriding the implicit animation.
    [self addAnimation:animation forKey:@"bounds"];
}

-(void)setX:(CGFloat)x {
    CGPoint newPosition = self.position;
    newPosition.x = x;
    [self setLocation:NSPointFromCGPoint(newPosition)];
} 

-(void)setY:(CGFloat)y {
    CGPoint newPosition = self.position;
    newPosition.y = y;
    [self setLocation:NSPointFromCGPoint(newPosition)];
} 

-(void)setX:(CGFloat)x andY:(CGFloat)y {
    [self setLocation:NSMakePoint(x, y)];
}

-(void)setLocation:(NSPoint)point
{
    // Prepare the animation from the current position to the new position
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [self valueForKey:@"position"];
    
    // NSValue/+valueWithPoint:(NSPoint)point is available on Mac OS X
    // NSValue/+valueWithCGPoint:(CGPoint)point is available on iOS
    // comment/uncomment the corresponding lines depending on which platform you're targeting
    
    // Mac OS X
    animation.toValue = [NSValue valueWithPoint:point];
    // iOS
    //animation.toValue = [NSValue valueWithCGPoint:point];
    animation.duration = 0.001;
    
    // Update the layer's position so that the layer doesn't snap back when the animation completes.
    self.position = NSPointToCGPoint(point);
    
    // Add the animation, overriding the implicit animation.
    [self addAnimation:animation forKey:@"position"];
}

-(void)setX:(CGFloat)x andY:(CGFloat)y withWidth:(CGFloat)width andHeight:(CGFloat)height{
    [self setLocation:NSMakePoint(x, y)];
    [self setSize:NSMakeSize(width, height)];
}

-(void)play {
    [movie play];
}
-(void)stop {
    [movie stop];
}
-(void)goToBeginning {
    [movie gotoBeginning];
}

-(CGFloat)rate {
    return (CGFloat)[movie rate];
}
-(void)setRate:(CGFloat)newRate {
    [movie setRate:newRate];
}

-(CGFloat)volume {
    return (CGFloat)[movie volume];
}

-(void)setVolume:(CGFloat)newVolume {
    newVolume = [C4Math constrainf:newVolume min:0 max:1];
    [movie setRate:newVolume];
}

-(CGFloat)movieLength {
    QTTime length = [movie duration];
    return (CGFloat)(length.timeValue/length.timeScale);
}

-(void)setLoops:(BOOL)loops {
    [movie setAttribute:[NSNumber numberWithBool:loops] forKey:QTMovieLoopsAttribute];
}

-(BOOL)muted {
    return [movie muted];
}

-(void)setMuted:(BOOL)mute {
    [movie setMuted:mute];
}

-(void)goToTime:(CGFloat)aTime {
    QTTime newTime = [movie currentTime];
    
    newTime.timeValue = (long long)(aTime * newTime.timeScale);
    [movie setCurrentTime:newTime];
}

-(void)moveLayerDown {
    [self setZPosition:self.zPosition-1];
}

-(void)moveLayerUp {
    [self setZPosition:self.zPosition+1];
}

-(void)moveBelow:(CALayer *)anotherLayer {
    self.zPosition = anotherLayer.zPosition-1;
}

-(void)moveAbove:(CALayer *)anotherLayer {
    self.zPosition = anotherLayer.zPosition+1;
}
@end
