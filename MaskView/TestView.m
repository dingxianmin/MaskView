//
//  TestView.m
//  MaskView
//
//  Created by invoker on 16/3/8.
//  Copyright © 2016年 QQQ. All rights reserved.
//

#import "TestView.h"

@implementation TestView

- (void)drawRect:(CGRect)rect {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    label.text = @"Test";
    label.center = CGPointMake(rect.size.width/2, rect.size.height/2);
    [self addSubview:label];
}

@end
