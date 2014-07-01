//
//  FeedbackViewCell.h
//  FastRent
//
//  Created by heng chengfei on 14-6-13.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaceHolderTextView.h"

@protocol FeedbackDelegate <NSObject>

-(void)resetFrame;
-(void)pushBackController;

@end
@interface FeedbackViewCell : UITableViewCell

@property(nonatomic,weak)IBOutlet UIPlaceHolderTextView *textView;
@property(nonatomic,weak)IBOutlet UITextField *contacterField;
@property(nonatomic,weak)IBOutlet UIButton *commitButton;

@property(nonatomic,retain)id<FeedbackDelegate> delegate;
//@property(nonatomic,copy)dispatch_block_t commitBlock;

-(IBAction)commit:(id)sender;
-(IBAction)exitKeyboard:(id)sender;


@end
