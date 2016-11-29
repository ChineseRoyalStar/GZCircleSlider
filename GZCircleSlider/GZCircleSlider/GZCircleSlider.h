//
//  GZCircleSlider.h
//  GZCircleSlider
//
//  Created by armada on 2016/11/25.
//  Copyright © 2016年 com.zlot.gz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GZCircleSlider : UIControl

@property(nonatomic,assign) float minimumValue;
@property(nonatomic,assign) float maximumValue;
@property(nonatomic,assign) float currentValue;

@property(nonatomic,assign) CGFloat lineWidth;
@property(nonatomic,assign) CGFloat lineRadiusDisplacement;
@property(nonatomic,strong) UIColor *filledColor;
@property(nonatomic,strong) UIColor *unfilledColor;

@property(nonatomic,strong) UIColor *handleColor;

@property(nonatomic,assign) CGFloat followingAngle;
@property(nonatomic,strong) UIColor *followingColor;

@end
