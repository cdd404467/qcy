//
//  PLView.h
//  QCY
//
//  Created by i7colors on 2018/11/29.
//  Copyright © 2018 Shanghai i7colors Ecommerce Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CommentListModel;

NS_ASSUME_NONNULL_BEGIN

typedef void (^ClickTextBlock)(NSInteger index);
//点击评论人名字，跳转
typedef void (^ClickNameBlock)(CommentListModel *model , NSString *type);

@interface PLView : UIView

@property (nonatomic, strong)CommentListModel *commentModel;
@property (nonatomic, assign)CGFloat labelWidth;
@property (nonatomic, copy)ClickTextBlock clickTextBlock;
@property (nonatomic, copy)ClickNameBlock clickNameBlock;
@property (nonatomic, assign)NSInteger index;  //是这个数组里的第几条评论
@end

NS_ASSUME_NONNULL_END
