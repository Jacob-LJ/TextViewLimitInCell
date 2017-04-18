//
//  LimitTextView.m
//  TextViewLimitInCellDemo
//
//  Created by Jacob on 2017/4/11.
//  Copyright © 2017年 Jacob. All rights reserved.
//

#import "LimitTextView.h"
#import "NSString+UnicoLengthCaculate.h"

@interface LimitTextView()

@property (nonatomic, strong) UILabel *placeHolderLabel;
@property (nonatomic, strong) NSString *limitString;   //用来存储当前输入的第一次超过时从中截取的符合字数限制的string

@end

@implementation LimitTextView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        [self setUpInit];
    }
    return self;
}

- (void)setUpInit {
    
}

- (void)createPlaceHolderLabel {
    
    _placeHolderLabel = [[UILabel alloc] init];
    _placeHolderLabel.text = _placeHolder;
    if (!_placeHolderFont) _placeHolderFont = [self _defaultFont];
    if (_placeHolderFont) _placeHolderLabel.font = _placeHolderFont;
    _placeHolderLabel.textColor = [self _defaultPlaceholderColor];
    _placeHolderLabel.numberOfLines = 0;
    _placeHolderLabel.lineBreakMode = NSLineBreakByCharWrapping;
    
    CGFloat labelWidth = self.frame.size.width - 10;
    CGSize size = CGSizeMake(labelWidth, MAXFLOAT);
    //获取当前文本的属性
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:self.font,NSFontAttributeName,nil];
    //获取文本需要的size，限制宽度
    CGSize actualSize = [_placeHolder boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:tdic context:nil].size;
    _placeHolderLabel.frame = CGRectMake(5, 5, labelWidth, actualSize.height);
    [self centerPlaceHolder];
    [self addSubview:_placeHolderLabel];
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    if (self.placeHolder.length > 0) {
        if (self.text.length == 0) {
            self.placeHolderLabel.hidden = NO;
        } else {
            self.placeHolderLabel.hidden = YES;
        }
    }
    
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    //如果在变化中是高亮部分在变，就不计算字符
    if (selectedRange && pos) {
        return;
    }
    
    //字数超过后通过退格键把字数删除到符合限制的范围内，会调用这个函数
    //将limitString赋值为@“”，方便下一次循环判断
    if ([textView.text charNumber] <= self.limitNum * 2 && ![self.limitString isEqualToString:@""]) {
        self.limitString = @"";
    }
    
    //超过规定的字数时
    if ([textView.text charNumber] > self.limitNum * 2) {
        //判断是否是普通的字符或asc码，我就是拿来判断是不是纯英文
        BOOL asc = [textView.text canBeConvertedToEncoding:NSASCIIStringEncoding];
        if (asc) {
            //是纯英文就好办，可以直接截取相应的字符数用来显示
            NSString *str = [textView.text substringToIndex:self.limitNum * 2];
            if ([self.limitdelegate respondsToSelector:@selector(beyondLimitNum)]) {
                [self.limitdelegate beyondLimitNum];
            }
            [textView setText:str];
        } else {
            //当前输入的第一次超过才会进行循环截取，如果继续输入直接赋值为截取的符合字数限制的字符串，避免再次循环
            if ([self.limitString isEqualToString:@""]) {
                //如果是中英文混合输入，那么就不能单纯用substringToIndex截取，因为它一视同仁
                //不管中英文都当做一个单位来截断
                __block NSString *str = [[NSString alloc] init];
                __block NSInteger num = 0;
                __weak LimitTextView * bSelf = self;
                //逐字遍历，不管是中文英文，中文就按照字，英文就是按字母
                [textView.text enumerateSubstringsInRange:NSMakeRange(0, [textView.text length])
                                                  options:NSStringEnumerationByComposedCharacterSequences
                                               usingBlock: ^(NSString* substring, NSRange substringRange, NSRange enclosingRange, BOOL* stop) {
                                                   NSInteger subLen = [substring charNumber];
                                                   num += subLen;
                                                   NSLog(@"%ld", num);
                                                   if (num <= self.limitNum * 2) {
                                                       str  = [str stringByAppendingString:substring];
                                                   } else {
                                                       if ([bSelf.limitdelegate respondsToSelector:@selector(beyondLimitNum)]) {
                                                           [bSelf.limitdelegate beyondLimitNum];
                                                       }
                                                       self.limitString = str;
                                                       return;
                                                   }
                                               }];
                
            }
            [textView setText:self.limitString];
        }
    }
    
    //滚动到一个特定区域
    [self textViewIndicateMoveToCurrentPosition];
    //随着输入越多字数，textview不断变高
    if (self.autoHeight) {
        if (self.contentSize.height > self.frame.size.height) {
            CGRect frame = self.frame;
            frame.size.height = self.contentSize.height;
            self.frame = frame;
        }
    }
}


#pragma mark - Private
//滚动到一个特定区域（这里是保证固定高度时输入能一直可见，在最后一行）
- (void)textViewIndicateMoveToCurrentPosition {
    NSString *reqSysVer = @"7.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    if (osVersionSupported) {
        [self layoutIfNeeded];
        CGRect caretRect = [self caretRectForPosition:self.selectedTextRange.end];
        caretRect.size.height += self.textContainerInset.bottom;
        [self scrollRectToVisible:caretRect animated:NO];
    }
}


- (void)centerPlaceHolder {
    if (_centerPlaceHolderFirst) {
        
        CGFloat top = (self.contentSize.height - _placeHolderLabel.bounds.size.height)/2.0;
        self.contentInset = UIEdgeInsetsMake(top, 0, 0, 0);
        
        CGFloat y = (self.contentSize.height - _placeHolderLabel.bounds.size.height)/4.0 - 0.5;
        CGFloat x = _placeHolderLabel.frame.origin.x;
        CGFloat width = self.contentSize.width - _placeHolderLabel.frame.origin.x;
        CGFloat height = self.contentSize.height;
        _placeHolderLabel.frame = CGRectMake(x, -y, width, height);
    }
}

#pragma mark - getter & setter
#pragma mark super
- (void)setFont:(UIFont *)font {
    [super setFont:font];
    _placeHolderFont = font;
    _placeHolderLabel.font = font;
}

#pragma mark current property
- (void)setPlaceHolder:(NSString *)placeHolder {
    _placeHolder = placeHolder;
    if (placeHolder.length) {
        if (!_placeHolderLabel) {
            [self createPlaceHolderLabel];
        }
        _placeHolderLabel.text = _placeHolder;
    }
}

- (void)setPlaceHolderFont:(UIFont *)placeHolderFont {
    _placeHolderFont = placeHolderFont;
    _placeHolderLabel.font = placeHolderFont;
}

- (void)setPlaceHolderColor:(UIColor *)placeHolderColor {
    _placeHolderLabel.textColor = _placeHolderColor;
}

- (void)setCenterPlaceHolderFirst:(BOOL)centerPlaceHolderFirst {
    _centerPlaceHolderFirst = centerPlaceHolderFirst;
    [self centerPlaceHolder];
}

#pragma mark - default
/// Returns the default placeholder color for text view (same as UITextField).
- (UIColor *)_defaultPlaceholderColor {
    return [UIColor colorWithRed:0 green:0 blue:25/255.0 alpha:44/255.0];
}

/// Returns the default font for text view (same as CoreText).
- (UIFont *)_defaultFont {
    return [UIFont systemFontOfSize:12];
}

@end
