//
//  ComboBoxView.h
//  comboBox
//
//  Created by duansong on 10-7-28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ComboxDelegate <NSObject>

-(void)didComboxClick:(NSInteger)tag;

-(void)didComboxSelect:(NSInteger)tag value:(NSString *)value;

@end

@interface ComboBoxView : UIView < UITableViewDelegate, UITableViewDataSource > {
	UILabel			*_selectContentLabel;
	UIButton		*_pulldownButton;
	UIButton		*_hiddenButton;
	UITableView		*_comboBoxTableView;
	NSArray			*_comboBoxDatasource;
	BOOL			_showComboBox;
    
    float _comboxWidth;
    float _comboxHeight;
}


@property(nonatomic,retain) id<ComboxDelegate> delegate;

@property (nonatomic, retain) NSArray *comboBoxDatasource;

- (void)initVariables;
- (void)initCompentWithFrame:(CGRect)frame;
- (void)setContent:(NSString *)content;
- (void)show;
- (void)hidden;
- (void)drawListFrameWithFrame:(CGRect)frame withContext:(CGContextRef)context;

@end
