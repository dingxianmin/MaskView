//
//  CustomController_ActionSheet.m
//  MaskView
//
//  Created by invoker on 16/3/10.
//  Copyright © 2016年 QQQ. All rights reserved.
//

#import "CustomController_ActionSheet.h"

@implementation CustomController_ActionSheet

- (void)drawRect:(CGRect)rect {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 21)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"custom Controller";
    label.font = [UIFont systemFontOfSize:15.f];
    label.center = CGPointMake(rect.size.width/2, rect.size.height/2);
    [self addSubview:label];
}
@end
