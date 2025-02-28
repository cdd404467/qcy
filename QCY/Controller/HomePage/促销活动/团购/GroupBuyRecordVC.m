//
//  GroupBuyRecordVC.m
//  QCY
//
//  Created by i7colors on 2018/11/5.
//  Copyright © 2018 Shanghai i7colors Ecommerce Co., Ltd. All rights reserved.
//

#import "GroupBuyRecordVC.h"
#import "ClassTool.h"
#import <YNPageTableView.h>
#import "UIView+Border.h"
#import "NetWorkingPort.h"
#import "GroupBuyingModel.h"
#import "GroupBuyAlreadyCell.h"

@interface GroupBuyRecordVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign)int page;
@property (nonatomic, assign)BOOL isFirstLoad;
@property (nonatomic, strong)NSMutableArray *dataSource;

@end

@implementation GroupBuyRecordVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        _page = 1;
        _isFirstLoad = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshGroupBuyRecord) name:@"groupBuySuc" object:nil];
    [self requestData];
    
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _dataSource;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[YNPageTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
//        _tableView.backgroundColor = [UIColor redColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        if (@available(iOS 11.0, *)) {
            _tableView.estimatedRowHeight = 0;
            _tableView.estimatedSectionHeaderHeight = 0;
            _tableView.estimatedSectionFooterHeight = 0;
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        if ([_type isEqualToString:@"group"]) {
            if (![_layoutStr isEqualToString:@"10"] && ![_layoutStr isEqualToString:@"11"]) {
                _tableView.contentInset = UIEdgeInsetsMake(0, 0, Bottom_Height_Dif, 0);
                _tableView.scrollIndicatorInsets = _tableView.contentInset;
            }
        }
        
        
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

#pragma mark - 网络请求
- (void)requestData {
    
    NSString *urlString = [NSString string];
    if ([_type isEqualToString:@"group"]) {
        urlString = [NSString stringWithFormat:URL_GroupBuy_Already,_groupID,_page,Page_Count];
    } else if ([_type isEqualToString:@"sales"]) {
        urlString = [NSString stringWithFormat:URL_Discount_sales_Already,_groupID,_page,Page_Count];
    }
    
//    [CddHUD show];
    DDWeakSelf;
    [ClassTool getRequest:urlString Params:nil Success:^(id json) {
//        NSLog(@"---- %@",json);
        if ([To_String(json[@"code"]) isEqualToString:@"SUCCESS"]) {
            weakself.dataSource = [GroupBuyFinishModel mj_objectArrayWithKeyValuesArray:json[@"data"]];
            if (weakself.isFirstLoad == YES) {
                [weakself.view addSubview:weakself.tableView];
                weakself.isFirstLoad = NO;
            } else {
                [weakself.tableView reloadData];
            }
        }
        [weakself.tableView reloadData];
    } Failure:^(NSError *error) {
        NSLog(@" Error : %@",error);
    }];
    
}


#pragma mark - UITableView代理
//section header高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 80;
}

//section footer高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.00001;
}

//分区数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

//cell个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _dataSource.count;
}

//自定义的section header
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 80)];
    header.backgroundColor = Cell_BGColor;
    
    UILabel *headerName = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, SCREEN_WIDTH, 40)];
    NSString *text = [NSString string];
    if ([_type isEqualToString:@"group"]) {
        text = @"参与团购记录详情";
    } else if ([_type isEqualToString:@"sales"]) {
        text = @"参与购买记录详情";
    }
    headerName.text = text;
    headerName.textAlignment = NSTextAlignmentCenter;
    headerName.textColor = HEXColor(@"#818181", 1);
    headerName.font = [UIFont systemFontOfSize:14];
    headerName.backgroundColor = [UIColor whiteColor];
    [header addSubview:headerName];
    
    
    UIView *navBg = [[UIView alloc] initWithFrame:CGRectMake(0, 50, SCREEN_WIDTH, 30)];
    navBg.backgroundColor = HEXColor(@"#F7F7F7", 1);
    [header addSubview:navBg];
    [navBg addBorderView:LineColor width:1.f direction:BorderDirectionTop];
    
    CGFloat leftGap = KFit_W(15);
    CGFloat centerGap = KFit_W(5);
    CGFloat width1 = KFit_W(50);
    CGFloat width2 = (SCREEN_WIDTH - leftGap * 2 - centerGap * 3 - width1 * 2) / 2;
    
//    NSArray *titleArr = @[@"序号",@"公司名称",@"联系方式",@"认领量"];
    for (NSInteger i = 0; i < 4; i++) {
        UILabel *title = [[UILabel alloc] init];
        title.textAlignment = NSTextAlignmentCenter;
        title.textColor = HEXColor(@"#818181", 1);
        title.text = _titleArray[i];
        title.font = [UIFont systemFontOfSize:13];
        [navBg addSubview:title];
        
        if (i == 0) {
            title.frame = CGRectMake(leftGap, 0, width1, 30);
        } else if (i == 1) {
            title.frame = CGRectMake(leftGap + width1 + centerGap, 0, width2, 30);
        } else if (i == 2) {
            title.frame = CGRectMake(leftGap + width1 + width2 + centerGap * 2, 0, width2, 30);
        } else {
            title.frame = CGRectMake(leftGap + width1 + width2 * 2 + centerGap * 3, 0, width1, 30);
        }
    }
    
    return header;
}
//cell高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 40;
}

//数据源
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupBuyAlreadyCell *cell = [GroupBuyAlreadyCell cellWithTableView:tableView];
    cell.model = _dataSource[indexPath.row];
    
    return cell;
    
}

- (void)refreshGroupBuyRecord {
    
    [self requestData];
}

- (void)dealloc {
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
