//
//  UITextField+Limit.m
//  输出限制
//
//  Created by pc-005 on 2018/2/11.
//  Copyright © 2018年 lishuang. All rights reserved.
//

#import "UITextField+Limit.h"
#import <objc/runtime.h>


static const char max_length = '\0';
static const char value_changed_block = '\0';
static const char kObsever = '\0';
static const char kDisableEmoji = '\0';
@interface UITextField ()

@property (assign,nonatomic,getter=isObsevered) BOOL obsever;
@end

@implementation UITextField (Limit)

static char limit;

- (void)setLimitBlock:(LimitBlock)limitBlock {
    objc_setAssociatedObject(self, &limit, limitBlock, OBJC_ASSOCIATION_COPY);
}

- (LimitBlock)limitBlock {
    return objc_getAssociatedObject(self, &limit);
}

- (void)lengthLimit:(void (^)(void))limit {
    [self addTarget:self action:@selector(textFieldEditChanged:) forControlEvents:UIControlEventEditingChanged];
    self.limitBlock = limit;
}

- (void)textFieldEditChanged:(UITextField *)textField {
    NSString *lang = [[UIApplication sharedApplication]textInputMode].primaryLanguage; // 键盘输入模式
    // 简体中文输入，包括简体拼音，健体五笔，简体手写
    if ([lang isEqualToString:@"zh-Hans"]) {
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (self.limitBlock) {
                self.limitBlock();
            }
        }
    }
    
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (self.limitBlock) {
            self.limitBlock();
        }
        
    }
    
}

/*** 最新限制方式***/

-(void)setDisableEmoji:(BOOL)disableEmoji{
    
    objc_setAssociatedObject(self, &kDisableEmoji, [NSNumber numberWithBool:disableEmoji], OBJC_ASSOCIATION_RETAIN);
}



-(BOOL)isDisableEmoji{
    
    return [objc_getAssociatedObject(self, &kDisableEmoji) boolValue];
}

-(BOOL)isObsevered{
    
    return [objc_getAssociatedObject(self, &kObsever) boolValue];
}

-(void)setObsever:(BOOL)obsever{
    
    objc_setAssociatedObject(self, &kObsever, [NSNumber numberWithBool:obsever], OBJC_ASSOCIATION_RETAIN);
}

-(NSUInteger)maxLength{
    
    return [objc_getAssociatedObject(self, &max_length) integerValue];
}

-(void)setMaxLength:(NSUInteger)maxLength{
    objc_setAssociatedObject(self, &max_length, @(maxLength), OBJC_ASSOCIATION_RETAIN);
    
    if (!self.isObsevered) {
        [self addTarget:self action:@selector(mq_textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        self.obsever = YES;
    }
}


-(void)setValueChangedBlock:(void (^)(NSString *))valueChangedBlock{
    
    objc_setAssociatedObject(self, &value_changed_block, valueChangedBlock, OBJC_ASSOCIATION_COPY);
    if (!self.isObsevered) {
        [self addTarget:self action:@selector(mq_textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        self.obsever = YES;
    }
}


-(void(^)(NSString *))valueChangedBlock{
    
    return objc_getAssociatedObject(self, &value_changed_block);
}


- (void)mq_textFieldDidChange:(UITextField *)textField
{
    NSUInteger kMaxLength = [objc_getAssociatedObject(self, &max_length) integerValue];
    
    if (kMaxLength == 0) {
        
        kMaxLength = NSIntegerMax;
    }
    
    
    NSString *toBeString = textField.text;
    
    //获取高亮部分
    UITextRange *selectedRange = [textField markedTextRange];
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if (!position)
    {
        
        if (toBeString.length > kMaxLength)
        {
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:kMaxLength];
            if (rangeIndex.length == 1)
            {
                textField.text = [toBeString substringToIndex:kMaxLength];
            }
            else
            {
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, kMaxLength)];
                
                NSInteger tmpLength;
                if (rangeRange.length > kMaxLength) {
                    tmpLength = rangeRange.length - rangeIndex.length;
                }else{
                    
                    tmpLength = rangeRange.length;
                }
                textField.text = [toBeString substringWithRange:NSMakeRange(0, tmpLength)];
            }
        }
        
    }
    if (self.valueChangedBlock) {
        
        self.valueChangedBlock(self.text);
    }
    
}

@end

