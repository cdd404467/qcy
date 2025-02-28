//
//  HomePageSearchVC.m
//  QCY
//
//  Created by i7colors on 2018/11/9.
//  Copyright © 2018 Shanghai i7colors Ecommerce Co., Ltd. All rights reserved.
//

#import "HomePageSearchVC.h"
#import "ClassTool.h"
#import "NetWorkingPort.h"
#import "CddHUD.h"
#import "HomePageSectionHeader.h"
#import "OpenMallVC_Cell.h"
#import "AskToBuyCell.h"
#import "ProductMallVC_Cell.h"
#import "HomePageModel.h"
#import "OpenMallModel.h"
#import "PYSearchConst.h"
#import "PYSearchSuggestionViewController.h"
#import "ProductDetailsVC.h"
#import "AskToBuyDetailsVC.h"
#import "ShopMainPageVC.h"
#import "ProductMallVC.h"
#import "AskToBuyVC.h"
#import "OpenMallVC.h"
#import "NoDataView.h"
#import <UIScrollView+EmptyDataSet.h>
#import "SearchResultPageVC.h"
#import "UITextField+Limit.h"


@interface HomePageSearchVC ()<UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate,DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, assign)int page;
@property (nonatomic, strong)HomePageModel *dataSource;
@property (nonatomic, weak) UISearchBar *searchBar;
@property (nonatomic, assign)BOOL isFirstLoad;
@end

@implementation HomePageSearchVC

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
    
    [self keyWordSearch];
    [self setupUI];
}


- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.emptyDataSetSource = self;
        _tableView.emptyDataSetDelegate = self;
        _tableView.backgroundColor = Cell_BGColor;
        if (@available(iOS 11.0, *)) {
            //            _tableView.estimatedRowHeight = 0;
            _tableView.estimatedSectionHeaderHeight = 0;
            _tableView.estimatedSectionFooterHeight = 0;
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } 
        _tableView.contentInset = UIEdgeInsetsMake(NAV_HEIGHT, 0, 0, 0);
        _tableView.scrollIndicatorInsets = _tableView.contentInset;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, TABBAR_HEIGHT)];
        _tableView.tableFooterView = footer;
    }
    return _tableView;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)setupUI {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 50, 44);
    [btn setTitle:@"取消" forState:UIControlStateNormal];
//    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, -5)];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [btn sizeToFit];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
    
    [btn addTarget:self action:@selector(cancelDidClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    // 创建搜索框
    UIView *titleView = [[UIView alloc] init];
    titleView.py_x = PYMargin * 0.5;
    titleView.py_y = 7;
    titleView.py_width = self.view.py_width - 64 - titleView.py_x * 2;
    
    titleView.py_height = 30;
//    titleView.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1];
    titleView.backgroundColor = UIColor.whiteColor;
    titleView.layer.cornerRadius = 13;
    titleView.clipsToBounds = YES;
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:titleView.bounds];
    searchBar.py_width -= PYMargin * 1.5;
    searchBar.placeholder = @"输入关键词搜索";
    searchBar.text = _searchKeyWord;
    //    searchBar.placeholder = PYSearchPlaceholderText;
    //iOS 10 searchBarBackground
    searchBar.backgroundImage = [UIImage imageNamed:@"PYSearch.bundle/clearImage"];
    searchBar.delegate = self;
    //    searchBar.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1];
    //去掉searchBar的背景色
    //    for (UIView *view in searchBar.subviews) {
    //        if ([view isKindOfClass:NSClassFromString(@"UIView")] && view.subviews.count > 0) {
    //            [[view.subviews objectAtIndex:0] removeFromSuperview];
    //            break;
    //        }
    //    }
    
    
    UITextField * searchTextField = [[[searchBar.subviews firstObject] subviews] lastObject];
    if (@available(iOS 13.0, *)) {
        searchTextField = searchBar.searchTextField;
    }
    
    [searchTextField setClearButtonMode:UITextFieldViewModeNever];
    [searchTextField addTarget:self action:@selector(textFieldChange:) forControlEvents:UIControlEventEditingChanged];
    searchTextField.tintColor = UIColor.blackColor;
    //限制字数
    [searchTextField lengthLimit:^{
        if (searchTextField.text.length > 20) {
            searchTextField.text = [searchTextField.text substringToIndex:20];
        }
    }];
//    [searchTextField setBackgroundColor:[UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1]];
    [searchTextField setBackgroundColor:UIColor.whiteColor];
    [titleView addSubview:searchBar];
    self.searchBar = searchBar;
    self.navigationItem.titleView = titleView;
}

//监听键盘输入
-(void)textFieldChange:(UITextField *)textField{
    if (textField.markedTextRange == nil) {
        if (textField.text.length == 0) {
            //            [self.navigationController popViewControllerAnimated:NO];
        }
    }
}

//searchBar 键盘搜索按钮的点击事件
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
    _searchKeyWord = _searchBar.text;
    [self keyWordSearch];
}

/** 点击取消 */
- (void)cancelDidClick
{
    [self.searchBar resignFirstResponder];
    //    [self.navigationController popToRootViewControllerAnimated:NO];
    //    [self dismissViewControllerAnimated:NO completion:nil];
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
    
}

#pragma mark - 搜索
- (void)keyWordSearch {

    NSString *urlString = [NSString stringWithFormat:URL_HomePage_search,User_Token,_searchKeyWord,_page,Page_Count];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [CddHUD show:self.view];
    DDWeakSelf;
    [ClassTool getRequest:urlString Params:nil Success:^(id json) {
        [CddHUD hideHUD:weakself.view];
        if ([To_String(json[@"code"]) isEqualToString:@"SUCCESS"]) {
            weakself.dataSource = [HomePageModel mj_objectWithKeyValues:json[@"data"]];
            
            if (weakself.dataSource.productList.count > 0) {
                weakself.dataSource.productList = [ProductInfoModel mj_objectArrayWithKeyValuesArray:weakself.dataSource.productList];
            }
            if (weakself.dataSource.enquiryList.count > 0) {
                weakself.dataSource.enquiryList = [AskToBuyModel mj_objectArrayWithKeyValuesArray:weakself.dataSource.enquiryList];
            }
            if (weakself.dataSource.marketList.count > 0) {
                weakself.dataSource.marketList = [OpenMallModel mj_objectArrayWithKeyValuesArray:weakself.dataSource.marketList];
                for (OpenMallModel *model in weakself.dataSource.marketList) {
                    model.businessList = [BusinessList mj_objectArrayWithKeyValuesArray:model.businessList];
                }
            }
            
            if (weakself.isFirstLoad == YES) {
                [weakself.view addSubview:weakself.tableView];
                weakself.isFirstLoad = NO;
            } else {
                [weakself.tableView reloadData];
            }
        }
        
    } Failure:^(NSError *error) {
        
    }];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *title = @"没有搜索结果，请换个关键词";
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont boldSystemFontOfSize:16.0f],
                                 NSForegroundColorAttributeName:HEXColor(@"#708090", 1)
                                 };
    return [[NSAttributedString alloc] initWithString:title attributes:attributes];
}

#pragma mark - UITableView代理
//section header高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        if (_dataSource.productList.count > 0) {
            return 36;
        } else {
            return 0.001;
        }
    } else if (section == 1) {
        if (_dataSource.enquiryList.count > 0) {
            return 36;
        } else {
            return 0.001;
        }
    } else {
        if (_dataSource.marketList.count > 0) {
            return 36;
        } else {
            return 0.001;
        }
    }
    
}

//section footer高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        if (_dataSource.productList.count > 0)
            return 6;
        return 0.00001;
    } else {
        return 0.00001;
    }
}

//分区数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}

//自定义的section header
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSArray *titleArr = @[@"产品大厅",@"求购大厅",@"开放商城"];
    HomePageSectionHeader *header = [ HomePageSectionHeader headerWithTableView:tableView];
    header.titleLabel.text = titleArr[section];
    SearchResultPageVC *vc = [[SearchResultPageVC alloc] init];
    vc.keyWord = _searchKeyWord;
    DDWeakSelf;
    if (section == 0) {
        if (_dataSource.productList.count > 0) {
            header.clickMoreBlock = ^{
                vc.type = @"product";
                [weakself.navigationController pushViewController:vc animated:YES];
            };
            return header;
        } else {
            return nil;
        }
    } else if (section == 1) {
        if (_dataSource.enquiryList.count > 0) {
            header.clickMoreBlock = ^{
                vc.type = @"askBuy";
                [weakself.navigationController pushViewController:vc animated:YES];
            };
            return header;
        } else {
            return nil;
        }
    } else {
        if (_dataSource.marketList.count > 0) {
            header.clickMoreBlock = ^{
                vc.type = @"openMall";
                [weakself.navigationController pushViewController:vc animated:YES];
            };
            return header;
        } else {
            return nil;
        }
    }
}

//cell个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if (_dataSource.productList.count < 4) {
            return _dataSource.productList.count;
        } else {
            return 3;
        }
    } else if (section == 1) {
        if (_dataSource.enquiryList.count < 4) {
            return _dataSource.enquiryList.count;
        } else {
            return 3;
        }
    } else {
        if (_dataSource.marketList.count < 4) {
            return _dataSource.marketList.count;
        } else {
            return 3;
        }
    }
}

//cell高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (_dataSource.productList.count > 0) {
            return 126;
        } else {
            return 0;
        }
    } else if (indexPath.section == 1) {
        if (_dataSource.enquiryList.count > 0) {
            return 126;
        } else {
            return 0;
        }
    } else {
        if (_dataSource.marketList.count > 0) {
            return 126;
        } else {
            return 0;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        ProductDetailsVC *vc = [[ProductDetailsVC alloc] init];
        ProductInfoModel *model = _dataSource.productList[indexPath.row];
        vc.productID = model.productID;
        [self.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.section == 1) {
        AskToBuyDetailsVC *vc = [[AskToBuyDetailsVC alloc] init];
        AskToBuyModel *model = _dataSource.enquiryList[indexPath.row];
        vc.buyID = model.buyID;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        ShopMainPageVC *vc = [[ShopMainPageVC alloc] init];
        OpenMallModel *model = _dataSource.marketList[indexPath.row];
        vc.storeID = model.storeID;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

//数据源
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        ProductMallVC_Cell *cell = [ProductMallVC_Cell cellWithTableView:tableView];
        cell.model = _dataSource.productList[indexPath.row];
        return cell;
    } else if (indexPath.section == 1) {
        AskToBuyCell *cell = [AskToBuyCell cellWithTableView:tableView];
        cell.model = _dataSource.enquiryList[indexPath.row];
        return cell;
    } else {
        OpenMallVC_Cell *cell = [OpenMallVC_Cell cellWithTableView:tableView];
        cell.model = _dataSource.marketList[indexPath.row];
        return cell;
    }
    
}


@end
