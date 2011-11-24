//
//  C4Image.m
//  Created by Travis Kirton
//

#import "C4Image.h"
@interface C4Image () {}
-(void)drawFilteredImageAt:(NSPoint)p;
-(void)drawFilteredImageInRect:(NSRect)aRect;
@end


@implementation C4Image

@synthesize originalImage, filteredImage, imageWidth, imageHeight, imageSize, imageRect, imageMode, drawFilteredImage, filterContext, rawData, bytesPerPixel;

+(void)load {
	if(VERBOSELOAD) printf("C4Image\n");
}

-(id)init {
	if (![super init]) {
		return nil;
	}
	self.originalImage = [CIImage emptyImage];
	imageRect = NSRectFromCGRect([originalImage extent]);
	filterContext = [[CIContext contextWithCGContext:[[NSGraphicsContext currentContext] graphicsPort]
											 options:nil] retain];
	singleFilter = YES;
    imageMode = CORNER;
	return self;
}

-(id)initWithImage:(C4Image *)image {
	[self setOriginalImage:image.originalImage];
	imageRect = NSRectFromCGRect([originalImage extent]);
	filterContext = [[CIContext contextWithCGContext:[[NSGraphicsContext currentContext] graphicsPort]
									  options:nil] retain];
	singleFilter = YES;
    imageMode = CORNER;
	return self;
}

-(id)initWithImageName:(NSString *)name {
	NSArray *nameComponents = [name componentsSeparatedByString:@"."];
	if([nameComponents count] == 2) [self initWithImageName:[nameComponents objectAtIndex:0]
													andType:[nameComponents objectAtIndex:1]];
	return nil;
}

-(id)initWithImageName:(NSString *)name andType:(NSString *)type{
	NSString *   path = [[NSBundle mainBundle] pathForResource:name
														ofType:type];
	NSURL *      url = [NSURL fileURLWithPath: path];
	
	self.originalImage = [CIImage imageWithContentsOfURL:url];
	imageRect = NSRectFromCGRect([originalImage extent]);
	[self setFilterContext:[CIContext contextWithCGContext:[[NSGraphicsContext currentContext] graphicsPort]
												   options:nil]];
	singleFilter = YES;
    imageMode = CORNER;
	return self;
}

-(id)initWithCGImage:(CGImageRef)image {
	self.originalImage = [CIImage imageWithCGImage:image];
	imageRect = NSRectFromCGRect([originalImage extent]);
	[self setFilterContext:[CIContext contextWithCGContext:[[NSGraphicsContext currentContext] graphicsPort]
												   options:nil]];
	singleFilter = YES;
    imageMode = CORNER;
	return self;
}

-(void)dealloc {
	free(rawData);
	
	[self setFilterContext:nil];
	[self setOriginalImage:nil];
	[self setFilteredImage:nil];
	[super dealloc];
}

+(C4Image *)imageName:(NSString *)name {
	NSArray *nameComponents = [name componentsSeparatedByString:@"."];
	if([nameComponents count] == 2) return [[C4Image imageName:[nameComponents objectAtIndex:0]
													   andType:[nameComponents objectAtIndex:1]] retain];
	return nil;
}

+(C4Image *)imageName:(NSString *)name andType:(NSString *)type {
	return [[[C4Image alloc] initWithImageName:name andType:type] retain];
}

+(C4Image *)imageWithCGImage:(CGImageRef)image {
    return [[[C4Image alloc] initWithCGImage:image] retain];
}

-(void)loadPixelData {
	NSBitmapImageRep* rep = [[[NSBitmapImageRep alloc] initWithCIImage:originalImage] autorelease];
	
	// First get the image into your data buffer
	CGImageRef imageRef = [rep CGImage];
	NSInteger w = CGImageGetWidth(imageRef);
	NSInteger h = CGImageGetHeight(imageRef);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	rawData = malloc(h * w * 4);
	bytesPerPixel = 4;
	NSInteger bytesPerRow = bytesPerPixel * w;
	NSInteger bitsPerComponent = 8;
	CGContextRef context = CGBitmapContextCreate(rawData, w, h,
												 bitsPerComponent, bytesPerRow, colorSpace,
												 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	CGColorSpaceRelease(colorSpace);
	
	CGContextDrawImage(context, CGRectMake(0, 0, w, h), imageRef);
	CGContextRelease(context);
}

-(C4Color *)colorAtX:(int)x andY:(int)y {
    if(rawData == nil) [self loadPixelData];
    if(rawData != nil) {
	// inverting the y coordinate (a hack, but it works)
	// might be better to invert the pixels when the loadPixelData method is called
	int byteIndex = (bytesPerPixel * self.imageWidth * (self.imageHeight-y-1)) + x * bytesPerPixel;
	CGFloat red   = (rawData[byteIndex]     * 1.0) / 255.0;
	CGFloat green = (rawData[byteIndex + 1] * 1.0) / 255.0;
	CGFloat blue  = (rawData[byteIndex + 2] * 1.0) / 255.0;
	CGFloat alpha = (rawData[byteIndex + 3] * 1.0) / 255.0;
	
	return [C4Color colorWithRed:red green:green blue:blue alpha:alpha];
    }
    return nil;
}

-(CGFloat)imageWidth {
	return imageRect.size.width;
}

-(CGFloat)imageHeight {
	return imageRect.size.height;
}

-(void)drawAt:(NSPoint)p {
    [self drawAt:p withAlpha:1.0f];
}

-(void)drawAt:(NSPoint)p withAlpha:(float)alpha{
	if(!drawFilteredImage) {
        if (imageMode == CENTER) {
            p.x -= imageRect.size.width/2;
            p.y -= imageRect.size.height/2;
        }
		[originalImage drawAtPoint:p fromRect:imageRect operation:NSCompositeSourceOver fraction:alpha];
	}
	else {
        NSRect filteredImageRect = NSRectFromCGRect([filteredImage extent]);
        if (imageMode == CENTER) {
            p.x -= filteredImageRect.size.width/2;
            p.y -= filteredImageRect.size.height/2;
        }
		[filteredImage drawAtPoint:p fromRect:filteredImageRect operation:NSCompositeSourceOver fraction:alpha];
	}
}

-(void)drawAt:(NSPoint)p withWidth:(float)w andHeight:(float)h {
    [self drawAt:p withWidth:w andHeight:h withAlpha:1.0f];
}

-(void)drawAt:(NSPoint)p withWidth:(float)w andHeight:(float)h withAlpha:(float)a{
    NSRect r = NSMakeRect(p.x, p.y, w, h);
    [self drawInRect:r withAlpha:a];
}

-(void)drawInRect:(NSRect)rect {
	[self drawInRect:rect withAlpha:1.0f];
}

-(void)drawInRect:(NSRect)rect withAlpha:(CGFloat)alpha{
    if (imageMode == CENTER) {
        rect.origin.x -= rect.size.width/2;
        rect.origin.y -= rect.size.height/2;
    }
	if(!drawFilteredImage) {
		[originalImage drawInRect:rect
                         fromRect:imageRect 
                        operation:NSCompositeSourceOver 
                         fraction:alpha];
	}
	else {
		[filteredImage drawInRect:rect 
                         fromRect:NSRectFromCGRect([filteredImage extent]) 
                        operation:NSCompositeSourceOver 
                         fraction:alpha];
	}
}

-(void)setImageMode:(NSInteger)mode {
    if(mode == CORNER || mode == CENTER)
        imageMode = mode;
}

/*
 Filters
 */

-(void)drawFilteredImageAt:(NSPoint)p {
	
	[filterContext drawImage:filteredImage
					 atPoint:NSPointToCGPoint(p)
					fromRect:NSRectToCGRect(NSIntersectionRect(self.imageRect,[C4Canvas getCanvasRect]))];
}

-(void)drawFilteredImageInRect:(NSRect)aRect {
}

-(void)singleFilter {
	singleFilter = YES;
	self.filteredImage = nil;
}

-(void)combinedFilter {
	singleFilter = NO;
	self.filteredImage = [originalImage copy];
}

/*
 CIFilter *filter = [CIFilter filterWithName:];
 [filter setDefaults];
 if(singleFilter) {
 [filter setValue:originalImage forKey:@"inputImage"];
 } else {
 [filter setValue:filteredImage forKey:@"inputImage"];
 }
 
 [filter setValue: forKey:@""];
 filteredImage = [filter valueForKey: @"outputImage"];
*/

-(CGImageRef)cgImage {
    CGImageRef returnImage;
    if(singleFilter) {
        NSBitmapImageRep* rep =
        [[[NSBitmapImageRep alloc] initWithCIImage:originalImage] autorelease];
        returnImage = rep.CGImage;
    } else {
        NSBitmapImageRep* rep =
        [[[NSBitmapImageRep alloc] initWithCIImage:filteredImage] autorelease];
        returnImage = rep.CGImage;
    }
    return returnImage;
}

#pragma mark BLUR FILTERS
-(void)gaussianBlur:(CGFloat)radius {
	CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}

	[filter setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}

-(void)motionBlur:(CGFloat)radius angle:(CGFloat)angle {
	CIFilter *filter = [CIFilter filterWithName:@"CIMotionBlur"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
	[filter setValue:[NSNumber numberWithFloat:angle] forKey:@"inputAngle"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
	
}

-(void)zoomBlur:(NSPoint)center amount:(CGFloat)amount {
	CIFilter *filter = [CIFilter filterWithName:@"CIZoomBlur"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:[CIVector vectorWithX:center.x Y:center.y] forKey:@"inputCenter"];
	[filter setValue:[NSNumber numberWithFloat:amount] forKey:@"inputAmount"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}

#pragma mark TILE FILTERS
-(void)kaleidoscope:(NSPoint)center count:(NSInteger)count angle:(CGFloat)angle {
	CIFilter *filter = [CIFilter filterWithName:@"CIKaleidoscope"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	count = [C4Math constrain:(int)count min:1 max:64];
	[filter setValue:[NSNumber numberWithInteger:count] forKey:@"inputCount"];
	[filter setValue:[CIVector vectorWithX:center.x Y:center.y] forKey:@"inputCenter"];
	[filter setValue:[NSNumber numberWithFloat:angle] forKey:@"inputAngle"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)opTile:(NSPoint)center scale:(CGFloat)scale angle:(CGFloat)angle width:(CGFloat)width {
    if(center.x < 1 && center.y < 1) center = NSMakePoint(1, 1);
	CIFilter *filter = [CIFilter filterWithName:@"CIOpTile"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:[CIVector vectorWithX:center.x Y:center.y] forKey:@"inputCenter"];
	if(scale < 0.0f) scale = 0.01f;
	[filter setValue:[NSNumber numberWithFloat:scale] forKey:@"inputScale"];
	[filter setValue:[NSNumber numberWithFloat:angle] forKey:@"inputAngle"];
	[filter setValue:[NSNumber numberWithFloat:width] forKey:@"inputWidth"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)parallelogramTile:(NSPoint)center angle:(CGFloat)angle acuteAngle:(CGFloat)acute width:(CGFloat)width{
	CIFilter *filter = [CIFilter filterWithName:@"CIParallelogramTile"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:[CIVector vectorWithX:center.x Y:center.y] forKey:@"inputCenter"];
	[filter setValue:[NSNumber numberWithFloat:angle] forKey:@"inputAngle"];
	[filter setValue:[NSNumber numberWithFloat:acute] forKey:@"inputAcuteAngle"];
	[filter setValue:[NSNumber numberWithFloat:width] forKey:@"inputWidth"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)perspectiveTile:(NSPoint)topLeft topRight:(NSPoint)topRight bottomRight:(NSPoint)bottomRight bottomLeft:(NSPoint)bottomLeft{
	CIFilter *filter = [CIFilter filterWithName:@"CIPerspectiveTile"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:[CIVector vectorWithX:topLeft.x Y:topLeft.y] forKey:@"inputTopLeft"];
	[filter setValue:[CIVector vectorWithX:topRight.x Y:topRight.y] forKey:@"inputTopRight"];
	[filter setValue:[CIVector vectorWithX:bottomRight.x Y:bottomRight.y] forKey:@"inputBottomRight"];
	[filter setValue:[CIVector vectorWithX:bottomLeft.x Y:bottomLeft.y] forKey:@"inputBottomLeft"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)triangleTile:(NSPoint)center angle:(CGFloat)angle width:(CGFloat)width{
	CIFilter *filter = [CIFilter filterWithName:@"CITriangleTile"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:[CIVector vectorWithX:center.x Y:center.y] forKey:@"inputCenter"];
	[filter setValue:[NSNumber numberWithFloat:angle] forKey:@"inputAngle"];
	[filter setValue:[NSNumber numberWithFloat:width] forKey:@"inputWidth"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}

-(void)colorControls:(CGFloat)saturation brightness:(CGFloat)brightness contrast:(CGFloat)contrast{
	CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:[NSNumber numberWithFloat:saturation] forKey:@"inputSaturation"];
	[filter setValue:[NSNumber numberWithFloat:brightness] forKey:@"inputBrightness"];
	[filter setValue:[NSNumber numberWithFloat:contrast] forKey:@"inputContrast"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)exposureAdjust:(CGFloat)exposure{
	CIFilter *filter = [CIFilter filterWithName:@"CIExposureAdjust"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:[NSNumber numberWithFloat:exposure] forKey:@"inputEV"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)gammaAdjust:(CGFloat)gamma{
	CIFilter *filter = [CIFilter filterWithName:@"CIGammaAdjust"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:[NSNumber numberWithFloat:gamma] forKey:@"inputPower"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)hueAdjust:(CGFloat)hue{
	CIFilter *filter = [CIFilter filterWithName:@"CIHueAdjust"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:[NSNumber numberWithFloat:hue] forKey:@"inputAngle"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)invert{
	CIFilter *filter = [CIFilter filterWithName:@"CIColorInvert"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)monochrome:(C4Color *)color intensity:(CGFloat)intensity{
	CIFilter *filter = [CIFilter filterWithName:@"CIColorMonochrome"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:[CIColor colorWithCGColor:[color cgColor]] forKey:@"inputColor"];
	[filter setValue:[NSNumber numberWithFloat:intensity] forKey:@"inputIntensity"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)posterize:(CGFloat)intensity{
	CIFilter *filter = [CIFilter filterWithName:@"CIColorPosterize"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:[NSNumber numberWithFloat:intensity] forKey:@"inputLevels"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)maxGrayscale{
	CIFilter *filter = [CIFilter filterWithName:@"CIMaximumComponent"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)minGrayscale{
	CIFilter *filter = [CIFilter filterWithName:@"CIMinimumComponent"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)sepia:(CGFloat)intensity{
	CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:[NSNumber numberWithFloat:intensity] forKey:@"inputIntensity"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}

-(void)tint:(C4Color *)color {
    //create a color image to filter with..
    CIFilter *colorGenerator = [CIFilter filterWithName:@"CIConstantColorGenerator"];
    CIColor *cicolor = [CIColor colorWithRed:[color redComponent] green:[color greenComponent] blue:[color blueComponent]];
    [colorGenerator setValue:cicolor forKey:@"inputColor"];
    CIImage *colorImage = [colorGenerator valueForKey:@"outputImage"];
    
    //set up the multiply filter
    CIFilter *filter = [CIFilter filterWithName:@"CIMultiplyCompositing"];
    [filter setDefaults];
    [filter setValue:colorImage forKey:@"inputImage"];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputBackgroundImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputBackgroundImage"];
	}
    self.filteredImage = [filter valueForKey:@"outputImage"];
}
/*
 CIImage* outputImage = nil;
 
 //create some green
 CIFilter* greenGenerator = [CIFilter filterWithName:@"CIConstantColorGenerator"];
 CIColor* green = [CIColor colorWithRed:0.30 green:0.596 blue:0.172];
 [greenGenerator setValue:green forKey:@"inputColor"];
 CIImage* greenImage = [greenGenerator valueForKey:@"outputImage"];
 
 //apply a multiply filter
 CIFilter* filter = [CIFilter filterWithName:@"CIMultiplyCompositing"];
 [filter setValue:greenImage forKey:@"inputImage"];
 [filter setValue:inputImage forKey:@"inputBackgroundImage"];
 outputImage = [filter valueForKey:@"outputImage"];
*/

-(void)colorBlend:(C4Image *)backgroundImage{
	CIFilter *filter = [CIFilter filterWithName:@"CIColorBlendMode"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:backgroundImage.originalImage forKey:@"inputBackgroundImage"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)burnBlend:(C4Image *)backgroundImage{
	CIFilter *filter = [CIFilter filterWithName:@"CIColorBurnBlendMode"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:backgroundImage.originalImage forKey:@"inputBackgroundImage"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)darkenBlend:(C4Image *)backgroundImage{
	CIFilter *filter = [CIFilter filterWithName:@"CIDarkenBlendMode"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:backgroundImage.originalImage forKey:@"inputBackgroundImage"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)differenceBlend:(C4Image *)backgroundImage{
	CIFilter *filter = [CIFilter filterWithName:@"CIDifferenceBlendMode"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:backgroundImage.originalImage forKey:@"inputBackgroundImage"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)exclusionBlend:(C4Image *)backgroundImage{
	CIFilter *filter = [CIFilter filterWithName:@"CIExclusionBlendMode"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:backgroundImage.originalImage forKey:@"inputBackgroundImage"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)hardLightBlend:(C4Image *)backgroundImage{
	CIFilter *filter = [CIFilter filterWithName:@"CIHardLightBlendMode"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:backgroundImage.originalImage forKey:@"inputBackgroundImage"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)hueBlend:(C4Image *)backgroundImage{
	CIFilter *filter = [CIFilter filterWithName:@"CIHueBlendMode"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:backgroundImage.originalImage forKey:@"inputBackgroundImage"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)lightenBlend:(C4Image *)backgroundImage{
	CIFilter *filter = [CIFilter filterWithName:@"CILightenBlendMode"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:backgroundImage.originalImage forKey:@"inputBackgroundImage"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)luminosityBlend:(C4Image *)backgroundImage{
	CIFilter *filter = [CIFilter filterWithName:@"CILuminosityBlendMode"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:backgroundImage.originalImage forKey:@"inputBackgroundImage"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)multiplyBlend:(C4Image *)backgroundImage{
	CIFilter *filter = [CIFilter filterWithName:@"CIMultiplyBlendMode"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:backgroundImage.originalImage forKey:@"inputBackgroundImage"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)overlayBlend:(C4Image *)backgroundImage{
	CIFilter *filter = [CIFilter filterWithName:@"CIOverlayBlendMode"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:backgroundImage.originalImage forKey:@"inputBackgroundImage"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)saturationBlend:(C4Image *)backgroundImage{
	CIFilter *filter = [CIFilter filterWithName:@"CISaturationBlendMode"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:backgroundImage.originalImage forKey:@"inputBackgroundImage"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)screenBlend:(C4Image *)backgroundImage{
	CIFilter *filter = [CIFilter filterWithName:@"CIScreenBlendMode"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:backgroundImage.originalImage forKey:@"inputBackgroundImage"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)softLightBlend:(C4Image *)backgroundImage{
	CIFilter *filter = [CIFilter filterWithName:@"CISoftLightBlendMode"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:backgroundImage.originalImage forKey:@"inputBackgroundImage"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}

-(void)bumpDistortion:(NSPoint)center radius:(CGFloat)radius scale:(CGFloat)scale{
	CIFilter *filter = [CIFilter filterWithName:@"CIBumpDistortion"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:[CIVector vectorWithX:center.x Y:center.y] forKey:@"inputCenter"];
	[filter setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
	[filter setValue:[NSNumber numberWithFloat:scale] forKey:@"inputScale"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)bumpLinearDistortion:(NSPoint)center radius:(CGFloat)radius angle:(CGFloat)angle scale:(CGFloat)scale{
	CIFilter *filter = [CIFilter filterWithName:@"CIBumpDistortionLinear"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:[CIVector vectorWithX:center.x Y:center.y] forKey:@"inputCenter"];
	[filter setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
	[filter setValue:[NSNumber numberWithFloat:scale] forKey:@"inputScale"];
	[filter setValue:[NSNumber numberWithFloat:angle] forKey:@"inputAngle"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)circleDistortion:(NSPoint)center radius:(CGFloat)radius{
	CIFilter *filter = [CIFilter filterWithName:@"CICircleSplashDistortion"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:[CIVector vectorWithX:center.x Y:center.y] forKey:@"inputCenter"];
	[filter setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}

-(void)circularScreen:(NSPoint)center width:(CGFloat)width sharpness:(CGFloat)sharpness{
	CIFilter *filter = [CIFilter filterWithName:@"CICircularScreen"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:[CIVector vectorWithX:center.x Y:center.y] forKey:@"inputCenter"];
	[filter setValue:[NSNumber numberWithFloat:width] forKey:@"inputWidth"];
	[filter setValue:[NSNumber numberWithFloat:sharpness] forKey:@"inputSharpness"];
	
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)circularWrap:(NSPoint)center radius:(CGFloat)radius angle:(CGFloat)angle{
	CIFilter *filter = [CIFilter filterWithName:@"CICircularWrap"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}

	[filter setValue:[CIVector vectorWithX:center.x Y:center.y] forKey:@"inputCenter"];
	[filter setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
	[filter setValue:[NSNumber numberWithFloat:angle] forKey:@"inputAngle"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)holeDistortion:(NSPoint)center radius:(CGFloat)radius{
	CIFilter *filter = [CIFilter filterWithName:@"CIHoleDistortion"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:[CIVector vectorWithX:center.x Y:center.y] forKey:@"inputCenter"];
	[filter setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)twirlDistortion:(NSPoint)center radius:(CGFloat)radius angle:(CGFloat)angle{
	CIFilter *filter = [CIFilter filterWithName:@"CITwirlDistortion"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:[CIVector vectorWithX:center.x Y:center.y] forKey:@"inputCenter"];
	[filter setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
	[filter setValue:[NSNumber numberWithFloat:angle] forKey:@"inputAngle"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)vortexDistortion:(NSPoint)center radius:(CGFloat)radius angle:(CGFloat)angle{
	CIFilter *filter = [CIFilter filterWithName:@"CIVortexDistortion"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:[CIVector vectorWithX:center.x Y:center.y] forKey:@"inputCenter"];
	[filter setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
	[filter setValue:[NSNumber numberWithFloat:angle] forKey:@"inputAngle"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}

-(void)dotScreen:(NSPoint)center angle:(CGFloat)angle width:(CGFloat)width sharpness:(CGFloat)sharpness{
	CIFilter *filter = [CIFilter filterWithName:@"CIDotScreen"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:[CIVector vectorWithX:center.x Y:center.y] forKey:@"inputCenter"];
	[filter setValue:[NSNumber numberWithFloat:angle] forKey:@"inputAngle"];
	[filter setValue:[NSNumber numberWithFloat:width] forKey:@"inputWidth"];
	[filter setValue:[NSNumber numberWithFloat:sharpness] forKey:@"inputSharpness"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)hatchedScreen:(NSPoint)center angle:(CGFloat)angle width:(CGFloat)width sharpness:(CGFloat)sharpness{
	CIFilter *filter = [CIFilter filterWithName:@"CIHatchedScreen"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:[CIVector vectorWithX:center.x Y:center.y] forKey:@"inputCenter"];
	[filter setValue:[NSNumber numberWithFloat:angle] forKey:@"inputAngle"];
	[filter setValue:[NSNumber numberWithFloat:width] forKey:@"inputWidth"];
	[filter setValue:[NSNumber numberWithFloat:sharpness] forKey:@"inputSharpness"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)lineScreen:(NSPoint)center angle:(CGFloat)angle width:(CGFloat)width sharpness:(CGFloat)sharpness{
	CIFilter *filter = [CIFilter filterWithName:@"CILineScreen"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:[CIVector vectorWithX:center.x Y:center.y] forKey:@"inputCenter"];
	[filter setValue:[NSNumber numberWithFloat:angle] forKey:@"inputAngle"];
	[filter setValue:[NSNumber numberWithFloat:width] forKey:@"inputWidth"];
	[filter setValue:[NSNumber numberWithFloat:sharpness] forKey:@"inputSharpness"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}

-(void)blendWithMask:(C4Image *)backgroundImage maskImage:(C4Image *)maskImage{
	CIFilter *filter = [CIFilter filterWithName:@"CIBlendWithMask"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:backgroundImage.originalImage forKey:@"inputBackgroundImage"];
	[filter setValue:maskImage.originalImage forKey:@"inputMaskImage"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}

-(void)bloom:(CGFloat)radius intensity:(CGFloat)intensity{
	CIFilter *filter = [CIFilter filterWithName:@"CIBloom"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
	[filter setValue:[NSNumber numberWithFloat:intensity] forKey:@"inputIntensity"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)comicEffect{
	CIFilter *filter = [CIFilter filterWithName:@"CIComicEffect"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)crystallize:(NSPoint)center radius:(CGFloat)radius{
	CIFilter *filter = [CIFilter filterWithName:@"CICrystallize"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:[CIVector vectorWithX:center.x Y:center.y] forKey:@"inputCenter"];
	[filter setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)edges:(CGFloat)intensity{
	CIFilter *filter = [CIFilter filterWithName:@"CIEdges"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:[NSNumber numberWithFloat:intensity] forKey:@"inputIntensity"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)edgeWork:(CGFloat)radius{
	CIFilter *filter = [CIFilter filterWithName:@"CIEdgeWork"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)gloom:(CGFloat)radius intensity:(CGFloat)intensity{
	CIFilter *filter = [CIFilter filterWithName:@"CIGloom"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:[NSNumber numberWithFloat:intensity] forKey:@"inputIntensity"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)hexagonalPixellate:(NSPoint)center scale:(CGFloat)scale{
	CIFilter *filter = [CIFilter filterWithName:@"CIHexagonalPixellate"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:[CIVector vectorWithX:center.x Y:center.y] forKey:@"inputCenter"];
	[filter setValue:[NSNumber numberWithFloat:scale] forKey:@"inputScale"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)pixellate:(NSPoint)center scale:(CGFloat)scale{
	CIFilter *filter = [CIFilter filterWithName:@"CIPixellate"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}
	
	[filter setValue:[CIVector vectorWithX:center.x Y:center.y] forKey:@"inputCenter"];
	[filter setValue:[NSNumber numberWithFloat:scale] forKey:@"inputScale"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
-(void)pointillize:(NSPoint)center radius:(CGFloat)radius{
	CIFilter *filter = [CIFilter filterWithName:@"CIPointillize"];
	[filter setDefaults];
	if(singleFilter) {
		[filter setValue:originalImage forKey:@"inputImage"];
	} else {
		[filter setValue:filteredImage forKey:@"inputImage"];
	}

	[filter setValue:[CIVector vectorWithX:center.x Y:center.y] forKey:@"inputCenter"];
	[filter setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
	self.filteredImage = [filter valueForKey: @"outputImage"];
}
@end
