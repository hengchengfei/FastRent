//
//  HouseDetailViewController.m
//  FastRent
//
//  Created by heng chengfei on 14-3-24.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import "DetailViewController.h"
#import "Rent.h"
#import "DetailImagesViewCell.h"
#import "DetailTitleViewCell.h"
#import "DetailPriceViewCell.h"
#import "DetailContentViewCell.h"
#import "DetailMapViewCell.h"
#import "Image.h"
#import "WebRequest.h"
#import "UIImageView+WebCache.h"
#import "FavoriteViewController.h"
#import "MapViewController.h"
#import "DXAlertView.h"
#import "VerticallyAlignedLabel.h"
#import "MBProgressHUD.h"
#import "WxSdk/WXApi.h"
#import "WxSdk/WXApiObject.h"
#import "MobClick.h"

@interface DetailViewController ()
{
    Rent *_rent;
    //LocationViewController *_locationViewController;
    
    MKPointAnnotation* pointAnnotation;
    
    CGFloat _latitude;
    CGFloat _longitude;
    NSString *_address;
    
    
    NSMutableDictionary *_heightDictionary;
    
    UIToolbar *toolbar;
    
    enum WXScene _wxscene;
}
@end

@implementation DetailViewController

@synthesize tableView=_tableView,id=_id,fromViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    [self setTitle:@"详情"];
    [self setNavLeftButton];
    
    //    NSArray *fNames=[UIFont familyNames];
    //    for (NSString *name in fNames) {
    //        printf("Family:%s\n",[name UTF8String]);
    //        NSArray *fn =[UIFont fontNamesForFamilyName:name];
    //        for (NSString *fontname in fn) {
    //            printf("\tFont:%s\n",[fontname UTF8String]);
    //        }
    //    }
    
    
    //添加收藏按钮
    [self addFavorite];
    
    
    //View样式设置
    [self initStyle];
    
    //加载数据
    [self loadData];
    
    
    //QQ
    [self initTencent];
    
}

#pragma mark View样式设置
-(void)initStyle{
    //控件开始位置和相关设置
    if (ISOS7) {
        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars=NO;
        self.modalPresentationCapturesStatusBarAppearance=NO;
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
    
    //先隐藏
    self.tableView.hidden=YES;
    self.tableView.tableFooterView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 20)];
    if (ISOS7) {
        self.tableView.separatorInset=UIEdgeInsetsMake(0, 0, 0, 0);//使得cell下面的分割线靠最左边(IOS7以上的属性)
    }
    
}


#pragma mark -
#pragma mark color转换为image
-(UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect=CGRectMake(0, 0, 1.0, 1.0);
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(void)initTencent{
    _tencentOAuth = [[TencentOAuth alloc] initWithAppId:__TencentAppId__
 								        	andDelegate:self];
    _permissions = [NSArray arrayWithObjects:
                    kOPEN_PERMISSION_GET_USER_INFO,
                    kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                    kOPEN_PERMISSION_ADD_ALBUM,
                    kOPEN_PERMISSION_ADD_IDOL,
                    kOPEN_PERMISSION_ADD_ONE_BLOG,
                    kOPEN_PERMISSION_ADD_PIC_T,
                    kOPEN_PERMISSION_ADD_SHARE,
                    kOPEN_PERMISSION_ADD_TOPIC,
                    kOPEN_PERMISSION_CHECK_PAGE_FANS,
                    kOPEN_PERMISSION_DEL_IDOL,
                    kOPEN_PERMISSION_DEL_T,
                    kOPEN_PERMISSION_GET_FANSLIST,
                    kOPEN_PERMISSION_GET_IDOLLIST,
                    kOPEN_PERMISSION_GET_INFO,
                    kOPEN_PERMISSION_GET_OTHER_INFO,
                    kOPEN_PERMISSION_GET_REPOST_LIST,
                    kOPEN_PERMISSION_LIST_ALBUM,
                    kOPEN_PERMISSION_UPLOAD_PIC,
                    kOPEN_PERMISSION_GET_VIP_INFO,
                    kOPEN_PERMISSION_GET_VIP_RICH_INFO,
                    kOPEN_PERMISSION_GET_INTIMATE_FRIENDS_WEIBO,
                    kOPEN_PERMISSION_MATCH_NICK_TIPS_WEIBO,
                    nil];
}
#pragma mark 底部工具栏
-(void)addBottomToolbar
{
    //工具栏
    CGRect rect=CGRectMake(0,self.view.frame.size.height-44, self.view.frame.size.width, 44.0 );
    
    toolbar=[[UIToolbar alloc]initWithFrame:rect];
    [toolbar setBarStyle:UIBarStyleDefault];
    [toolbar setTranslucent:YES];
    toolbar.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    [toolbar setBackgroundImage:[UIImage imageNamed:@"TABBackground.png"] forToolbarPosition:0 barMetrics:0];
    
    UIFont *systemFont =[UIFont systemFontOfSize:13];
    //联系人
    NSString *contacter;
    if (_rent.contacterName==nil) {
        contacter=@"联系人";
    }else{
        contacter=_rent.contacterName;
    }
    CGSize contacterSize = MB_TEXTSIZE(contacter, systemFont);
    UILabel *contacterLabel=[[UILabel alloc]init];
    contacterLabel.frame=CGRectMake(0, 5, contacterSize.width, contacterSize.height);
    contacterLabel.font=systemFont;
    contacterLabel.textAlignment=NSTextAlignmentLeft;
    [contacterLabel setText:contacter];
    contacterLabel.backgroundColor=[UIColor clearColor];
    contacterLabel.textColor=[UIColor blackColor];
    
    //联系人电话
    NSString *tel=_rent.contacterPhoneDisplay;
    CGSize telSize = MB_TEXTSIZE(tel, [UIFont systemFontOfSize:12]);
    UILabel *telLabel=[[UILabel alloc]init];
    telLabel.frame=CGRectMake(0, contacterSize.height+10, telSize.width, telSize.height);
    telLabel.font=[UIFont systemFontOfSize:11];
    telLabel.textAlignment=NSTextAlignmentLeft;
    [telLabel setText:tel];
    telLabel.backgroundColor=[UIColor clearColor];
    telLabel.textColor=[UIColor blackColor];
    
    UIView *view =[[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    [view addSubview:contacterLabel];
    [view addSubview:telLabel];
    
    UIBarButtonItem *leftItem=[[UIBarButtonItem alloc]initWithCustomView:view];
    
    //空格
    UIBarButtonItem *spaceItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width=100;
    
    //电话
    UIImage *image=[UIImage imageNamed:@"TOOLTel.png"];
    UIImageView *telImageView=[[UIImageView alloc]initWithImage:image];
    telImageView.frame=CGRectMake(0,0, image.size.width,image.size.height);
    //telImageView.contentMode=UIViewContentModeScaleAspectFit;
    
    UILabel *telPhoneDesc=[[UILabel alloc]init];
    telPhoneDesc.frame=CGRectMake(0, 25, 50, 19);
    telPhoneDesc.font=[UIFont systemFontOfSize:11];
    telPhoneDesc.textAlignment=NSTextAlignmentLeft;
    [telPhoneDesc setText:@"电话"];
    telPhoneDesc.backgroundColor=[UIColor clearColor];
    telPhoneDesc.textColor=[UIColor blackColor];
    
    UIView *viewPhone =[[UIView alloc]initWithFrame:CGRectMake(0, 0, image.size.width,image.size.height)];
    [viewPhone addSubview:telImageView];
    //[viewPhone addSubview:telPhoneDesc];
    
    //加入手势，item无action方法
    UITapGestureRecognizer *telGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openTelphone:)];
    viewPhone.userInteractionEnabled=YES;
    [viewPhone addGestureRecognizer:telGesture];
    
    UIBarButtonItem *telPhoneItem=[[UIBarButtonItem alloc]initWithCustomView:viewPhone];
    
    
    //短信
    UIImage *imageTxt=[UIImage imageNamed:@"TOOLMessage.png"];
    UIImageView *textImageView=[[UIImageView alloc]initWithImage:imageTxt];
    textImageView.frame=CGRectMake(0,0, imageTxt.size.width, imageTxt.size.height);
    textImageView.contentMode=UIViewContentModeCenter;
    UILabel *textMsgDesc=[[UILabel alloc]init];
    textMsgDesc.frame=CGRectMake(0,25, 50, 19);
    textMsgDesc.font=[UIFont systemFontOfSize:11];
    textMsgDesc.textAlignment=NSTextAlignmentLeft;
    [textMsgDesc setText:@"短信"];
    textMsgDesc.backgroundColor=[UIColor clearColor];
    textMsgDesc.textColor=[UIColor blackColor];
    
    UIView *viewText =[[UIView alloc]initWithFrame:CGRectMake(55, 0, imageTxt.size.width, imageTxt.size.height)];
    [viewText addSubview:textImageView];
    //[viewText addSubview:textMsgDesc];
    //加入手势，item无action方法
    UITapGestureRecognizer *textGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openTextMsg:)];
    viewText.userInteractionEnabled=YES;
    [viewText addGestureRecognizer:textGesture];
    
    UIBarButtonItem *textMsgItem=[[UIBarButtonItem alloc]initWithCustomView:viewText];
    
    //UIBarButtonItem *textMsgItem =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:nil action:nil];
    
    NSArray *array=[NSArray arrayWithObjects:leftItem,spaceItem,telPhoneItem,textMsgItem, nil];
    
    //[self setToolbarItems:array animated:YES];
    //[self.navigationController setToolbarHidden:NO animated:YES];
    [toolbar setItems:array animated:YES];
    [self.view addSubview:toolbar];
    
}

#pragma mark 拨打电话
-(void)openTelphone:(id)sender
{
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",_rent.contacterPhone]];
    BOOL isSuccess = [[UIApplication sharedApplication]openURL:url];
    if (!isSuccess) {
        DXAlertView *alert=[[DXAlertView alloc]initWithTitle:@"提示" contentText:@"该设备不支持电话功能" leftButtonTitle:nil rightButtonTitle:@"确定"];
        [alert show];
    }
}

-(void)openTextMsg:(id)sender
{
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"sms://%@",_rent.contacterPhone]];
    BOOL isSuccess=  [[UIApplication sharedApplication]openURL:url];
    if (!isSuccess) {
        DXAlertView *alert=[[DXAlertView alloc]initWithTitle:@"提示" contentText:@"该设备不支持短信功能" leftButtonTitle:nil rightButtonTitle:@"确定"];
        [alert show];
    }
}

#pragma mark 加载数据
-(void)loadData{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    BOOL isConnected =[WebRequest isConnectionAvailable];
    if (!isConnected) {
        [self warnMessage:@"网络连接失败"];
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        return;
    }
    
    MBProgressHUD *hudLoading=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hudLoading.labelText=@"加载中";
    [hudLoading show:YES];
    
    __block    BOOL isSuccess;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0) ,^{
        [WebRequest findRent:self.id onCompletion:^(Rent *rent, NSError *error) {
            if (error!=nil) {
                isSuccess=NO;
            }else{
                isSuccess=YES;
                _rent=rent;
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
            [hudLoading hide:YES];
            if (!isSuccess) {
                [self warnMessage:@"加载失败"];
                self.tableView.hidden=YES;
                return;
            }
            self.tableView.hidden=NO;
            
            self.tableView.dataSource=self;
            self.tableView.delegate=self;
            
            [self setHeightForCell];
            
            [self addBottomToolbar];
            [self.tableView reloadData];
        });
    });
}

-(void)warnMessage:(NSString *)msg
{
    MBProgressHUD *hd =[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hd.mode=MBProgressHUDModeText;
    hd.labelText=msg;
    [hd show:YES];
    
    [hd hide:YES afterDelay:2.0];
}

-(void)setHeightForCell
{
    _heightDictionary=[[NSMutableDictionary alloc]init];
    
    /*图像cell*/
    if (_rent.rentImages.count<=0) {
        [_heightDictionary setValue:[NSNumber numberWithFloat:0.0f] forKey:@"ImageCell"];
    }else{
        [_heightDictionary setValue:[NSNumber numberWithFloat:190.0f] forKey:@"ImageCell"];
    }
    
    /*标题cell*/
    NSString *title =[_rent publishTitle];
    
    //设置字体,包括字体及其大小
    UIFont *fontTitle=[UIFont fontWithName:@"FZHei-B01S" size:16];
    
    //label可设置的最大高度和宽度
    CGSize maxSize=CGSizeMake(300.0f, MAXFLOAT);
    
    //字符串在指定区域内按照指定的字体显示时,需要的高度和宽度(宽度在字符串只有一行时有用)
    //一般用法:指定区域的宽度而高度用MAXFLOAT,则返回值包含对应的高度
    //如果指定区域的宽度指定,而字符串要显示的区域的高度超过了指定区域的高度,则高度返回0
    //核心:多行显示,指定宽度,获取高度
    CGSize sizeTitle = MB_MULTILINE_TEXTSIZE(title, fontTitle, maxSize, NSLineBreakByWordWrapping);
    [_heightDictionary setValue:[NSNumber numberWithDouble:sizeTitle.height+40.0] forKey:@"TitleCell"];
    
    /*价格cell*/
    [_heightDictionary setValue:[NSNumber numberWithFloat:114.0f] forKey:@"PriceCell"];
    
    /*地图Cell*/
    [_heightDictionary setValue:[NSNumber numberWithFloat:228.0f] forKey:@"MapCell"];
    
    /*正文cell*/
    UIFont *fontContent=[UIFont systemFontOfSize:13.0];
    NSString *content=_rent.publishContent;
    CGSize sizeContent=MB_MULTILINE_TEXTSIZE(content, fontContent, maxSize, NSLineBreakByWordWrapping);
    [_heightDictionary setValue:[NSNumber numberWithDouble:sizeContent.height+44] forKey:@"ContentCell"];
}

-(void)addFavorite
{
    NSUserDefaults *defaluts =[NSUserDefaults standardUserDefaults];
    NSArray *array =[defaluts arrayForKey:FavoriteIdKey];
    BOOL isExisted = NO;
    for (NSNumber *value in array) {
        if (value!=nil && self.id.intValue == value.intValue) {
            isExisted=YES;
            break;
        }
    }
    UIButton *button=[[UIButton alloc]init];
    
    
    if (isExisted) {
        UIImage *back=[UIImage imageNamed:kPNG_Favorited];
        [button setBackgroundImage:back forState:UIControlStateNormal];
        button.frame = CGRectMake(0, 0, 23, 23);
    }else{
        
        UIImage *back=[UIImage imageNamed:kPNG_Favorite];
        [button setBackgroundImage:back forState:UIControlStateNormal];
        button.frame = CGRectMake(0, 0, 23, 23);
    }
    [button addTarget:self action:@selector(favoriteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item=[[UIBarButtonItem alloc]initWithCustomView:button];
    
    //分享
    UIButton *shareButton =[[UIButton alloc]init];
    UIImage *shareImage=[UIImage imageNamed:kPNG_Share];
    [shareButton setBackgroundImage:shareImage forState:UIControlStateNormal];
    shareButton.frame=CGRectMake(0, 0, shareImage.size.width,shareImage.size.height);
    [shareButton addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item1=[[UIBarButtonItem alloc]initWithCustomView:shareButton];
    
    NSArray *arrItems =[NSArray arrayWithObjects:item,item1, nil];
    self.navigationItem.rightBarButtonItems=arrItems;
    
}

#pragma mark LXActivityDelegate
-(void)share:(id)sender
{
    NSArray *shareButtonTitleArray = [NSArray arrayWithObjects:@"微信朋友圈",@"微信好友",@"QQ好友",@"新浪微博",@"QQ空间", nil];
    NSArray *shareButtonImageNameArray = [NSArray arrayWithObjects:@"sns_icon_21",@"sns_icon_22",@"sns_icon_24",@"sns_icon_25",@"sns_icon_23", nil];
    
    
    LXActivity *lxActivity = [[LXActivity alloc] initWithTitle:@"分享到" delegate:self cancelButtonTitle:@"取消" ShareButtonTitles:shareButtonTitleArray withShareButtonImagesName:shareButtonImageNameArray];
    
    
    [lxActivity showInView:self.view];
}

-(void)didClickOnImageIndex:(NSInteger *)imageIndex
{
    int index=(int)imageIndex;
    
    NSString *app;
    switch (index) {
        case 0:
            app=@"微信朋友圈";
            _wxscene=WXSceneTimeline;
            [self shareWx];
            break;
        case 1:
            app=@"微信好友";
            _wxscene=WXSceneSession;
            [self shareWx];
            break;
        case 2:
            app=@"QQ好友";
            [self shareQQ];
            break;
        case 3:
            app=@"微博";
            [self shareWeibo];
            break;
        case 4:
            app=@"QQ空间";
            [self shareQzone];
            break;
        default:
            break;
    }
    
    //记录事件
    NSDictionary *dict = @{@"app":app};
    [MobClick event:@"ShareEvent" attributes:dict];
}

#pragma mark share
- (void) shareWx
{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = _rent.publishTitle;
    message.description = _rent.publishContent;
    [message setThumbImage:[UIImage imageNamed:@"AppIcon57x57.png"]];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = _rent.infoUrl;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = _wxscene;
    
    [WXApi sendReq:req];
}

-(void)shareQQ
{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"AppIcon57x57@2x" ofType:@"png"];
    NSData *data=[NSData dataWithContentsOfFile:path];
    
    NSString *houseImage=_rent.houseImg;
    if (houseImage) {
        data=[NSData dataWithContentsOfURL:[NSURL URLWithString:houseImage]];
    }
    NSURL* url = [NSURL URLWithString:_rent.infoUrl];
    
    QQApiNewsObject* img = [QQApiNewsObject objectWithURL:url
                                                    title:_rent.publishTitle
                                              description:_rent.publishContent
                                         previewImageData:data];
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:img];
    
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];
    
}

- (void)shareQzone
{
    NSString *imageurl = _rent.houseImg;
    NSString *shareText = _rent.publishContent;
    NSString *shareTitle = _rent.publishTitle;
    NSString *shareurl = _rent.infoUrl;

    QQApiNewsObject *_qqApiObject = [QQApiNewsObject objectWithURL:[NSURL URLWithString:shareurl ? : @""]
                                                        title:shareTitle ? : @""
                                                  description:shareText ? : @""
                                              previewImageURL:[NSURL URLWithString:imageurl ? : @""]];

    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:_qqApiObject];
    QQApiSendResultCode sent =   [QQApiInterface SendReqToQZone:req];
    [self handleSendResult:sent];
}

-(void)shareWeibo
{
    WBMessageObject *message = [WBMessageObject message];
    message.text = @"我在闪租上找了一个好房子哦";
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"AppIcon57x57@2x" ofType:@"png"];
    NSData *data=[NSData dataWithContentsOfFile:path];
    
    NSString *houseImage=_rent.houseImg;
    if (houseImage) {
        data=[NSData dataWithContentsOfURL:[NSURL URLWithString:houseImage]];
    }
    
    WBWebpageObject *webpage = [WBWebpageObject object];
    webpage.objectID = _rent.publishTitle;
    webpage.title = _rent.publishTitle;
    webpage.description = _rent.publishContent;
    webpage.thumbnailData = data;
    webpage.webpageUrl = _rent.infoUrl;
    message.mediaObject = webpage;
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
    request.userInfo = @{@"ShareMessageFrom": @"SendMessageToWeiboViewController",
                         @"Other_Info_1": [NSNumber numberWithInt:123],
                         @"Other_Info_2": @[@"obj1", @"obj2"],
                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    //    request.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
    [WeiboSDK sendRequest:request];
}

-(void)isOnlineResponse:(NSDictionary *)response
{
    
}
- (void)showInvalidTokenOrOpenIDMessage{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"api调用失败" message:@"参数有误或者token失效，请检查参数或者重新登录" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)handleSendResult:(QQApiSendResultCode)sendResult
{
    switch (sendResult)
    {
        case EQQAPIAPPNOTREGISTED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"App未注册" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送参数错误" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQQNOTINSTALLED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"未安装手Q" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"API接口不支持" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPISENDFAILD:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQZONENOTSUPPORTTEXT:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"空间分享不支持纯文本分享，请使用图文分享" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQZONENOTSUPPORTIMAGE:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"空间分享不支持纯图片分享，请使用图文分享" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        default:
        {
            break;
        }
    }
}


-(void)tencentDidLogin{
    NSString *msg=@"登录完成";
    if (_tencentOAuth.accessToken && 0 != [_tencentOAuth.accessToken length])
    {
        // 记录登录用户的OpenID、Token以及过期时间
        msg = _tencentOAuth.accessToken;
    }
    else
    {
        msg = @"登录不成功 没有获取accesstoken";
    }
    [self.view makeToast:msg];
    
    //    NSString *_accessToken=[_tencentOAuth accessToken];
    //    NSString *_openId =[_tencentOAuth openId];
    //   NSDate *_expirationDate= [_tencentOAuth expirationDate];
}


#pragma mark - QQApiInterfaceDelegate
- (void)onReq:(QQBaseReq *)req
{
    DLog(@"%s",__FUNCTION__);
}


- (void)onResp:(QQBaseResp *)resp
{
    DLog(@"%s",__FUNCTION__);
    
}

-(void)tencentDidNotLogin:(BOOL)cancelled
{
    NSString *msg=@"";
    if (cancelled) {
        msg=@"用户取消登录";
        
    }else{
        msg=@"登录失败";
    }
    [self.view makeToast:msg];
}

-(void)tencentDidNotNetWork
{
    [self.view makeToast:@"无网络连接，请设置网络"];
}
#pragma mark 设置导航颜色
-(void)setTitle:(NSString *)title
{
    UIFont *font = [UIFont systemFontOfSize:kNav_TitleSize];
    
    CGSize titleSize=MB_TEXTSIZE(title, font);
    
    UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 10, titleSize.width, 44)];
    titleLabel.backgroundColor=[UIColor clearColor];
    titleLabel.text=title;
    titleLabel.font=font;
    titleLabel.textColor=[UIColor whiteColor];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    
    titleLabel.userInteractionEnabled=YES;
    self.navigationItem.titleView=titleLabel;
    
}

-(void)setNavLeftButton
{
    UIButton *button=[[UIButton alloc]init];
    UIImage *back=[UIImage imageNamed:kPNG_BACK];
    button.frame = CGRectMake(0, 0, back.size.width, back.size.height);
    [button setBackgroundImage:back forState:UIControlStateNormal];
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item=[[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.leftBarButtonItem=item;
    
}
-(void)back
{
    [self.delegate addItemViewController:self disFinishEnteringItem:self.isFavorited];
    //[self.navigationController popViewControllerAnimated:YES];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)favoriteButtonClicked:(id *)sender
{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *array = [userDefaults mutableArrayValueForKey:FavoriteIdKey];//userdefaults取出的数据只能读，不能更新
    BOOL isExisted = NO;
    if (array.count<=0) {
        array =[[NSMutableArray alloc]init];
        [array addObject:self.id];
        [userDefaults setObject:array forKey:FavoriteIdKey];
    }else{
        NSMutableArray *newarray = [NSMutableArray arrayWithArray:array];
        
        for (NSNumber *value in newarray) {
            if (value!=nil && value.intValue == self.id.intValue) {
                isExisted=YES;
                break;
            }
        }
        if (!isExisted) {
            self.isFavorited=YES;
            [newarray addObject:self.id];
        }else{
            self.isFavorited=NO;
            [newarray removeObject:self.id];
        }
        [userDefaults setObject:newarray forKey:FavoriteIdKey];
        
    }
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    [self addFavorite];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *detailImagesViewCell = @"DetailImagesViewCell";
    static NSString *detailTitleViewCell = @"DetailTitleViewCell";
    static NSString *detailPriceCell =@"DetailPriceCell";//注意和前面2个的区别，这里是属性设置中的identifier，这样下面的cell就不会为nil，直接读取的storyboard中设置的cell了。切记，一定要让tableview的Content为动态才有效
    static NSString *mapCell =@"DetailMapCell";
    static NSString *contentCell =@"DetailContentCell";
    
    
    //    //最后一行时，因为有toolbar，所以高度要加44（不要自动布局）
    //    int row = indexPath.row;
    //    if(row==3){
    //        self.tableView.tableFooterView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    //        if (ISOS7) {
    //            CGSize size =CGSizeMake(tableView.contentSize.width, tableView.contentSize.height+44);
    //            [self.tableView setContentSize:size];
    //        }else{
    //            CGSize size =CGSizeMake(tableView.contentSize.width, tableView.contentSize.height+64);
    //            [self.tableView setContentSize:size];
    //        }
    //
    //    }
    
    switch (indexPath.row) {
        case 0:
        {
            if ([_rent rentImages]==nil && [_rent rentImages].count<=0) {
                return [[UITableViewCell alloc]initWithFrame:CGRectZero];
            }else{
                DetailImagesViewCell *cell=[tableView dequeueReusableCellWithIdentifier:detailImagesViewCell];
                if (cell==nil) {
                    cell=[[DetailImagesViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:detailImagesViewCell data:_rent];
                }
                return cell;
            }
            break;
        }
        case 1:
        {
            DetailTitleViewCell *cell = [tableView dequeueReusableCellWithIdentifier:detailTitleViewCell];
            if (cell==nil) {
                cell=[[DetailTitleViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:detailTitleViewCell data:_rent];
            }
            return cell;
            break;
        }case 2:
        {
            DetailPriceViewCell *cell = [tableView dequeueReusableCellWithIdentifier:detailPriceCell];
            if (cell==nil) {
                cell= (DetailPriceViewCell *)[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:detailPriceCell];
            }
            [cell setAttribute:_rent];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            return cell;
            break;
        }case 3:
        {
            DetailMapViewCell *cell=[tableView dequeueReusableCellWithIdentifier:mapCell];
            if (cell==nil) {
                cell=(DetailMapViewCell *)[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:mapCell];
            }
            [cell setAttribute:_rent];
            
            
            //使得选择行无效
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            //            [cell.imageViewMap setContentScaleFactor:[[UIScreen mainScreen] scale]];
            //
            //            cell.imageViewMap.contentMode=UIViewContentModeScaleAspectFill;
            //            cell.imageViewMap.autoresizingMask=UIViewAutoresizingFlexibleHeight;
            //            cell.imageViewMap.clipsToBounds=YES;
            //            cell.imageViewMap.frame=CGRectMake(13, 72, 300.0, 105.0);
            return cell;
            break;
            
        }case 4:
        {
            
            DetailContentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:contentCell];
            if (cell==nil) {
                cell=(DetailContentViewCell *)[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contentCell];
            }
            NSNumber *h=(NSNumber *)[_heightDictionary objectForKey:@"ContentCell"];
            cell.publishContent.font=[UIFont systemFontOfSize:13.0];
            cell.publishContent.frame=CGRectMake(10, 30, 300, h.doubleValue);
            cell.publishContent.text =_rent.publishContent;
            //[cell.publishContent setContentMode:UIViewContentModeTop];
            cell.publishContent.textAlignment=NSTextAlignmentLeft;
            [cell.publishContent setVerticalAlignment:VerticalAlignmentTop];
            cell.publishContent.numberOfLines=0;
            
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            return cell;
            break;
        }
            
        default:
            break;
    }
    return nil;
}


/**
 
 使得选择行无效
 */
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    if (cell.selectionStyle== UITableViewCellSelectionStyleNone) {
        return nil;
    }
    
    return indexPath;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
        {
            NSNumber *h = (NSNumber *)[_heightDictionary objectForKey:@"ImageCell"];
            return h.doubleValue;
        }
            
        case 1:
        {
            NSNumber *h=(NSNumber *)[_heightDictionary objectForKey:@"TitleCell"];
            return h.doubleValue;
            break;
        }
        case 2:
        {
            NSNumber *h=(NSNumber *)[_heightDictionary objectForKey:@"PriceCell"];
            return h.doubleValue;
            break;
        }
            
        case 3:
        {
            NSNumber *h=(NSNumber *)[_heightDictionary objectForKey:@"MapCell"];
            return h.doubleValue;
            break;
        }
        case 4:{
            
            NSNumber *h=(NSNumber *)[_heightDictionary objectForKey:@"ContentCell"];
            return h.doubleValue;
            break;
        }
            
    }
    
    return 0;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //记录事件
    [MobClick event:@"MapLocationEvent"];
    
    NSString *identifier= segue.identifier;
    if ([identifier compare:@"MapSegue"]==0) {
        MapViewController *controller = segue.destinationViewController;
        controller.lat=_rent.latitude;
        controller.lng=_rent.longitude;
        if (_rent.houseAddress==nil || [_rent.houseAddress length]<=0) {
            controller.address=_rent.resident;
        }else{
            controller.address=_rent.houseAddress;
        }
        
        if (_rent.contacterName==nil || [_rent.contacterName length]<=0) {
            controller.contacter=@"联系人";
        }else{
            controller.contacter=_rent.contacterName;
        }
        
        controller.tel=_rent.contacterPhone;
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"详细页面(附近)"];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
    [MobClick endLogPageView:@"详细页面(附近)"];
}

-(void)viewWillAppear:(BOOL)animated
{
 
}

-(void)hiddenTabbar{
    
}
@end
