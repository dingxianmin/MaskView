//
//  ViewController.m
//  MaskView
//
//  Created by invoker on 16/3/8.
//  Copyright © 2016年 QQQ. All rights reserved.
//

#import "ViewController.h"
#import "MaskView.h"
#import "TestView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showMaskView:(id)sender {
    TestView *testView = [[TestView alloc] initWithFrame:CGRectMake(0, 0, 280, 200)];
    [testView setBackgroundColor:[UIColor whiteColor]];
    [MaskView showAlertTypeView:testView maskViewTouchableDismiss:YES];
}

@end