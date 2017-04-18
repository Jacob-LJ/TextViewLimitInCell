//
//  LimitTextView.h
//  TextViewLimitInCellDemo
//
//  Created by Jacob on 2017/4/11.
//  Copyright © 2017年 Jacob. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LimitTextViewDelegate <NSObject>

- (void)beyondLimitNum;

@end

@interface LimitTextView : UITextView<UITextViewDelegate>

@property (nonatomic, assign) NSInteger limitNum;      //限制输入的字数，不赋值就是不限制字数
@property (nonatomic, assign) BOOL autoHeight;         //根据输入文本自适应行高，默认不自适应
@property (nonatomic, strong) NSString *placeHolder;     //placehold的文字，不设置就不显示
@property (nonatomic, strong) UIFont *placeHolderFont;   //placehold的字号
@property (nonatomic, strong) UIColor *placeHolderColor;
@property (nonatomic, assign) BOOL centerPlaceHolderFirst;/**< 是否居中显示placehoder Default NO*/
@property (nonatomic, assign) id <LimitTextViewDelegate> limitdelegate;

@end
