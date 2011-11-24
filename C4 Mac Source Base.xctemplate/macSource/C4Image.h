//
//  C4Image.h
//  Created by Travis Kirton
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface C4Image : C4Object {
	@private
	CIContext *filterContext;
	NSSize imageSize;
	NSRect imageRect;
	CGFloat imageHeight, imageWidth;
	unsigned char *rawData;
	CIImage *originalImage, *filteredImage;
	BOOL singleFilter, drawFilteredImage;
	NSInteger bytesPerPixel,imageMode;
}


+(C4Image *)imageName:(NSString *)name;
+(C4Image *)imageName:(NSString *)name andType:(NSString *)type;
+(C4Image *)imageWithCGImage:(CGImageRef)image;

-(id)initWithImage:(C4Image *)image;
-(id)initWithImageName:(NSString *)name;
-(id)initWithImageName:(NSString *)name andType:(NSString *)type;
-(id)initWithCGImage:(CGImageRef)image;

-(void)drawAt:(NSPoint)p;
-(void)drawAt:(NSPoint)p withAlpha:(float)alpha;
-(void)drawAt:(NSPoint)p withWidth:(float)w andHeight:(float)h;
-(void)drawAt:(NSPoint)p withWidth:(float)w andHeight:(float)h withAlpha:(float)a;
-(void)drawInRect:(NSRect)rect;
-(void)drawInRect:(NSRect)rect withAlpha:(CGFloat)alpha;

-(CGImageRef)cgImage;

-(C4Color *)colorAtX:(int)x andY:(int)y;
-(void)loadPixelData;

@property(readwrite,retain) CIImage *originalImage, *filteredImage;
@property(readonly) CGFloat imageWidth, imageHeight;
@property(readonly) NSSize imageSize;
@property(readonly) NSRect imageRect;
@property(readwrite, retain) CIContext *filterContext;
@property(readwrite) BOOL drawFilteredImage;
@property(readwrite, nonatomic) NSInteger imageMode;
@property(readonly) NSInteger bytesPerPixel;
@property(readonly) unsigned char *rawData;

/*
 Filters
NOT WORKING...
//	[backgroundImage opTile:mousePos scale:1.0f angle:PI/4 width:10];
//	[backgroundImage parallelogramTile:mousePos angle:PI acuteAngle:PI/3 width:10];
//[backgroundImage perspectiveTile:NSMakePoint(0, self.canvasHeight) 
//                        topRight:NSMakePoint(self.canvasWidth/2, self.canvasHeight/2) 
//                     bottomRight:NSMakePoint(self.canvasWidth/2, self.canvasHeight/3) 
//                      bottomLeft:NSZeroPoint];
//    	[backgroundImage triangleTile:mousePos angle:PI/2 width:100];

 */

-(void)singleFilter;
-(void)combinedFilter;

-(void)gaussianBlur:(CGFloat)radius;
-(void)motionBlur:(CGFloat)radius angle:(CGFloat)angle;
-(void)zoomBlur:(NSPoint)center amount:(CGFloat)amount;

-(void)kaleidoscope:(NSPoint)center count:(NSInteger)count angle:(CGFloat)angle;
-(void)opTile:(NSPoint)center scale:(CGFloat)scale angle:(CGFloat)angle width:(CGFloat)width;
-(void)parallelogramTile:(NSPoint)center angle:(CGFloat)angle acuteAngle:(CGFloat)acute width:(CGFloat)width;
-(void)perspectiveTile:(NSPoint)topLeft topRight:(NSPoint)topRight bottomRight:(NSPoint)bottomRight bottomLeft:(NSPoint)bottomLeft;
-(void)triangleTile:(NSPoint)center angle:(CGFloat)angle width:(CGFloat)width;

-(void)colorControls:(CGFloat)saturation brightness:(CGFloat)brightness contrast:(CGFloat)contrast;
-(void)exposureAdjust:(CGFloat)exposure;
-(void)gammaAdjust:(CGFloat)gamma;
-(void)hueAdjust:(CGFloat)hue;

-(void)invert;
-(void)monochrome:(C4Color *)color intensity:(CGFloat)intensity;
-(void)posterize:(CGFloat)intensity;
-(void)maxGrayscale;
-(void)minGrayscale;
-(void)sepia:(CGFloat)intensity;
-(void)tint:(C4Color *)color;

-(void)colorBlend:(C4Image *)backgroundImage;
-(void)burnBlend:(C4Image *)backgroundImage;
-(void)darkenBlend:(C4Image *)backgroundImage;
-(void)differenceBlend:(C4Image *)backgroundImage;
-(void)exclusionBlend:(C4Image *)backgroundImage;
-(void)hardLightBlend:(C4Image *)backgroundImage;
-(void)hueBlend:(C4Image *)backgroundImage;
-(void)lightenBlend:(C4Image *)backgroundImage;
-(void)luminosityBlend:(C4Image *)backgroundImage;
-(void)multiplyBlend:(C4Image *)backgroundImage;
-(void)overlayBlend:(C4Image *)backgroundImage;
-(void)saturationBlend:(C4Image *)backgroundImage;
-(void)screenBlend:(C4Image *)backgroundImage;
-(void)softLightBlend:(C4Image *)backgroundImage;

-(void)bumpDistortion:(NSPoint)center radius:(CGFloat)radius scale:(CGFloat)scale;
-(void)bumpLinearDistortion:(NSPoint)center radius:(CGFloat)radius angle:(CGFloat)angle scale:(CGFloat)scale;
-(void)circleDistortion:(NSPoint)center radius:(CGFloat)radius;
-(void)circularScreen:(NSPoint)center width:(CGFloat)width sharpness:(CGFloat)sharpness;
-(void)circularWrap:(NSPoint)center radius:(CGFloat)radius angle:(CGFloat)angle;
-(void)holeDistortion:(NSPoint)center radius:(CGFloat)radius;
-(void)twirlDistortion:(NSPoint)center radius:(CGFloat)radius angle:(CGFloat)angle;
-(void)vortexDistortion:(NSPoint)center radius:(CGFloat)radius angle:(CGFloat)angle;

-(void)dotScreen:(NSPoint)center angle:(CGFloat)angle width:(CGFloat)width sharpness:(CGFloat)sharpness;
-(void)hatchedScreen:(NSPoint)center angle:(CGFloat)angle width:(CGFloat)width sharpness:(CGFloat)sharpness;
-(void)lineScreen:(NSPoint)center angle:(CGFloat)angle width:(CGFloat)width sharpness:(CGFloat)sharpness;

-(void)blendWithMask:(C4Image *)backgroundImage maskImage:(C4Image *)maskImage;
-(void)bloom:(CGFloat)radius intensity:(CGFloat)intensity;
-(void)comicEffect;
-(void)crystallize:(NSPoint)center radius:(CGFloat)radius;
-(void)edges:(CGFloat)intensity;
-(void)edgeWork:(CGFloat)radius;
-(void)gloom:(CGFloat)radius intensity:(CGFloat)intensity;
-(void)hexagonalPixellate:(NSPoint)center scale:(CGFloat)scale;
-(void)pixellate:(NSPoint)center scale:(CGFloat)scale;
-(void)pointillize:(NSPoint)center radius:(CGFloat)radius;

@end