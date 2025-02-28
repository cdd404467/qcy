//
//  ProductDetailsVC.m
//  QCY
//
//  Created by i7colors on 2018/9/25.
//  Copyright © 2018年 Shanghai i7colors Ecommerce Co., Ltd. All rights reserved.
//

#import "ProductDetailsVC.h"
#import "ProductDetailHeaderView.h"
#import "UIView+Border.h"
#import <SDAutoLayout.h>
#import "ClassTool.h"
#import "NetWorkingPort.h"
#import "CddHUD.h"
#import "ProductDetailBasicParaCell.h"
#import "ProductDetailSectionHeader.h"
#import "OpenMallModel.h"
#import "HelperTool.h"
#import "ShopMainPageVC.h"
#import "MyServiceVC.h"
#import <XHWebImageAutoSize.h>
#import "ImageCell.h"
#import <UIImageView+WebCache.h>
#import <WXApi.h>


@interface ProductDetailsVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)ProductInfoModel *dataSource;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation ProductDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavBar];
    [self requestData];
}

- (void)setNavBar {
    self.title = @"产品详情";
    if([WXApi isWXAppInstalled]){//判断用户是否已安装微信App
        [self addRightBarButtonItemWithTitle:@"分享" action:@selector(share)];
    }
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, NAV_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAV_HEIGHT - TABBAR_HEIGHT) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = Cell_BGColor;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.bounces = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        //取消垂直滚动条
        _tableView.showsVerticalScrollIndicator = NO;
        if (@available(iOS 11.0, *)) {
            //            _tableView.estimatedRowHeight = 0;
            _tableView.estimatedSectionHeaderHeight = 0;
            _tableView.estimatedSectionFooterHeight = 0;
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } 
//        _tableView.contentInset = UIEdgeInsetsMake(NAV_HEIGHT, 0, TABBAR_HEIGHT, 0);
//        _tableView.scrollIndicatorInsets = _tableView.contentInset;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        ProductDetailHeaderView *header = [[ProductDetailHeaderView alloc] initWithDataSource:_dataSource];
        header.frame = CGRectMake(0, 0, SCREEN_WIDTH, header.viewHeight);
        _tableView.tableHeaderView = header;
        UIView *footer = [[UIView alloc] init];
        footer.backgroundColor = Cell_BGColor;
        footer.frame = CGRectMake(0, 0, SCREEN_WIDTH, 50);
        _tableView.tableFooterView = footer;
    }
    return _tableView;
}

- (void)requestData {
   
    NSString *urlString = [NSString stringWithFormat:URL_Product_DetailInfo,_productID];
    
    [CddHUD show:self.view];
    DDWeakSelf;
    [ClassTool getRequest:urlString Params:nil Success:^(id json) {
        [CddHUD hideHUD:weakself.view];
//                NSLog(@"---- %@",json);
        if ([To_String(json[@"code"]) isEqualToString:@"SUCCESS"]) {
            weakself.dataSource = [ProductInfoModel mj_objectWithKeyValues:json[@"data"]];
            weakself.dataSource.propMap = [PropMap mj_objectArrayWithKeyValuesArray:weakself.dataSource.propMap];
            [weakself setupBottomBar];
        }
    } Failure:^(NSError *error) {
        NSLog(@" Error : %@",error);
        
    }];
}

#pragma mark - 分享
- (void)share{
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:0];
    if isRightData(_dataSource.pic) {
        [imageArray addObject:ImgStr(_dataSource.pic)];
    } else {
        [imageArray addObject:Logo];
    }
    NSString *shareStr = [NSString stringWithFormat:@"http://%@.i7colors.com/groupBuyMobile/openApp/shopDetails.html?id=%@",ShareString,_productID];

    [ClassTool shareSomething:imageArray urlStr:shareStr title:_dataSource.productName text:_dataSource.companyName];
}

//一键呼叫
- (void)callPhone {
    NSString *phoneNum = [NSString string];
    if isRightData(_dataSource.phone) {
        phoneNum = _dataSource.phone;
    } else {
        phoneNum = CompanyContact;
    }
    NSString *tel = [NSString stringWithFormat:@"tel://%@",phoneNum];
    //开线程，解决ios10调用慢的问题
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication.sharedApplication openURL:[NSURL URLWithString:tel]];
        });
    });
}

//跳转到开放商城主页

- (void)gotoShoppimgMain {
    ShopMainPageVC *vc = [[ShopMainPageVC alloc] init];
    vc.storeID = _dataSource.shopId;
    [self.navigationController pushViewController:vc animated:YES];
}

//客服
- (void)jumpToService {
    MyServiceVC *vc = [[MyServiceVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableView代理
//section header高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 51;
    } else {
        return 0.00001;
    }
}

//section footer高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.00001;
}

//分区数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

//cell个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if (_dataSource.propMap.count == 0) {
            return 1;
        } else {
            return _dataSource.propMap.count;
        }
    } else {
        if (_dataSource.detailPicList.count > 0)
            return _dataSource.detailPicList.count;
        return 0;
    }
}

//自定义的section header
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        ProductDetailSectionHeader *header = [ProductDetailSectionHeader headerWithTableView:tableView];
        return header;
    }
    return nil;
}

//估算高度
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 44;
}

//cell高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (_dataSource.propMap.count == 0) {
            return 60;
        } else {
            return UITableViewAutomaticDimension;
        }
    } else {
        return [XHWebImageAutoSize imageHeightForURL:ImgUrl(_dataSource.detailPicList[indexPath.row]) layoutWidth:SCREEN_WIDTH estimateHeight:200];
    }
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 圆角弧度半径
    CGFloat cornerRadius = 10.f;
    // 设置cell的背景色为透明，如果不设置这个的话，则原来的背景色不会被覆盖
    cell.backgroundColor = UIColor.clearColor;
    
    // 创建一个shapeLayer
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    CAShapeLayer *backgroundLayer = [[CAShapeLayer alloc] init]; //显示选中
    // 创建一个可变的图像Path句柄，该路径用于保存绘图信息
    CGMutablePathRef pathRef = CGPathCreateMutable();
    // 获取cell的size
    // 第一个参数,是整个 cell 的 bounds, 第二个参数是距左右两端的距离,第三个参数是距上下两端的距离
    CGRect bounds = CGRectInset(cell.bounds, 13, 0);
    
    // CGRectGetMinY：返回对象顶点坐标
    // CGRectGetMaxY：返回对象底点坐标
    // CGRectGetMinX：返回对象左边缘坐标
    // CGRectGetMaxX：返回对象右边缘坐标
    // CGRectGetMidX: 返回对象中心点的X坐标
    // CGRectGetMidY: 返回对象中心点的Y坐标
    
    // 这里要判断分组列表中的第一行，每组section的第一行，每组section的中间行
    
    // CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
//    if (indexPath.row == 0) {
//        // 初始起点为cell的左下角坐标
//        CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
//        // 起始坐标为左下角，设为p，（CGRectGetMinX(bounds), CGRectGetMinY(bounds)）为左上角的点，设为p1(x1,y1)，(CGRectGetMidX(bounds), CGRectGetMinY(bounds))为顶部中点的点，设为p2(x2,y2)。然后连接p1和p2为一条直线l1，连接初始点p到p1成一条直线l，则在两条直线相交处绘制弧度为r的圆角。
//        CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
//        CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
//        // 终点坐标为右下角坐标点，把绘图信息都放到路径中去,根据这些路径就构成了一块区域了
//        CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
//        CGPathCloseSubpath(pathRef);
//
//    } else
    
    if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
        // 初始起点为cell的左上角坐标
        CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
        // 添加一条直线，终点坐标为右下角坐标点并放到路径中去
        CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
    } else {
        // 添加cell的rectangle信息到path中（不包括圆角）
        CGPathAddRect(pathRef, nil, bounds);
    }
    // 把已经绘制好的可变图像路径赋值给图层，然后图层根据这图像path进行图像渲染render
    layer.path = pathRef;
    backgroundLayer.path = pathRef;
    // 注意：但凡通过Quartz2D中带有creat/copy/retain方法创建出来的值都必须要释放
    CFRelease(pathRef);
    // 按照shape layer的path填充颜色，类似于渲染render
    //     layer.fillColor = [UIColor colorWithWhite:1.f alpha:0.8f].CGColor;
    layer.fillColor = [UIColor whiteColor].CGColor;
//    layer.strokeColor = [UIColor lightGrayColor].CGColor;
    
    // view大小与cell一致
    UIView *roundView = [[UIView alloc] initWithFrame:bounds];
    // 添加自定义圆角后的图层到roundView中
    [roundView.layer insertSublayer:layer atIndex:0];
    roundView.backgroundColor = UIColor.clearColor;
    // cell的背景view
    cell.backgroundView = roundView;
    
    // 以上方法存在缺陷当点击cell时还是出现cell方形效果，因此还需要添加以下方法
    // 如果你 cell 已经取消选中状态的话,那以下方法是不需要的.
    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:bounds];
    backgroundLayer.fillColor = [UIColor cyanColor].CGColor;
    [selectedBackgroundView.layer insertSublayer:backgroundLayer atIndex:0];
    selectedBackgroundView.backgroundColor = UIColor.clearColor;
    cell.selectedBackgroundView = selectedBackgroundView;
    
}


//数据源
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        ProductDetailBasicParaCell *cell = [ProductDetailBasicParaCell cellWithTableView:tableView];
        if (_dataSource.propMap.count == 0) {
            cell.noneLabel.hidden = NO;
            cell.vLine.hidden = YES;
        } else {
            cell.noneLabel.hidden = YES;
            cell.vLine.hidden = NO;
            cell.model = _dataSource.propMap[indexPath.row];
        }
        
        return cell;
    } else {
        static NSString *identifier = @"imageCell";
        ImageCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[ImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        [cell.cellImageView sd_setImageWithURL:ImgUrl(_dataSource.detailPicList[indexPath.row]) placeholderImage:PlaceHolderImg completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            /** 缓存image size */
            [XHWebImageAutoSize storeImageSize:image forURL:imageURL completed:^(BOOL result) {
                /** reload  */
                if(result)  [tableView  xh_reloadDataForURL:imageURL];
            }];
        }];
        
        return cell;
    }
}

- (void)setupBottomBar {
    [self.view addSubview:self.tableView];
    UIView *bottomView = [[UIView alloc] init];
    [self.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-Bottom_Height_Dif);
        make.height.mas_equalTo(49);
    }];
    
    //进入店铺
    UIButton *goInToShop = [UIButton buttonWithType:UIButtonTypeCustom];
    goInToShop.backgroundColor = View_Color;
    goInToShop.frame = CGRectMake(0, 0, KFit_W(60), 49);
    [goInToShop addBorderLayer:LineColor width:1.f direction:BorderDirectionRight];
    [goInToShop setImage:[UIImage imageNamed:@"shop_icon"] forState:UIControlStateNormal];
    [goInToShop setTitle:@"进入店铺" forState:UIControlStateNormal];
    [goInToShop setTitleColor:HEXColor(@"#333333", 1) forState:UIControlStateNormal];
    goInToShop.titleLabel.font = [UIFont systemFontOfSize:10];
    goInToShop.titleLabel.textAlignment = NSTextAlignmentCenter;
    goInToShop.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [goInToShop addTarget:self action:@selector(gotoShoppimgMain) forControlEvents:UIControlEventTouchUpInside];
    goInToShop.adjustsImageWhenHighlighted = NO;
    [bottomView addSubview:goInToShop];
    
    goInToShop.imageView.sd_layout
    .topSpaceToView(goInToShop, 7)
    .centerXEqualToView(goInToShop)
    .widthIs(23)
    .heightIs(20);
    
    goInToShop.titleLabel.sd_layout
    .bottomSpaceToView(goInToShop, 7)
    .leftEqualToView(goInToShop)
    .rightEqualToView(goInToShop)
    .heightIs(12);
    
    //联系客服
    UIButton *contactService = [UIButton buttonWithType:UIButtonTypeCustom];
    contactService.backgroundColor = View_Color;
    contactService.frame = CGRectMake(goInToShop.frame.size.width, 0, goInToShop.frame.size.width, 49);
    [contactService setImage:[UIImage imageNamed:@"contact_icon"] forState:UIControlStateNormal];
    [contactService setTitle:@"联系客服" forState:UIControlStateNormal];
    [contactService setTitleColor:HEXColor(@"#333333", 1) forState:UIControlStateNormal];
    contactService.titleLabel.font = [UIFont systemFontOfSize:10];
    contactService.titleLabel.textAlignment = NSTextAlignmentCenter;
    contactService.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [contactService addTarget:self action:@selector(jumpToService) forControlEvents:UIControlEventTouchUpInside];
    contactService.adjustsImageWhenHighlighted = NO;
    [bottomView addSubview:contactService];
    
    contactService.imageView.sd_layout
    .topSpaceToView(contactService, 7)
    .centerXEqualToView(contactService)
    .widthIs(23)
    .heightIs(20);
    
    contactService.titleLabel.sd_layout
    .bottomSpaceToView(contactService, 7)
    .leftEqualToView(contactService)
    .rightEqualToView(contactService)
    .heightIs(12);
    
    //一键呼叫
    UIButton *callBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    callBtn.frame = CGRectMake(goInToShop.frame.size.width * 2, 0, SCREEN_WIDTH - goInToShop.frame.size.width * 2, 49);
    callBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [callBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [callBtn setImage:[UIImage imageNamed:@"phone_icon"] forState:UIControlStateNormal];
    [callBtn setTitle:@"一键呼叫" forState:UIControlStateNormal];
    callBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    callBtn.adjustsImageWhenHighlighted = NO;
    [callBtn addTarget:self action:@selector(callPhone) forControlEvents:UIControlEventTouchUpInside];
    callBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    CGRect rect = CGRectMake(0, 0, callBtn.frame.size.width, 49);
    [ClassTool addLayer:callBtn frame:rect];
    [callBtn bringSubviewToFront:callBtn.titleLabel];
    [callBtn bringSubviewToFront:callBtn.imageView];
    [bottomView addSubview:callBtn];
    
    callBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);
    callBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
}


- (NSArray *)dealWithData:(ProductInfoModel *)model {
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
    //染料、助剂、其他
    if (isRightData(@(model.price).stringValue) && [model.displayPrice isEqualToString:@"1"])
        [tempArr addObject:@{@"key":@"单位", @"value":model.unit}];
    
    if (isRightData(@(model.price).stringValue) && [model.displayPrice isEqualToString:@"1"])
        [tempArr addObject:@{@"key":@"价格", @"value":@(model.price).stringValue}];

    if (isRightData(model.priceUnit))
        [tempArr addObject:@{@"key":@"价格单位", @"value":model.priceUnit}];

    if (isRightData(model.pack))
        [tempArr addObject:@{@"key":@"包装规格", @"value":model.pack}];
    
    if (isRightData(model.supplierName))
        [tempArr addObject:@{@"key":@"生产厂商", @"value":model.supplierName}];
    
    if (isRightData(model.packLabel))
        [tempArr addObject:@{@"key":@"包装形式", @"value":model.packLabel}];
    
    if (isRightData(model.minNum))
        [tempArr addObject:@{@"key":@"起订数量", @"value":model.minNum}];
    
    //化学品
    if (isRightData(model.fineness))
        [tempArr addObject:@{@"key":@"纯度", @"value":model.fineness}];
    
    //设备仪器
    if (isRightData(model.brand))
        [tempArr addObject:@{@"key":@"品牌", @"value":model.brand}];
    
    if (isRightData(model.modelNumber))
        [tempArr addObject:@{@"key":@"型号", @"value":model.modelNumber}];
    
    if (isRightData(model.origin))
        [tempArr addObject:@{@"key":@"产地", @"value":model.origin}];
    
    if (isRightData(model.dateInProduced))
        [tempArr addObject:@{@"key":@"生产日期", @"value":model.dateInProduced}];
    
    if (isRightData(model.overallDimensions))
        [tempArr addObject:@{@"key":@"外形尺寸", @"value":model.overallDimensions}];
    
    //纺织品
    if (isRightData(model.num))
        [tempArr addObject:@{@"key":@"数量", @"value":model.num}];
    
    if (isRightData(model.colors))
        [tempArr addObject:@{@"key":@"颜色", @"value":model.colors}];
    
    if (isRightData(model.componentContent))
        [tempArr addObject:@{@"key":@"成分含量", @"value":model.componentContent}];
    
    if (isRightData(model.yarnCount))
        [tempArr addObject:@{@"key":@"纱支", @"value":model.yarnCount}];
    
    if (isRightData(model.densityOf))
        [tempArr addObject:@{@"key":@"密度", @"value":model.densityOf}];
    
    if (isRightData(model.gramWeight))
        [tempArr addObject:@{@"key":@"克重", @"value":model.gramWeight}];
    
    if (isRightData(model.breadth))
        [tempArr addObject:@{@"key":@"幅宽", @"value":model.breadth}];
    
    if (isRightData(model.fabric))
        [tempArr addObject:@{@"key":@"织物组织", @"value":model.fabric}];
    
    if (isRightData(model.specificPurpose))
        [tempArr addObject:@{@"key":@"具体用途", @"value":model.specificPurpose}];
    
    return [PropMap mj_objectArrayWithKeyValuesArray:[tempArr copy]];
//    return [tempArr copy];
}


@end
