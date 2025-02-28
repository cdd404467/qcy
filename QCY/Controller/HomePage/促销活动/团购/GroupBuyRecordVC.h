//
//  GroupBuyRecordVC.h
//  QCY
//
//  Created by i7colors on 2018/11/5.
//  Copyright © 2018 Shanghai i7colors Ecommerce Co., Ltd. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface GroupBuyRecordVC : BaseViewController

@property (nonatomic, copy)NSString *groupID;
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, copy)NSArray *titleArray;
@property (nonatomic, copy)NSString *type;
@property (nonatomic, strong)NSString *layoutStr;

@end

NS_ASSUME_NONNULL_END
