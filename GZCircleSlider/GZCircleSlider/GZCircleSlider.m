//
//  GZCircleSlider.m
//  GZCircleSlider
//
//  Created by armada on 2016/11/25.
//  Copyright © 2016年 com.zlot.gz. All rights reserved.
//

#import "GZCircleSlider.h"

#define kDefaultFontSize 14.0f
#define ToRad(deg) ((M_PI*(deg))/180.00)
#define ToDeg(rad) ((180*rad)/M_PI)
#define SQR(x) ((x)*(x))

@interface GZCircleSlider()

{
    int angle;
    int fixedAngle;
    int previousIndex;
}

@property(readonly, nonatomic) CGFloat radius;

@property(nonatomic,strong) NSMutableArray<CAShapeLayer *> *dials;

@property(nonatomic,strong) NSMutableArray<CATextLayer *> *textLayers;

@end

@implementation GZCircleSlider

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)defaults {
    // Defaults
    _maximumValue = 100.0f;
    _minimumValue = 0.0f;
    _currentValue = 0.0f;
    _lineWidth = 20.0f;
    
    _followingAngle = 30.0f;
    _followingColor = [UIColor cyanColor];
    
    _lineRadiusDisplacement = 0.0f;
    _unfilledColor = [UIColor blackColor];
    _filledColor = [UIColor redColor];
    _handleColor = _filledColor;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        [self defaults];
        [self setFrame:frame];
        
        [self addDialLayers];
        [self addTextLayers];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder]) {
        [self defaults];
    }
    return self;
}

#pragma mark - Setter/Getter
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    angle = [self angleFromValue];
}

- (void)setCurrentValue:(float)currentValue {
    _currentValue=currentValue;
    
    if(_currentValue>_maximumValue) _currentValue=_maximumValue;
    else if(_currentValue<_minimumValue) _currentValue=_minimumValue;
    
    angle = [self angleFromValue];
    [self setNeedsLayout];
    [self setNeedsDisplay];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (CGFloat)radius {
    return self.frame.size.height/2 - _lineWidth/2 - ([self circleDiameter] - _lineWidth) - _lineRadiusDisplacement;
}

- (CGFloat)circleDiameter {
    return _lineWidth;
}

#pragma mark - drawing methods

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
  /*
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //draw the background circle
    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, self.radius, 0, M_PI*2, 0);
    [_unfilledColor setStroke];
    CGContextSetLineWidth(ctx,_lineWidth);
    CGContextSetLineCap(ctx, kCGLineCapButt);
    CGContextDrawPath(ctx,kCGPathStroke);
    
    //draw the filled circle
    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, self.radius, 3*M_PI/2, 3*M_PI/2-ToRad(angle), 0);
    [_filledColor setStroke];
    CGContextSetLineWidth(ctx, _lineWidth);
    CGContextSetLineCap(ctx, kCGLineCapButt);
    CGContextDrawPath(ctx, kCGPathStroke);
 */
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //draw background circle
    
    //create the mask image
    UIGraphicsBeginImageContext(CGSizeMake(self.frame.size.width,self.frame.size.height));
    CGContextRef imageCtx = UIGraphicsGetCurrentContext();
    CGContextAddArc(imageCtx, self.frame.size.width/2, self.frame.size.height/2, self.radius, 0, M_PI*2, 0);
    [[UIColor redColor] set];
    
    CGContextSetShadowWithColor(imageCtx, CGSizeMake(0, 0), M_PI, [UIColor blackColor].CGColor);
    
    CGContextSetLineWidth(imageCtx, _lineWidth-4);
    CGContextDrawPath(imageCtx, kCGPathStroke);
    
    //save the context content into the image
    CGImageRef mask = CGBitmapContextCreateImage(UIGraphicsGetCurrentContext());
    UIGraphicsEndImageContext();
    
    CGContextSaveGState(ctx);

    CGContextClipToMask(ctx, self.bounds, mask);
    
    //create the gradient
    CGFloat components[8] = {
        0.0,0.0,1.0,1.0,
        1.0,0.0,1.0,1.0
    };
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, components, NULL, 2);
    CGColorSpaceRelease(baseSpace),baseSpace = NULL;
    
    //Gradient direction
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    //draw the gradient
    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient);
    gradient = NULL;
    
    CGContextRestoreGState(ctx);

    //draw following arc
    [self drawFollowingArc:ctx];
    
    //draggable part
    [self drawHandle:ctx];
    
}

- (void)drawFollowingArc:(CGContextRef)ctx {
    
    CGContextSaveGState(ctx);
    CGFloat followingMidAngle = ToRad(-angle-90);
    CGFloat startPoint = followingMidAngle - ToRad(self.followingAngle/2.0);
    CGFloat endPoint = followingMidAngle + ToRad(self.followingAngle/2.0);
    CGContextAddArc(ctx, [self centerPoint].x, [self centerPoint].y, self.radius, startPoint, endPoint, 0);
    
    CGContextSetLineWidth(ctx, _lineWidth);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    [self.followingColor set];
    
    CGContextDrawPath(ctx, kCGPathStroke);
}

- (void)drawHandle:(CGContextRef)ctx {
    
    CGContextSaveGState(ctx);
    CGPoint handleCenter = [self pointFromAngle:angle];
    [[UIColor colorWithWhite:1.0 alpha:1] set];
    CGContextFillEllipseInRect(ctx, CGRectMake(handleCenter.x, handleCenter.y, _lineWidth, _lineWidth));
    CGContextRestoreGState(ctx);
}

- (void)addDialLayers {
    
    _dials = [NSMutableArray array];
    
    for(int i=0;i<12;i++) {
        
        CGFloat radian = M_PI/6.0*i;
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.frame = CGRectMake(0, 0, 6, 6);
        
        CGFloat centerX = [self centerPoint].x + (self.radius - 20)*sin(radian);
        CGFloat centerY = [self centerPoint].y - (self.radius - 20)*cos(radian);
        shapeLayer.position = CGPointMake(centerX, centerY);
        
        shapeLayer.backgroundColor = [UIColor blueColor].CGColor;
        shapeLayer.cornerRadius = shapeLayer.bounds.size.width/2.0;
        shapeLayer.masksToBounds = YES;
        
        [self.layer addSublayer:shapeLayer];
        
        [_dials addObject:shapeLayer];
    }
    
}

- (void)addTextLayers {
    
    _textLayers = [NSMutableArray array];
    
    for(int i=0;i<12;i++) {
        
        CGFloat radian = M_PI/6.0*i;
        
        CATextLayer *textLayer = [CATextLayer layer];
        textLayer.frame = CGRectMake(0, 0, 30, 15);
        
        CGFloat centerX = [self centerPoint].x + (self.radius - 40)*sin(radian);
        CGFloat centerY = [self centerPoint].y - (self.radius - 40)*cos(radian);
        textLayer.position = CGPointMake(centerX, centerY);
        
        if(i==0){
            textLayer.string = @"12";
        }else {
            textLayer.string = [NSString stringWithFormat:@"%d",i];
        }
        textLayer.fontSize = 15;
        textLayer.foregroundColor = [UIColor grayColor].CGColor;
        textLayer.alignmentMode = @"center";
        
        [self.layer addSublayer:textLayer];
        
        [_textLayers addObject:textLayer];

    }
    
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGPoint p1 = [self centerPoint];
    CGPoint p2 = point;
    CGFloat xDist = (p2.x - p1.x);
    CGFloat yDist = (p2.y - p1.y);
    double distance = sqrt((xDist * xDist) + (yDist * yDist));
    //return distance < self.radius + 11;
    return distance < self.radius+_lineWidth/2 && distance > self.radius-_lineWidth/2;
}


#pragma mark - UIControl Functions
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super beginTrackingWithTouch:touch withEvent:event];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super continueTrackingWithTouch:touch withEvent:event];
    CGPoint lastPoint = [touch locationInView:self];
    [self moveHandle:lastPoint];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    int index = round((self.currentValue/100*360)/30.0);
//    int index = round((double)(self.currentValue)/30.0);
//    
    if(index!=previousIndex) {
        
        if(index==12) {
            index = 0;
        }
        self.dials[previousIndex].backgroundColor = [UIColor blueColor].CGColor;
        CAShapeLayer *currentLayer = self.dials[index];
        currentLayer.backgroundColor = [UIColor cyanColor].CGColor;
        
        previousIndex = index;
    }
    
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super endTrackingWithTouch:touch withEvent:event];
    
    //select the nearest index dial
    self.currentValue = round((self.currentValue/100*360)/30.0)*30.0/360.0*100;
}

- (void)moveHandle:(CGPoint)point {
    CGPoint centerPoint;
    centerPoint = [self centerPoint];
    CGFloat currentAngle = floor(AngleFromNorth(centerPoint, point, NO));
    angle = 360-90-currentAngle;
    _currentValue = [self valueFromAngle];
    
    [self setNeedsDisplay];
}

- (CGPoint)centerPoint {
    return CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}

#pragma mark - Helper Functions
-(float) valueFromAngle {
    if(angle < 0) {
        _currentValue = -angle;
    } else {
        _currentValue = 270 - angle + 90;
    }
    fixedAngle = _currentValue;
    return (_currentValue*(_maximumValue - _minimumValue))/360.0f;
}

- (float)angleFromValue {
    
    angle = 360 - (360.0f*_currentValue/_maximumValue);
    
    if(angle==360) angle=0;
    
    return angle;
}

- (CGPoint)pointFromAngle:(int)ang {
    
    //Define the circle center
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2-_lineWidth/2,self.frame.size.height/2-_lineWidth/2);
    
    //Define the point position on the circumference
    CGPoint result = CGPointMake(0, 0);
    result.y = round(centerPoint.y+self.radius*sin(ToRad(-ang-90)));
    result.x = round(centerPoint.x+self.radius*cos(ToRad(-ang-90)));
    
    return result;
}

static inline float AngleFromNorth(CGPoint p1, CGPoint p2, BOOL flipped) {
    CGPoint v = CGPointMake(p2.x-p1.x,p2.y-p1.y);
    float vmag = sqrt(SQR(v.x) + SQR(v.y));
    v.x /= vmag;
    v.y /= vmag;
    double radians = atan2(v.y,v.x);
    CGFloat result = ToDeg(radians);
    return (result >=0  ? result : result + 360.0);
}

@end
