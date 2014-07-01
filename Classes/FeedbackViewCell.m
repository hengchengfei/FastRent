//
//  FeedbackViewCell.m
//  FastRent
//
//  Created by heng chengfei on 14-6-13.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import "FeedbackViewCell.h"
#import "MBProgressHUD.h"
#import "WebRequest.h"

@implementation FeedbackViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark 联系人输入框，完成的按键事件
-(IBAction)exitKeyboard:(id)sender{
    [[[UIApplication sharedApplication]keyWindow] endEditing:YES];
}
 

-(IBAction)commit:(id)sender
{
    [[[UIApplication sharedApplication ]keyWindow] endEditing:YES];
    [self.delegate resetFrame];
    
    NSString *strModel=[UIDevice currentDevice].model;
    NSString *strModelLocal=[UIDevice currentDevice].localizedModel;
    NSString *systemVersion=[UIDevice currentDevice].systemVersion;
    NSString *systemName=[UIDevice currentDevice].systemName;
    
    NSString *device=[NSString stringWithFormat:@"model=%@(%@) system=%@ %@" ,strModel,strModelLocal,systemName,systemVersion];
    NSString *contacter=self.contacterField.text;
    NSString *content=self.textView.text;
    
    content = [content stringByReplacingOccurrencesOfString:@" " withString:@""];
    contacter = [contacter stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if([content length]==0){
        [self warnMsg:@"您还没填写意见哦"];
        return;
    }
    if ([contacter length]==0) {
        [self warnMsg:@"请留下您的联系方式"];
        return;
    }
    
    contacter=[contacter stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    content=[content stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    device=[device stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    BOOL isConnect=[WebRequest isConnectionAvailable];
    if (!isConnect) {
        [self warnMsg:@"网络连接失败"];
        return;
    }
    
    MBProgressHUD *hudLoading=[MBProgressHUD showHUDAddedTo:self.superview animated:YES];
    hudLoading.labelText=@"提交中...";
    [hudLoading show:YES];
    
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block BOOL isSuccess;
        __block NSData *data;
        [WebRequest feedback:contacter content:content device:device complete:^(NSData *_data,NSError *error) {
            data=_data;
            if (error) {
                isSuccess=false;
            }else{
                isSuccess=true;
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [hudLoading hide:NO];
            if (isSuccess) {
                [self warnMsg:@"提交成功"];
                //[self commitBlock];
                [self.delegate pushBackController];
                return ;
            }else{
                [self warnMsg:@"提交失败"];
            }
        });
    });
}

-(void)warnMsg:(NSString *)msg{
    MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.superview animated:YES];
    hud.mode=MBProgressHUDModeText;
    hud.labelText=msg;
    [hud show:YES];
    [hud hide:YES afterDelay:2.0];
}
@end
