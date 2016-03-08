//
//  MaskView.m
//  MaskView
//
//  Created by invoker on 16/3/8.
//  Copyright © 2016年 QQQ. All rights reserved.
//

#import "MaskView.h"
#import <objc/runtime.h>

typedef void(^ShowMaskViewQueueBlock)(void);

@interface MaskView ()

@property (nonatomic ,strong) UIView *backView;
/**
 *  value: contentView
 *  describe: 需要显示的View
 */
@property (nonatomic ,strong) UIView *contentView;

/**
 *  value: maskType
 *  describe: 显示风格
 */
@property (nonatomic ,assign) MaskViewType maskType;

/**
 *  value: canTouchDismiss
 *  describe: 点击背景消失
 *  default: YES
 */
@property (nonatomic ,assign) BOOL canTouchDismiss;

/**
 *  value: showQueueBlock
 *  describe: 当前视图还未移除,将新推出的视图显示方法放到Queue中
 *  default: nil
 */
@property (nonatomic ,copy) ShowMaskViewQueueBlock showQueueBlock;

@end

static const CGFloat mv_NavigationBar_Height = 44.f;
static const CGFloat mv_TabBar_Height = 49.f;
static const CGFloat mv_Animation_duration = 0.35f;
static const CGFloat mv_Bounces_duration = 0.1f;

@implementation MaskView

+ (instancetype)sharedMaskView
{
    static MaskView *maskView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        maskView = [[MaskView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        maskView.backgroundColor = [UIColor clearColor];
        [maskView _initSubView];
    });
    return maskView;
}

- (void)_initSubView
{
    if (self.backView == nil)
    {
        self.backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.backView.backgroundColor = [UIColor blackColor];
        self.backView.alpha = 0.2f;
        [self addSubview:self.backView];
    }
}

- (void)layoutSubviews
{
    self.backView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    if (self.contentView) {
        [self bringSubviewToFront:self.contentView];
    }
    
    if (self.canTouchDismiss) {
        if (self.backView.gestureRecognizers.count == 0) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_dismissMaskView)];
            [self.backView addGestureRecognizer:tap];
        }
    } else {
        if (self.backView.gestureRecognizers.count > 0) {
            for (UIGestureRecognizer *gr in self.backView.gestureRecognizers) {
                [self.backView removeGestureRecognizer:gr];
            }
        }
    }
}


+ (void)maskViewTouchableDismiss:(BOOL)touchDismiss
{
    [[self sharedMaskView] setCanTouchDismiss:touchDismiss];
    [[self sharedMaskView] layoutSubviews];
}

+ (void)showWithContenView:(UIView*)view type:(MaskViewType)type inViewController:(UIViewController *)viewController maskViewTouchableDismiss:(BOOL)touchDismiss
{
    if ([self currentShowView])
    {
        __weak typeof(self) weakSelf = self;
        [[self sharedMaskView] setShowQueueBlock:^(void) {
            [[weakSelf sharedMaskView] setCanTouchDismiss:touchDismiss];
            [[weakSelf sharedMaskView] setMaskType:type];
            [[weakSelf sharedMaskView] setContentView:view];
            [[weakSelf sharedMaskView] showInView:viewController.view];
        }];
    }
    else
    {
        [[self sharedMaskView] setCanTouchDismiss:touchDismiss];
        [[self sharedMaskView] setMaskType:type];
        [[self sharedMaskView] setContentView:view];
        [[self sharedMaskView] showInView:viewController.view];
    }
}

+ (void)showAlertTypeView:(UIView*)view maskViewTouchableDismiss:(BOOL)touchDismiss;
{
    [self showWithContenView:view type:MaskViewAlertType inViewController:[UIViewController new] maskViewTouchableDismiss:touchDismiss];
}

+ (void)showAlertTypeView:(UIView*)view
{
    [self showWithContenView:view type:MaskViewAlertType inViewController:[UIViewController new] maskViewTouchableDismiss:YES];
}

+ (void)showActionSheetTypeView:(UIView*)view
{
    [self showWithContenView:view type:MaskViewActionSheetType inViewController:[UIViewController new] maskViewTouchableDismiss:YES];
}

+ (void)showActionSheetTypeView:(UIView*)view maskViewTouchableDismiss:(BOOL)touchDismiss;
{
    [self showWithContenView:view type:MaskViewActionSheetType inViewController:[UIViewController new] maskViewTouchableDismiss:touchDismiss];
}

+ (void)showNotificationTypeView:(UIView*)view inViewController:(UIViewController*)viewController
{
    [self showWithContenView:view type:MaskViewNotificationType inViewController:viewController maskViewTouchableDismiss:YES];
}

+ (void)showNotificationClearTypeView:(UIView*)view inViewController:(UIViewController*)viewController;
{
    [self showWithContenView:view type:MaskViewNotificationClearType inViewController:viewController maskViewTouchableDismiss:NO];
}



- (void)showInView:(UIView*)view
{
    self.showQueueBlock = nil;
    switch (self.maskType)
    {
        case MaskViewAlertType:
        {
            self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            [self addSubview:self.contentView];
            self.contentView.alpha = 0.1f;
            
            if(!self.superview) {
                UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
                [window addSubview:self];
            }
            self.contentView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
            [self.contentView setTransform:CGAffineTransformMakeScale(0.01, 0.01)];
            [UIView animateWithDuration:0.35f
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.contentView.transform = CGAffineTransformMakeScale(1.1, 1.1);
                                 self.contentView.alpha = 0.9f;
                                 self.backView.alpha = 0.5f;
                             } completion:^(BOOL finished) {
                                 [UIView animateWithDuration:mv_Bounces_duration animations:^{
                                     self.contentView.transform = CGAffineTransformMakeScale(0.99, 0.99);
                                 } completion:^(BOOL finished) {
                                     [UIView animateWithDuration:mv_Bounces_duration animations:^{
                                         self.contentView.alpha = 1.0f;
                                         self.contentView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                     }];
                                 }];
                             }];
        }
            break;
        case MaskViewActionSheetType:
        {
            self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            
            if(!self.superview) {
                UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
                [window addSubview:self];
            }
            
            [self.contentView setFrame:CGRectMake((self.frame.size.width - self.contentView.frame.size.width)/2 , self.frame.size.height, self.contentView.frame.size.width, self.contentView.frame.size.height)];
            [self addSubview:self.contentView];
            
            [UIView animateWithDuration:mv_Animation_duration
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.backView.alpha = 0.5f;
                                 [self.contentView setFrame:CGRectMake((self.frame.size.width - self.contentView.frame.size.width)/2 , self.frame.size.height - self.contentView.frame.size.height, self.contentView.frame.size.width, self.contentView.frame.size.height)];
                             } completion:^(BOOL finished) {}];
        }
            break;
        case MaskViewNotificationType:
        {
            CGFloat height = [UIScreen mainScreen].bounds.size.height;
            CGFloat top = 0;
            UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
            if ([window.rootViewController isKindOfClass:[UITabBarController class]])
            {
                UITabBarController *tabBarController = (UITabBarController*)window.rootViewController;
                if (!tabBarController.tabBar.hidden) {
                    height -= mv_TabBar_Height;
                }
                
                if ([tabBarController.selectedViewController isKindOfClass:[UINavigationController class]])
                {
                    UINavigationController *navController = (UINavigationController*)tabBarController.selectedViewController;
                    if (!navController.navigationBarHidden) {
                        height -= [[UIApplication sharedApplication] statusBarFrame].size.height;
                        top += [[UIApplication sharedApplication] statusBarFrame].size.height;
                        if (navController.navigationBar.translucent) {
                            top += mv_NavigationBar_Height;
                        }
                        height -= mv_NavigationBar_Height;
                    }
                }
            }
            else if ([window.rootViewController isKindOfClass:[UINavigationController class]])
            {
                UINavigationController *navController = (UINavigationController*)window.rootViewController;
                if (navController.navigationBar.translucent) {
                    top += mv_NavigationBar_Height;
                }
                height -= mv_NavigationBar_Height;
            }
            
            self.frame = CGRectMake(0,  top, [UIScreen mainScreen].bounds.size.width, height);
            [self addSubview:self.contentView];
            [self bringSubviewToFront:self.contentView];
            if(!self.superview) {
                [view addSubview:self];
            }
            
            [self.contentView setFrame:CGRectMake((self.frame.size.width - self.contentView.frame.size.width)/2 , -self.contentView.frame.size.height, self.contentView.frame.size.width, self.contentView.frame.size.height)];
            
            [UIView animateWithDuration:mv_Animation_duration
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.backView.alpha = 0.5f;
                                 [self.contentView setFrame:CGRectMake((self.frame.size.width - self.contentView.frame.size.width)/2 , 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
                             } completion:^(BOOL finished) {}];
        }
            break;
        case MaskViewNotificationClearType:
        {
            CGFloat top = 0;
            UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
            if ([window.rootViewController isKindOfClass:[UITabBarController class]])
            {
                UITabBarController *tabBarController = (UITabBarController*)window.rootViewController;
                if ([tabBarController.selectedViewController isKindOfClass:[UINavigationController class]])
                {
                    UINavigationController *navController = (UINavigationController*)tabBarController.selectedViewController;
                    if (!navController.navigationBarHidden) {
                        top += [[UIApplication sharedApplication] statusBarFrame].size.height;
                        if (navController.navigationBar.translucent) {
                            top += mv_NavigationBar_Height;
                        }
                    }
                }
            }
            else if ([window.rootViewController isKindOfClass:[UINavigationController class]])
            {
                UINavigationController *navController = (UINavigationController*)window.rootViewController;
                if (navController.navigationBar.translucent) {
                    top += mv_NavigationBar_Height;
                }
            }
            
            self.frame = CGRectMake(0, top, [UIScreen mainScreen].bounds.size.width, self.contentView.frame.size.height);
            [self addSubview:self.contentView];
            [self bringSubviewToFront:self.contentView];
            
            if(!self.superview) {
                [view addSubview:self];
            }
            
            [self.contentView setFrame:CGRectMake((self.frame.size.width - self.contentView.frame.size.width)/2 , -self.contentView.frame.size.height, self.contentView.frame.size.width, self.contentView.frame.size.height)];
            
            self.backView.alpha = 0.f;
            [UIView animateWithDuration:mv_Animation_duration
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 [self.contentView setFrame:CGRectMake((self.frame.size.width - self.contentView.frame.size.width)/2 , 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
                             } completion:^(BOOL finished) {}];
        }
            break;
        default:
            //nothing
            break;
    }
}

+ (void)dismiss
{
    [[self sharedMaskView] _dismissMaskView];
}

- (void)_dismissMaskView
{
    switch (self.maskType)
    {
        case MaskViewAlertType:
        {
            [UIView animateWithDuration:0.05f
                             animations:^{
                                 self.contentView.transform = CGAffineTransformMakeScale(1.1, 1.1);
                                 self.contentView.alpha = 0.9f;
                             } completion:^(BOOL finished) {
                                 [UIView animateWithDuration:0.3f
                                                       delay:0
                                                     options:UIViewAnimationOptionCurveEaseOut
                                                  animations:^{
                                                      self.contentView.alpha = 0.4f;
                                                      self.contentView.transform = CGAffineTransformMakeScale(0.01, 0.01);
                                                      self.backView.alpha = 0.2f;
                                                  } completion:^(BOOL finished) {
                                                      self.canTouchDismiss = YES;
                                                      [self removeFromSuperview];
                                                      [self.contentView removeFromSuperview];
                                                      self.contentView = nil;
                                                      //
                                                      if (self.showQueueBlock) {
                                                          self.showQueueBlock();
                                                      }
                                                  }];
                             }];
        }
            break;
        case MaskViewActionSheetType:
        {
            [UIView animateWithDuration:mv_Animation_duration
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.backView.alpha = 0.05f;
                                 [self.contentView setFrame:CGRectMake((self.frame.size.width - self.contentView.frame.size.width)/2 , self.frame.size.height, self.contentView.frame.size.width, self.contentView.frame.size.height)];
                             } completion:^(BOOL finished) {
                                 self.canTouchDismiss = YES;
                                 [self removeFromSuperview];
                                 [self.contentView removeFromSuperview];
                                 self.contentView = nil;
                                 if (self.showQueueBlock) {
                                     self.showQueueBlock();
                                 }
                             }];
        }
            break;
        case MaskViewNotificationType:
        {
            [UIView animateWithDuration:mv_Animation_duration
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.backView.alpha = 0.05f;
                                 [self.contentView setFrame:CGRectMake((self.frame.size.width - self.contentView.frame.size.width)/2 , -self.contentView.frame.size.height, self.contentView.frame.size.width, self.contentView.frame.size.height)];
                             } completion:^(BOOL finished) {
                                 self.canTouchDismiss = YES;
                                 [self removeFromSuperview];
                                 [self.contentView removeFromSuperview];
                                 self.contentView = nil;
                                 if (self.showQueueBlock) {
                                     self.showQueueBlock();
                                 }
                             }];
        }
            break;
        case MaskViewNotificationClearType:
        {
            [UIView animateWithDuration:mv_Animation_duration
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 
                                 [self.contentView setFrame:CGRectMake((self.frame.size.width - self.contentView.frame.size.width)/2 , -self.contentView.frame.size.height, self.contentView.frame.size.width, self.contentView.frame.size.height)];
                             } completion:^(BOOL finished) {
                                 self.canTouchDismiss = YES;
                                 [self removeFromSuperview];
                                 [self.contentView removeFromSuperview];
                                 self.contentView = nil;
                                 if (self.showQueueBlock) {
                                     self.showQueueBlock();
                                 }
                             }];
        }
            break;
        default:
            //nothing
            break;
    }
}

+ (BOOL)currentShowView
{
    if ([[self sharedMaskView] superview] != nil && [[[self sharedMaskView] contentView] superview] != nil)
    {
        return YES;
    }
    return NO;
}
@end
