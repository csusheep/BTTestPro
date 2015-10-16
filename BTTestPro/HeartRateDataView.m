//
//  HeartRateDataView.m
//  BTTestPro
//
//  Created by 刘 晓东 on 15/10/13.
//  Copyright © 2015年 刘 晓东. All rights reserved.
//



#import "HeartRateDataView.h"
#import <CoreGraphics/CoreGraphics.h>

#define   DEGREES_TO_RADIANS(degrees)  ((M_PI * degrees)/ 180)

@interface HeartRateDataView()
{
    NSMutableArray *points;
}

@end

@implementation HeartRateDataView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        points = nil;
        _heartValue = [NSNumber numberWithInteger:0];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [self drawInContext:UIGraphicsGetCurrentContext()];
}

- (void)drawInContext:(CGContextRef)context {
    [self render:context value:_heartValue];
}

- (void)render:(CGContextRef)context value:(NSNumber*)value {
    if (!points) {
        points = [NSMutableArray new];
    }
    [points insertObject:value atIndex:0];
    CGRect bounds = self.layer.bounds;
    while (bounds.size.width/2 < points.count) {
        [points removeLastObject];
    }
    if (points.count == 0) {
        return;
    }
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 2);
    CGContextBeginPath(context);
    CGContextSaveGState(context);
    
    //矩阵变换，调整坐标原点到左下角。
    CGContextTranslateCTM(context, 0.0f, bounds.size.height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    
    float xpos = bounds.size.width;
    //float ypos = bounds.size.height - [[points objectAtIndex:0] floatValue];
    float ypos = [[points objectAtIndex:0] floatValue];
    ypos = ypos < 40 ? 0 : ypos - 40 ;
    CGContextMoveToPoint(context, xpos,ypos);
    for (int i = 1; i < points.count; i++) {
        xpos -= 2;
        ypos = [[points objectAtIndex:i] floatValue];
        ypos = ypos < 40 ? 0 : ypos - 40 ;
        CGContextAddLineToPoint(context, xpos ,ypos  );
    }
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

- (void)setHeartValue:(NSNumber*)value{
        _heartValue = value;
        [self setNeedsDisplay];
}

- (void)dealloc {
    
#if !__has_feature(objc_arc)
    if (!points) {
        [points release];
    }
    if (!heartValue) {
        [heartValue release];
    }
#if NS_BLOCKS_AVAILABLE
    //[completionBlock release];
#endif
    points = nil;
    heartValue = nil;
    [super dealloc];
#endif
}

@end
