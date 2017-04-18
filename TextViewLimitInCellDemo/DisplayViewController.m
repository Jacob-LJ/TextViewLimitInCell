//
//  DisplayViewController.m
//  TextViewLimitInCellDemo
//
//  Created by Jacob on 2017/4/11.
//  Copyright © 2017年 Jacob. All rights reserved.
//

#import "DisplayViewController.h"
#import "LimitTextView.h"

@interface DisplayViewController ()<LimitTextViewDelegate>
//
@end

@implementation DisplayViewController

- (instancetype)init {
    if (self = [super init]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    LimitTextView *tx = [[LimitTextView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 50)];
    tx.backgroundColor = [UIColor lightGrayColor];
    tx.limitNum = 5;
    tx.autoHeight = YES;
    tx.placeHolder = @"我是placeholder,可以改变行高";
    tx.centerPlaceHolderFirst = YES;
    tx.limitdelegate = self;
    [self.view addSubview:tx];
    
}

- (void)beyondLimitNum {
    NSLog(@"超过了限制字数( ⊙ o ⊙ )啊！");
}

@end
