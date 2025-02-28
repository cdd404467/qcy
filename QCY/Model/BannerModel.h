//
//  BannerModel.h
//  QCY
//
//  Created by i7colors on 2019/10/9.
//  Copyright © 2019 Shanghai i7colors Ecommerce Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MJExtension.h>

NS_ASSUME_NONNULL_BEGIN

@interface BannerModel : NSObject
//轮播图片
@property (nonatomic, copy) NSString *ad_image;
//活动名字
@property (nonatomic, copy) NSString *plate_code;
//活动名字
@property (nonatomic, copy) NSString *ad_name;
//活动链接
@property (nonatomic, copy) NSString *ad_url;
//广告类型，type=inner内部跳转。type=html外链。如果type= null则是默认外部链接。链接也可能为空
@property (nonatomic, copy) NSString *type;
//跳转模块，enquiry求购，groupBuy团购，auction抢购，market店铺，product产品，information资讯,zhuji助剂定制
@property (nonatomic, copy) NSString *directType;
//模块id，如果为空，则是跳转列表
@property (nonatomic, copy) NSString *directTypeId;



/*** 消息通知中的消息类型 ***/
@property (nonatomic, copy) NSString *workType;
/*** 首页icon的中文名字 ***/
@property (nonatomic, copy) NSString *ad_desc;
@end

NS_ASSUME_NONNULL_END
