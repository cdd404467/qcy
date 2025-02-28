//
//  MineHeaderReusableView.h
//  QCY
//
//  Created by i7colors on 2018/10/21.
//  Copyright © 2018年 Shanghai i7colors Ecommerce Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^RightBtnClickBlock)(void);
@interface MineHeaderReusableView : UICollectionReusableView

@property (nonatomic, strong)UIImageView *leftImageView;
@property (nonatomic, strong)UILabel *leftLabel;
@property (nonatomic, strong)UIButton *rightBtn;

@property (nonatomic, copy) RightBtnClickBlock rightBtnClickBlock;
@end

NS_ASSUME_NONNULL_END
