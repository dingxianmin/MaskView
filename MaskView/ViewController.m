//
//  ViewController.m
//  MaskView
//
//  Created by invoker on 16/3/8.
//  Copyright © 2016年 QQQ. All rights reserved.
//

#import "ViewController.h"
#import "MaskView.h"
#import "CustomController_Alert.h"
#import "CustomController_ActionSheet.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"MaskView";
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showAlertMaskView:(id)sender {
    CustomController_Alert *alertView = [[CustomController_Alert alloc] initWithFrame:CGRectMake(0, 0, 280, 200)];
    [alertView setBackgroundColor:[UIColor whiteColor]];
    alertView.layer.cornerRadius = 4.f;
    alertView.layer.masksToBounds = YES;
    [MaskView showAlertTypeView:alertView maskViewTouchableDismiss:YES];
}

- (IBAction)showActionSheetMaskView:(id)sender {
    CustomController_ActionSheet *actionSheetView = [[CustomController_ActionSheet alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
    [actionSheetView setBackgroundColor:[UIColor whiteColor]];
    [MaskView showActionSheetTypeView:actionSheetView maskViewTouchableDismiss:YES];
}

@end