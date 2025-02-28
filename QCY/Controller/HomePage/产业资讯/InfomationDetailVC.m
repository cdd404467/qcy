//
//  InfomationDetailVC.m
//  QCY
//
//  Created by i7colors on 2018/11/1.
//  Copyright © 2018年 Shanghai i7colors Ecommerce Co., Ltd. All rights reserved.
//

#import "InfomationDetailVC.h"
#import <WebKit/WebKit.h>
#import "CommonNav.h"
#import "NetWorkingPort.h"
#import "CddHUD.h"
#import "ClassTool.h"
#import "InfomationModel.h"
#import "UIView+Border.h"
#import <WXApi.h>
#import <ShareSDKUI/ShareSDKUI.h>
#import "NavControllerSet.h"
#import "PublishFriendCircleVC.h"


@interface InfomationDetailVC ()

@property (nonatomic, strong)InfomationModel *dataSource;
@property (nonatomic, strong)InfomationModel *model;
@property (nonatomic, strong)WKWebView *webView;
@property (nonatomic, assign)BOOL isFirstLoad;
@property (nonatomic, strong)UIButton *prevBtn;
@property (nonatomic, strong)UIButton *nextBtn;
@property (nonatomic, copy)NSString *prevID;
@property (nonatomic, copy)NSString *nextID;
@end

@implementation InfomationDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _isFirstLoad = YES;
    self.title = @"资讯详情";
    [self setNavBar];
    [self setupUI];
    [self requestData];
    
}

- (void)setupUI {
    //创建webView
    CGRect frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - TABBAR_HEIGHT);
    WKWebView *webView = [[WKWebView alloc] initWithFrame:frame configuration:[self fitWebView]];
    [self.view addSubview:webView];
    _webView = webView;
}

- (void)setNavBar {
    self.title = @"资讯详情";
    [self vhl_setNavBarBackgroundColor:Like_Color];
    [self vhl_setNavBarShadowImageHidden:YES];
    [self vhl_setNavigationSwitchStyle:1];
    [self.backBtn setImage:[UIImage imageNamed:@"close_back"] forState:UIControlStateNormal];
    self.backBtn.left = self.backBtn.left + 2;
    if([WXApi isWXAppInstalled]){//判断用户是否已安装微信App
        [self addRightBarButtonItemWithTitle:@"分享" action:@selector(share)];
    }
}

- (void)share{
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:0];
    [imageArray addObject:Logo];
    NSString *shareStr = [NSString stringWithFormat:@"http://%@.i7colors.com/groupBuyMobile/openApp/information.html?id=%@",ShareString,_infoID];
    
    NSString *text = [NSString stringWithFormat:@"%@",_model.content_summary];
    
    //添加一个自定义的平台（非必要）
    SSUIPlatformItem *item = [[SSUIPlatformItem alloc] init];
    item.iconNormal = [UIImage imageNamed:@"fc_shareinside"];
    item.platformName = @"站内印染圈";
    [item addTarget:self action:@selector(shareInSide)];
    [ClassTool shareSomething:imageArray urlStr:shareStr title:_model.title text:text customItem:@[item,@(SSDKPlatformTypeWechat)]];
}


- (void)shareInSide {
    if (!GET_USER_TOKEN) {
        [self jumpToLogin];
        return;
    }
    PublishFriendCircleVC *vc = [[PublishFriendCircleVC alloc] init];
    vc.shareZinXunModel = _model;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)setBottomBtn {
    //创建底部上一页和下一页
    UIButton *prevBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    prevBtn.frame = CGRectMake(0, SCREEN_HEIGHT - TABBAR_HEIGHT, SCREEN_WIDTH / 2, 49);
    prevBtn.backgroundColor = MainColor;
    prevBtn.tag = 0;
    prevBtn.titleLabel.numberOfLines = 2;
    [prevBtn addTarget:self action:@selector(switchTextContent:) forControlEvents:UIControlEventTouchUpInside];
    [prevBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [prevBtn setTitleColor:RGBA(255, 255, 255, 0.5) forState:UIControlStateDisabled];
    prevBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [prevBtn setTitle:@"无更多文章" forState:UIControlStateDisabled];
    [self.view addSubview:prevBtn];
    _prevBtn = prevBtn;
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.frame = CGRectMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT - TABBAR_HEIGHT, SCREEN_WIDTH / 2, 49);
    nextBtn.backgroundColor = MainColor;
    nextBtn.tag = 1;
    nextBtn.titleLabel.numberOfLines = 2;
    [nextBtn addTarget:self action:@selector(switchTextContent:) forControlEvents:UIControlEventTouchUpInside];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    nextBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [nextBtn setTitleColor:RGBA(255, 255, 255, 0.5) forState:UIControlStateDisabled];
    [nextBtn setTitle:@"无更多文章" forState:UIControlStateDisabled];
    [nextBtn addBorderView:[UIColor whiteColor] width:1.f direction:BorderDirectionLeft];
    [self.view addSubview:nextBtn];
    _nextBtn = nextBtn;
}

//网页适配屏幕
- (WKWebViewConfiguration *)fitWebView {
    NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    
    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    
    WKUserContentController *wkUController = [[WKUserContentController alloc] init];
    
    [wkUController addUserScript:wkUScript];
    
    WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
    
    wkWebConfig.userContentController = wkUController;
    
    return wkWebConfig;
}

- (UIButton *)setBtn:(UIButton *)btn title:(NSString *)title {
    
    NSString *sTitle = [NSString string];
    if (btn.tag == 0) {
        sTitle = [NSString stringWithFormat:@"上一篇\n(%@)",title];
    } else {
        sTitle = [NSString stringWithFormat:@"下一篇\n(%@)",title];
    }
    
    NSMutableAttributedString *mutableTitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",sTitle]];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingMiddle];
    // 行间距设置为4
    [paragraphStyle setLineSpacing:2];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [mutableTitle addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, sTitle.length)];
    [mutableTitle addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0,sTitle.length)];
    [mutableTitle addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0,4)];
    [mutableTitle addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(4,title.length + 2)];
    [btn setAttributedTitle:mutableTitle forState:UIControlStateNormal];
    
    return btn;
}

- (void)requestData {
    DDWeakSelf;
    NSString *urlString = [NSString stringWithFormat:URL_Infomation_Detail,_infoID];
    
    [CddHUD show:self.view];
    [ClassTool getRequest:urlString Params:nil Success:^(id json) {
        [CddHUD hideHUD:weakself.view];
//                NSLog(@"---- %@",json);
        if ([To_String(json[@"code"]) isEqualToString:@"SUCCESS"]) {
            weakself.dataSource = [InfomationModel mj_objectWithKeyValues:json[@"data"]];
            weakself.model = weakself.dataSource.infoDetail;
            if (weakself.isFirstLoad == YES) {
                [weakself setBottomBtn];
            }
            weakself.isFirstLoad = NO;
            [weakself.webView loadHTMLString:weakself.dataSource.infoDetail.content baseURL:nil];
            
            //上一篇还有的话
            if (isRightData(weakself.dataSource.prev.title) && isRightData(weakself.dataSource.prev.infoID)) {
                [weakself setBtn:weakself.prevBtn title:weakself.dataSource.prev.title];
                weakself.prevID = weakself.dataSource.prev.infoID;
                weakself.prevBtn.enabled = YES;
            } else {
                weakself.prevBtn.enabled = NO;
                
            }
            //下一篇还有的话
            if (isRightData(weakself.dataSource.next.title) && isRightData(weakself.dataSource.next.infoID)) {
                weakself.nextID = weakself.dataSource.next.infoID;
                [weakself setBtn:weakself.nextBtn title:weakself.dataSource.next.title];
                weakself.nextBtn.enabled = YES;
            } else {
                weakself.nextBtn.enabled = NO;
            }
        }
    } Failure:^(NSError *error) {
        NSLog(@" Error : %@",error);
    }];
}

- (void)switchTextContent:(UIButton *)sender {
//    NSLog(@"----- %d",sender.isEnabled);
    
    if (sender.tag == 0) {
        _infoID = _prevID;
    } else {
        _infoID = _nextID;
    }
    
    [self requestData];
}

@end
