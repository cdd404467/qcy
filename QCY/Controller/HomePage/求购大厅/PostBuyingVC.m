//
//  PostBuyingVC.m
//  QCY
//
//  Created by i7colors on 2018/10/16.
//  Copyright © 2018年 Shanghai i7colors Ecommerce Co., Ltd. All rights reserved.
//

#import "PostBuyingVC.h"
#import "CommonNav.h"
#import "ClassTool.h"
#import "AskToBuyBottomView.h"
#import "NetWorkingPort.h"
#import <MJExtension.h>
#import "HomePageModel.h"
#import "BRPickerView.h"
#import "CddHUD.h"
#import "SelectedView.h"
#import "TimeAbout.h"
#import "HelperTool.h"

@interface PostBuyingVC ()<UITextFieldDelegate>
@property (nonatomic, strong)UIScrollView *scrollView;
@property (nonatomic, copy)NSArray *firstClassify;
@property (nonatomic, copy)NSArray *secondClassify;
@property (nonatomic, copy)NSString *supID;
@property (nonatomic, strong)AskToBuyBottomView *bView;
@property (nonatomic, strong)NSMutableArray *nameArr;
@property (nonatomic, strong)NSMutableArray *idArr;
@property (nonatomic, strong)NSMutableArray *nameArr_second;
@property (nonatomic, strong)NSMutableArray *idArr_second;
@property (nonatomic, copy)NSString *selectedFirstTitle;
@property (nonatomic, strong)NSDate *endDate;
@property (nonatomic, copy)NSString *allWeight;
@end

@implementation PostBuyingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"发布求购";
    
    [self.view addSubview:self.scrollView];
    [self setupUI];
//    [self getSupID];
}

- (NSMutableArray *)nameArr {
    if (!_nameArr) {
        _nameArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _nameArr;
}

- (NSMutableArray *)nameArr_second {
    if (!_nameArr_second) {
        _nameArr_second = [NSMutableArray arrayWithCapacity:0];
    }
    return _nameArr_second;
}

- (NSMutableArray *)idArr {
    if (!_idArr) {
        _idArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _idArr;
}

- (NSMutableArray *)idArr_second {
    if (!_idArr_second) {
        _idArr_second = [NSMutableArray arrayWithCapacity:0];
    }
    return _idArr_second;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        UIScrollView *sv = [[UIScrollView alloc] init];
        sv.backgroundColor = [UIColor whiteColor];
        sv.frame = CGRectMake(0, NAV_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAV_HEIGHT - TABBAR_HEIGHT);
        sv.showsVerticalScrollIndicator = YES;
        sv.bounces = NO;
        
//        sv.contentInset = UIEdgeInsetsMake(0, 0, 49, 0);
//        sv.scrollIndicatorInsets = sv.contentInset;
        _scrollView = sv;
    }
    
    return _scrollView;
}

#pragma mark - 发布求购
//获取全部供应商一级分类ID
- (void)getSupID {
    [self.view endEditing:YES];
    DDWeakSelf;
    NSString *urlString = [NSString stringWithFormat:URL_GET_SUPID,@"0"];
    [CddHUD show:self.view];
    [ClassTool getRequest:urlString Params:nil Success:^(id json) {
        [CddHUD hideHUD:weakself.view];
        if ([To_String(json[@"code"]) isEqualToString:@"SUCCESS"]) {
            weakself.firstClassify = [PostBuyingModel mj_objectArrayWithKeyValuesArray:json[@"data"]];
            [weakself showPickView_1];
        }
    } Failure:^(NSError *error) {
        NSLog(@" Error : %@",error);
    }];
}

//获取二级分类ID
- (void)getSupID_second {
    [self.view endEditing:YES];
    if (_firstClassify.count == 0 || [_bView.productClassifyOne.textLabel.text isEqualToString:@"请选择分类"]) {
        [CddHUD showTextOnlyDelay:@"请先选择一级分类" view:self.view];
        return ;
    }
    DDWeakSelf;
    [CddHUD show:self.view];
    NSString *urlString = [NSString stringWithFormat:URL_GET_SUPID,[self getFirstID]];
    [ClassTool getRequest:urlString Params:nil Success:^(id json) {
        [CddHUD hideHUD:weakself.view];
        if ([To_String(json[@"code"]) isEqualToString:@"SUCCESS"]) {
            weakself.secondClassify = [PostBuyingModel mj_objectArrayWithKeyValuesArray:json[@"data"]];
            [weakself showPickView_2];
        }
    } Failure:^(NSError *error) {
        NSLog(@" Error : %@",error);
    }];
}

//获取已经选择的一级title的id
- (NSString *)getFirstID {
    if ([_nameArr containsObject:_selectedFirstTitle]) {
        NSInteger index = [_nameArr indexOfObject:_selectedFirstTitle];
        return _idArr[index];
    }
    return nil;
}

#pragma mark - 选择框
//选择一级分类ID
- (void)showPickView_1 {
    [_nameArr removeAllObjects];
    [_idArr removeAllObjects];
    for (PostBuyingModel *model in _firstClassify) {
        [self.nameArr addObject:model.name];
        [self.idArr addObject:model.classID];
    }
    DDWeakSelf;
    [BRStringPickerView showStringPickerWithTitle:@"选择一级分类" dataSource:_nameArr defaultSelValue:nil isAutoSelect:NO themeColor:MainColor resultBlock:^(id selectValue) {
        weakself.selectedFirstTitle = selectValue;
        weakself.bView.productClassifyOne.textLabel.text = selectValue;
    }];
}

//选择级二分类ID
- (void)showPickView_2 {
    [_nameArr_second removeAllObjects];
    [_idArr_second removeAllObjects];
    for (PostBuyingModel *model in _secondClassify) {
        [self.nameArr_second addObject:model.name];
        [self.idArr_second addObject:model.classID];
    }
    DDWeakSelf;
    [BRStringPickerView showStringPickerWithTitle:@"选择二级分类" dataSource:_nameArr_second defaultSelValue:nil isAutoSelect:NO themeColor:MainColor resultBlock:^(id selectValue) {
        weakself.bView.productClassifyTwo.textLabel.text = selectValue;
    }];
}

//单位选择
- (void)showPickView_3 {
    [self.view endEditing:YES];
    NSArray *arr = @[@"桶",@"袋",@"箱"];
    DDWeakSelf;
    [BRStringPickerView showStringPickerWithTitle:@"选择包装规格" dataSource:arr defaultSelValue:nil isAutoSelect:NO themeColor:MainColor resultBlock:^(id selectValue) {
        weakself.bView.unit.textLabel.text = selectValue;
        weakself.bView.unitDisplay.text = selectValue;
        [weakself changeLabel];
    }];
}

//付款方式
- (void)showPickView_4 {
    [self.view endEditing:YES];
    NSArray *arr = @[@"现汇",@"银行承兑"];
    DDWeakSelf;
    [BRStringPickerView showStringPickerWithTitle:@"选择付款方式" dataSource:arr defaultSelValue:nil isAutoSelect:NO themeColor:MainColor resultBlock:^(id selectValue) {
        weakself.bView.payType.textLabel.text = selectValue;
    }];
}

//地址选择
- (void)showPickView_area {
    [self.view endEditing:YES];
    DDWeakSelf;
    [BRAddressPickerView showAddressPickerWithShowType:BRAddressPickerModeCity dataSource:nil defaultSelected:nil isAutoSelect:NO themeColor:MainColor resultBlock:^(BRProvinceModel *province, BRCityModel *city, BRAreaModel *area) {
        weakself.bView.placeArea.textLabel.text = [NSString stringWithFormat:@"%@-%@", province.name, city.name];
    } cancelBlock:^{
//        NSLog(@"点击了背景视图或取消按钮");
    }];
    
}

- (void)showPickView_5 {
    [self.view endEditing:YES];
    NSArray *arr = @[@"款到发货",@"货到付款",@"货到30天付款",@"货到45天付款",@"货到60天付款"];
    DDWeakSelf;
    [BRStringPickerView showStringPickerWithTitle:@"选择结帐期" dataSource:arr defaultSelValue:nil isAutoSelect:NO themeColor:MainColor resultBlock:^(id selectValue) {
        weakself.bView.billDate.textLabel.text = selectValue;
    }];
}

//结束时间
- (void)showPickView_endTime {
    [self.view endEditing:YES];
    DDWeakSelf;
    //开始日期
    NSDate *minDate = [TimeAbout getNDay:3];
    //最大日期
    NSDate *maxDate = [TimeAbout getNDay:30];
    
    //    NSDate *maxDate = [NSDate br_setYear:2030 month:1 day:1];
    [BRDatePickerView showDatePickerWithTitle:@"选择结束时间" dateType:BRDatePickerModeYMD defaultSelValue:[TimeAbout stringFromDate:minDate] minDate:minDate maxDate:maxDate isAutoSelect:NO themeColor:MainColor resultBlock:^(NSString *selectValue) {
        weakself.bView.endTime.textLabel.text = selectValue;
        weakself.endDate = [TimeAbout stringToDate:selectValue];
        //如果交货日期选择了，那就要清空
        if (![weakself.bView.deliveryDate.textLabel.text isEqualToString:@"请选择日期"] || weakself.bView.deliveryDate.textLabel.text.length <= 6) {
            weakself.bView.deliveryDate.textLabel.text = @"请选择日期";
        }
    }];
}

//交货时间
- (void)showPickView_deliveryDate {
    [self.view endEditing:YES];
    if ([_bView.endTime.textLabel.text isEqualToString:@"请选择时间"]) {
        [CddHUD showTextOnlyDelay:@"请先选择结束日期" view:self.view];
        return;
    }
    DDWeakSelf;
    //开始日期
    NSDate *minDate = _endDate;
    //最大日期
    NSDate *maxDate = [NSDate br_setYear:2020 month:1 day:1];
    //    NSDate *maxDate = [NSDate br_setYear:2030 month:1 day:1];
    [BRDatePickerView showDatePickerWithTitle:@"选择结束时间" dateType:BRDatePickerModeYMD defaultSelValue:[TimeAbout stringFromDate:minDate] minDate:minDate maxDate:maxDate isAutoSelect:NO themeColor:MainColor resultBlock:^(NSString *selectValue) {
        weakself.bView.deliveryDate.textLabel.text = selectValue;
    }];
}

- (void)postBuying {
    if ([self judgeRight] == NO) {
        return;
    }
    //公司名称（个人报价时必填），企业用户不需要
    NSString *companyName = [NSString string];
    if (isCompanyUser) {
        companyName = @"";
    } else {
        companyName = _bView.companyNameTF.text;
    }
    
    NSInteger firstID = [self getClassID:_nameArr title:_bView.productClassifyOne.textLabel.text];
    NSInteger secondID = [self getClassID:_nameArr_second title:_bView.productClassifyTwo.textLabel.text];
    NSArray *areaArr = [_bView.placeArea.textLabel.text componentsSeparatedByString:@"-"];
    
    NSString *dDate = [NSString string];
    if (_bView.dateCheckBox.on == YES) {
        dDate = _bView.billTF.text;
    } else {
        dDate = _bView.billDate.textLabel.text;
    }
    
    NSDictionary *dict = @{@"token":User_Token,
                           @"companyName2":companyName,
                           @"productName":_bView.productNameTF.text,
                           @"productCli1":_idArr[firstID],
                           @"productCli2":_idArr_second[secondID],
                           @"endTime":_bView.endTime.textLabel.text,
                           @"pack":[NSString stringWithFormat:@"%@KG/%@",_bView.specificationTF.text,_bView.unit.textLabel.text],
                           @"num":_allWeight,
                           @"numUnit":@"KG",
                           @"locationProvince":areaArr[0],
                           @"locationCity":areaArr[1],
                           @"paymentPeriod":dDate,
                           @"deliveryDate":_bView.deliveryDate.textLabel.text,
                           @"paymentType":_bView.payType.textLabel.text,
                           @"description":_bView.textView.text,
                           @"showInfo":_bView.agreeZTC.on ? @"1" : @"0"
                           };
    
    DDWeakSelf;
    [CddHUD show:self.view];
    [ClassTool postRequest:URL_POST_BUYING Params:[dict mutableCopy] Success:^(id json) {
        [CddHUD hideHUD:weakself.view];
        if ([json[@"code"] isEqualToString:@"SUCCESS"]) {
            BOOL isSuc = [json[@"data"] boolValue];
            if (isSuc == YES) {
                [CddHUD showTextOnlyDelay:@"发布求购成功" view:weakself.view];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakself refresh];
                });
            } else if (isSuc == NO){
                
            }
        }
    } Failure:^(NSError *error) {
        
    }];
    
}

//通知刷新
- (void)refresh {
    if (self.refreshPostBuyBlock) {
        self.refreshPostBuyBlock();
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//获取ID
- (NSInteger)getClassID:(NSMutableArray *)array title:(NSString *)title {
    if ([array containsObject:title]) {
        NSInteger index = [array indexOfObject:title];
        return index;
    }
    return 0;
}


- (void)setupUI {
    AskToBuyBottomView *bView = [[AskToBuyBottomView alloc] init];
    [_scrollView addSubview:bView];
    _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, bView.height);
    _bView = bView;
    
    bView.buyCountTF.delegate = self;
    bView.specificationTF.delegate = self;
    [bView.buyCountTF addTarget:self action:@selector(changeLabel) forControlEvents:UIControlEventEditingChanged];
    [bView.specificationTF addTarget:self action:@selector(changeLabel) forControlEvents:UIControlEventEditingChanged];

    //添加点击事件
    [HelperTool addTapGesture:bView.productClassifyOne withTarget:self andSEL:@selector(getSupID)];
    [HelperTool addTapGesture:bView.productClassifyTwo withTarget:self andSEL:@selector(getSupID_second)];
    [HelperTool addTapGesture:bView.unit withTarget:self andSEL:@selector(showPickView_3)];
    [HelperTool addTapGesture:bView.payType withTarget:self andSEL:@selector(showPickView_4)];
    [HelperTool addTapGesture:bView.billDate withTarget:self andSEL:@selector(showPickView_5)];
    //地区
    [HelperTool addTapGesture:bView.placeArea withTarget:self andSEL:@selector(showPickView_area)];
    //结束时间
    [HelperTool addTapGesture:bView.endTime withTarget:self andSEL:@selector(showPickView_endTime)];
    //交货时间
    [HelperTool addTapGesture:bView.deliveryDate withTarget:self andSEL:@selector(showPickView_deliveryDate)];
    
    UIButton *postBuyingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [postBuyingBtn setTitle:@"发布求购" forState:UIControlStateNormal];
    [postBuyingBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [postBuyingBtn addTarget:self action:@selector(postBuying) forControlEvents:UIControlEventTouchUpInside];
    [ClassTool addLayer:postBuyingBtn];
    [self.view addSubview:postBuyingBtn];
    [postBuyingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-Bottom_Height_Dif);
        make.height.mas_equalTo(49);
    }];

}

- (void)changeLabel {
    
    NSString *allWeight = [NSString string];
    NSString *perCount = [NSString string];
    NSString *unit = [NSString string];
    NSString *num = [NSString string];
    
    if (_bView.specificationTF.text.length == 0) {
        perCount = @"0";
    } else {
        perCount = _bView.specificationTF.text;
    }
    
    //单位
    if ([_bView.unit.textLabel.text isEqualToString:@"请选择"]) {
        unit = @"";
    } else {
        unit = _bView.unit.textLabel.text;
    }
    
    //总量
    if (_bView.buyCountTF.text.length == 0) {
        num = @"";
        allWeight = @"0";
    } else {
        num = _bView.buyCountTF.text;
        NSInteger x = [perCount integerValue] * [_bView.buyCountTF.text integerValue];
        allWeight =  [NSString stringWithFormat:@"%ld",(long)x];
    }
    _bView.explainLabel.text = [NSString stringWithFormat:@"总数量为%@KG(%@KG/%@ * %@%@)",allWeight,perCount,unit,num,unit];
    self.allWeight = allWeight;
}



- (BOOL)judgeRight {
    if (!isCompanyUser && _bView.companyNameTF.text.length == 0) {
        [CddHUD showTextOnlyDelay:@"请填写公司名称" view:self.view];
        return NO;
    } else if ([_bView.productClassifyOne.textLabel.text isEqualToString:@"请选择分类"]) {
        [CddHUD showTextOnlyDelay:@"请选择产品分类" view:self.view];
        return NO;
    } else if ([_bView.productClassifyTwo.textLabel.text isEqualToString:@"产品二级分类"]) {
        [CddHUD showTextOnlyDelay:@"请选择产品二级分类" view:self.view];
        return NO;
    } else if (_bView.productNameTF.text.length == 0) {
        [CddHUD showTextOnlyDelay:@"请填写产品名称" view:self.view];
        return NO;
    } else if (_bView.specificationTF.text.length == 0 || [_bView.unit.textLabel.text isEqualToString:@"请选择"]) {
        [CddHUD showTextOnlyDelay:@"请填写/选择包装规格" view:self.view];
        return NO;
    } else if (_bView.buyCountTF.text.length == 0) {
        [CddHUD showTextOnlyDelay:@"请填写求购数量" view:self.view];
        return NO;
    } else if ([_bView.payType.textLabel.text isEqualToString:@"请选择"]) {
        [CddHUD showTextOnlyDelay:@"请选择付款方式" view:self.view];
        return NO;
    } else if (_bView.dateCheckBox.on == YES && _bView.billTF.text.length == 0) {
        [CddHUD showTextOnlyDelay:@"请输入帐期时间" view:self.view];
        return NO;
    } else if (_bView.dateCheckBox.on == NO && [_bView.billDate.textLabel.text isEqualToString:@"输入帐期时间"]) {
        [CddHUD showTextOnlyDelay:@"请输入帐期时间" view:self.view];
        return NO;
    } else if ([_bView.placeArea.textLabel.text isEqualToString:@"请选择地区"]) {
        [CddHUD showTextOnlyDelay:@"请选择地区" view:self.view];
        return NO;
    } else if ([_bView.endTime.textLabel.text isEqualToString:@"请选择时间"]) {
        [CddHUD showTextOnlyDelay:@"请选择结束日期" view:self.view];
        return NO;
    } else if ([_bView.deliveryDate.textLabel.text isEqualToString:@"请选择日期"] || _bView.deliveryDate.textLabel.text.length <= 6) {
        [CddHUD showTextOnlyDelay:@"请选择交货日期" view:self.view];
        return NO;
    }
    
    return YES;
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}




@end
