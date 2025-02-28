//
//  ProductDetailHeaderView.h
//  QCY
//
//  Created by i7colors on 2018/10/31.
//  Copyright © 2018年 Shanghai i7colors Ecommerce Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ProductInfoModel;

NS_ASSUME_NONNULL_BEGIN

@interface ProductDetailHeaderView : UIView
- (instancetype)initWithDataSource:(ProductInfoModel *)dataSource;
@property (nonatomic, assign)CGFloat viewHeight;
@end

NS_ASSUME_NONNULL_END
