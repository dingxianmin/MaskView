//
//  MaskView.h
//  MaskView
//
//  Created by invoker on 16/3/8.
//  Copyright © 2016年 QQQ. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MaskViewType) {
    MaskViewAlertType = 1,
    MaskViewActionSheetType,
#warning you need dismiss maskview when release
    MaskViewNotificationType, //有遮罩层
    MaskViewNotificationClearType, //无遮罩层
};

@interface MaskView : UIView

/**
 *  view: 弹出的主业务内容视图
 *  type:弹出视图的类型 ENMaskViewType
 *  viewController: 加到某个控制器上
 *  touchDismiss:支持点击背景消失
 */

+ (void)showWithContenView:(UIView*)view type:(MaskViewType)type inViewController:(UIViewController*)viewController maskViewTouchableDismiss:(BOOL)touchDismiss;

+ (void)showAlertTypeView:(UIView*)view maskViewTouchableDismiss:(BOOL)touchDismiss;

+ (void)showAlertTypeView:(UIView*)view;

+ (void)showActionSheetTypeView:(UIView*)view maskViewTouchableDismiss:(BOOL)touchDismiss;

+ (void)showActionSheetTypeView:(UIView*)view;

+ (void)showNotificationTypeView:(UIView*)view inViewController:(UIViewController*)viewController;

+ (void)showNotificationClearTypeView:(UIView*)view inViewController:(UIViewController*)viewController;

+ (void)maskViewTouchableDismiss:(BOOL)touchDismiss;

+ (void)dismiss;

+ (BOOL)currentShowView;

@end