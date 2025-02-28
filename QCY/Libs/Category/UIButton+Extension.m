//
//  UIButton+Extension.m
//  SH
//
//  Created by i7colors on 2019/9/4.
//  Copyright © 2019 surhoo. All rights reserved.
//

#import "UIButton+Extension.h"
#import <objc/runtime.h>

typedef void(^ButtonEventsBlock)(void);

@interface UIButton()
/** 事件回调的block */
@property (nonatomic, copy) ButtonEventsBlock buttonEventsBlock;
@end

@implementation UIButton (Extension)
#pragma mark - 图片文字位置和间距
- (void)layoutWithEdgeInsetsStyle:(ButtonEdgeInsetsStyle)style
                        imageTitleSpace:(CGFloat)space {
    /**
     *  知识点：titleEdgeInsets是title相对于其上下左右的inset，跟tableView的contentInset是类似的，
     *  如果只有title，那它上下左右都是相对于button的，image也是一样；
     *  如果同时有image和label，那这时候image的上左下是相对于button，右边是相对于label的；title的上右下是相对于button，左边是相对于image的。
     */
    
    // 1. 得到imageView和titleLabel的宽、高
    CGFloat imageWith = self.imageView.image.size.width;
    CGFloat imageHeight = self.imageView.image.size.height;
    
    CGFloat labelWidth = 0.0;
    CGFloat labelHeight = 0.0;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        // 由于iOS8中titleLabel的size为0，用下面的这种设置
        labelWidth = self.titleLabel.intrinsicContentSize.width;
        labelHeight = self.titleLabel.intrinsicContentSize.height;
    } else {
        labelWidth = self.titleLabel.frame.size.width;
        labelHeight = self.titleLabel.frame.size.height;
    }
    
    // 2. 声明全局的imageEdgeInsets和labelEdgeInsets
    UIEdgeInsets imageEdgeInsets = UIEdgeInsetsZero;
    UIEdgeInsets labelEdgeInsets = UIEdgeInsetsZero;
    
    // 3. 根据style和space得到imageEdgeInsets和labelEdgeInsets的值
    
    switch (style) {
        case ButtonEdgeInsetsStyleTop:
        {
            imageEdgeInsets = UIEdgeInsetsMake(-labelHeight-space, 0, 0, -labelWidth);
            labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith, -imageHeight-space, 0);
        }
            break;
        case ButtonEdgeInsetsStyleLeft:
        {
            imageEdgeInsets = UIEdgeInsetsMake(0, -space, 0, space);
            labelEdgeInsets = UIEdgeInsetsMake(0, space, 0, -space);
        }
            break;
        case ButtonEdgeInsetsStyleBottom:
        {
            imageEdgeInsets = UIEdgeInsetsMake(0, 0, -labelHeight-space, -labelWidth);
            labelEdgeInsets = UIEdgeInsetsMake(-imageHeight-space, -imageWith, 0, 0);
        }
            break;
        case ButtonEdgeInsetsStyleRight:
        {
            imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth+space, 0, -labelWidth-space);
            labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith-space, 0, imageWith+space);
        }
            break;
        default:
            break;
    }
    
    // 4. 赋值
    self.titleEdgeInsets = labelEdgeInsets;
    self.imageEdgeInsets = imageEdgeInsets;
}


#pragma mark - button的block
//------- 添加属性 -------//

static void *my_buttonEventsBlockKey = &my_buttonEventsBlockKey;

- (ButtonEventsBlock)buttonEventsBlock {
    return objc_getAssociatedObject(self, &my_buttonEventsBlockKey);
}

- (void)setButtonEventsBlock:(ButtonEventsBlock)buttonEventsBlock {
    objc_setAssociatedObject(self, &my_buttonEventsBlockKey, buttonEventsBlock, OBJC_ASSOCIATION_COPY);
}

- (void)addEventHandler:(void (^)(void))block {
    self.buttonEventsBlock = block;
    [self addTarget:self action:@selector(addEventHandler) forControlEvents:UIControlEventTouchUpInside];
}

// 按钮点击
- (void)addEventHandler {
    !self.buttonEventsBlock ?: self.buttonEventsBlock();
}

@end
