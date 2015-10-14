//
//  HeartRateDataView.h
//  BTTestPro
//
//  Created by 刘 晓东 on 15/10/13.
//  Copyright © 2015年 刘 晓东. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeartRateDataView : UIView

@property (nonatomic, strong,readwrite)NSNumber *heartValue;


-(void)drawInContext:(CGContextRef)context;

@end
