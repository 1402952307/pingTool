//
//  ViewController.m
//  SimplePingDemo
//
//  Created by wanghe on 2017/5/15.
//  Copyright © 2017年 wanghe. All rights reserved.
//

#import "ViewController.h"
#import "AJDiagnosisToolVC.h"
#import "WHPingTester.h"

@interface ViewController ()<WHPingDelegate>
{
    UILabel* _pingLabel;
}
@property(nonatomic, strong) WHPingTester* pingTester;
@property(nonatomic, assign) int totalTime;
@property(nonatomic, strong) UITextView *txtView_log;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    AJDiagnosisToolVC *vc = [[AJDiagnosisToolVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
