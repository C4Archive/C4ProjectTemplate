//
//  C4Canvas.h
//  CodeSamples
//
//	A Cocoa For Artists project
//  Created by Travis Kirton
//

#import "C4Canvas.h"

int xvals[60];
int yvals[60];
int pointCount = 60;

@implementation C4Canvas
-(void)setup {
    [self drawStyle:DISPLAYRATE];
    [self windowWidth:400 andHeight:320];
    [C4Shape noStroke];
    for (int i = 0; i < pointCount; i++) {
        xvals[i] = self.canvasWidth/2;
        yvals[i] = self.canvasHeight/2;
    }
}

-(void)draw {
    [self background:0.3f];
    for(int i = 1; i < pointCount; i++){
        xvals[i-1] = xvals[i];
        yvals[i-1] = yvals[i];
    }
    xvals[pointCount-1] = mousePos.x;
    yvals[pointCount-1] = mousePos.y;
    
    [C4Shape fillRed:0.2f green:0.4f blue:1.0f alpha:0.66f];
    for(int i = 0; i < pointCount-1; i++) {
        [C4Shape ellipseWithXPos:xvals[i] yPos:yvals[i] width:i/2 andHeight:i/2];
    }
    [C4Shape stroke];
    [C4Shape strokeRed:1.0f green:0.2f blue:0.2f alpha:0.66f];
    [C4Shape ellipseWithXPos:xvals[pointCount-1] 
                        yPos:yvals[pointCount-1] 
                       width:pointCount/2 
                   andHeight:pointCount/2];
    [C4Shape noStroke];
}
@end