//
//  ViewController.m
//  TextViewLimitInCellDemo
//
//  Created by Jacob on 2017/4/10.
//  Copyright © 2017年 Jacob. All rights reserved.
//

#import "ViewController.h"
#import "DisplayViewController.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    DisplayViewController *displayVC = [[DisplayViewController alloc] init];
    [self.navigationController pushViewController:displayVC animated:YES];
}

@end
