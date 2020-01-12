//
//  ViewController.m
//  PLPullPlayer
//
//  Created by HJQ on 2020/1/11.
//  Copyright © 2020 HJQ. All rights reserved.
//

#import "ViewController.h"
#import "OFweekPlayerTestVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    OFweekPlayerTestVC *VC = [OFweekPlayerTestVC new];
    [self.navigationController pushViewController:VC animated:YES];
}


@end
