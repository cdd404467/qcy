//
//  ProductMallVC_Cell.h
//  QCY
//
//  Created by i7colors on 2018/9/25.
//  Copyright © 2018年 Shanghai i7colors Ecommerce Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ProductInfoModel;

NS_ASSUME_NONNULL_BEGIN

@interface ProductMallVC_Cell : UITableViewCell

@property (nonatomic, strong)ProductInfoModel *model;
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end

NS_ASSUME_NONNULL_END
