//
//  CddHUD.m
//  QCY
//
//  Created by i7colors on 2018/10/21.
//  Copyright © 2018年 Shanghai i7colors Ecommerce Co., Ltd. All rights reserved.
//

#import "CddHUD.h"


#define DELAY_TIME 1.5f
@implementation CddHUD

+ (MBProgressHUD *)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view onlyText:(BOOL)isOnly delay:(NSTimeInterval)duration {
    if (view == nil)
        view = [[UIApplication sharedApplication].windows lastObject];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled= NO;
    hud.bezelView.color = [UIColor blackColor];
    hud.contentColor = [UIColor whiteColor];
    if (icon != nil) {
        hud.mode = MBProgressHUDModeCustomView;
        UIImage *image = [[UIImage imageNamed:icon] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        hud.customView = [[UIImageView alloc] initWithImage:image];
    }
    if (isOnly == YES) {
        hud.mode = MBProgressHUDModeText;
    }
    hud.margin = 20;
    hud.label.text = text;
    //不设置的话hud为半透明
    hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
    //蒙版
//    hud.backgroundView.color = RGBA(0, 0, 0, 0.2);
    hud.removeFromSuperViewOnHide = YES;
    
    if (duration != 0) {
        [hud hideAnimated:YES afterDelay:DELAY_TIME];
    }
    
    return hud;
}

/*** 只显示菊花 ***/
+ (MBProgressHUD *)show:(UIView *)view {
    return [self show:nil icon:nil view:view onlyText:NO delay:0];
}

/*** 只显示文本 ***/
+ (void)showTextOnly:(NSString *)text view:(UIView *)view {
    [self show:text icon:nil view:view onlyText:YES delay:0];
}


/*** 只显示文本,延时关闭 ***/
+ (void)showTextOnlyDelay:(NSString *)text view:(UIView *)view {
    [self show:text icon:nil view:view onlyText:YES delay:DELAY_TIME];
}
/*** 只显示文本,延时关闭，自定义时间 ***/
+ (void)showTextOnlyDelay:(NSString *)text view:(UIView *)view delay:(NSTimeInterval)duration {
    [self show:text icon:nil view:view onlyText:YES delay:duration];
}

/*** 菊花和文本 ***/
+ (MBProgressHUD *)showWithText:(NSString *)text view:(UIView *)view {
    return [self show:text icon:nil view:view onlyText:NO delay:0];
}


/*** 关闭hud ***/
+ (void)hideHUD:(UIView * _Nullable)view {
    if (view == nil)
        view = [[UIApplication sharedApplication].windows lastObject];
    
    [MBProgressHUD hideHUDForView:view animated:YES];
}


+ (void)showSwitchText:(MBProgressHUD *)hud text:(NSString *)text {
    hud.mode = MBProgressHUDModeText;
    hud.label.text = text;
    [hud hideAnimated:YES afterDelay:DELAY_TIME];
}




@end
