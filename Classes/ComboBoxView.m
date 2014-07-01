//
//  ComboBoxView.m
//  comboBox
//
//  Created by duansong on 10-7-28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ComboBoxView.h"
#import "FPPopoverController.h"
#import "SelectionViewController.h"

@implementation ComboBoxView

#define PulldownWidthInCombox 20//定义combox上箭头按钮的宽度
#define TableWidth 200 //下拉表格的宽度
#define TableHeight 300 //下拉表格的高度

@synthesize comboBoxDatasource = _comboBoxDatasource;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		[self initVariables];
		[self initCompentWithFrame:frame];
    }
    return self;
}

#pragma mark -
#pragma mark custom methods

- (void)initVariables {
	_showComboBox = NO;
}

- (void)initCompentWithFrame:(CGRect)frame {
    _comboxWidth=frame.size.width;
    _comboxHeight=frame.size.height;
    
	_selectContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _comboxWidth-PulldownWidthInCombox, _comboxHeight)];
    _selectContentLabel.textAlignment=NSTextAlignmentCenter;
	_selectContentLabel.font = [UIFont systemFontOfSize:13.0f];
	_selectContentLabel.backgroundColor = [UIColor clearColor];
	[self addSubview:_selectContentLabel];
	
    _hiddenButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_hiddenButton setFrame:CGRectMake(0, 0, _comboxWidth, _comboxHeight)];
	_hiddenButton.backgroundColor = [UIColor clearColor];
	[_hiddenButton addTarget:self action:@selector(pulldownButtonWasClicked:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_hiddenButton];
    
	_pulldownButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_pulldownButton setFrame:CGRectMake(frame.size.width - PulldownWidthInCombox, 0, PulldownWidthInCombox, _comboxHeight)];
    //	[_pulldownButton setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"list_ico_d" ofType:@"png"]]
    //							   forState:UIControlStateNormal];
    [_pulldownButton setTitle:@"▼" forState:UIControlStateNormal];
    _pulldownButton.titleLabel.textAlignment=NSTextAlignmentLeft;
    _pulldownButton.titleLabel.font=[UIFont systemFontOfSize:8.0];
    _pulldownButton.titleLabel.textColor=[UIColor colorWithRed:170/255.0f green:170/250.0f blue:170/250.0f alpha:1];
	[_pulldownButton addTarget:self action:@selector(pulldownButtonWasClicked:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_pulldownButton];
    
	_comboBoxTableView = [[UITableView alloc] initWithFrame:CGRectMake(1, _comboxHeight+2, TableWidth, TableHeight)];
	_comboBoxTableView.dataSource = self;
	_comboBoxTableView.delegate = self;
	_comboBoxTableView.backgroundColor =[UIColor whiteColor];
	_comboBoxTableView.separatorColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
	_comboBoxTableView.hidden = YES;
    _comboBoxTableView.tableFooterView =[[UIView alloc]initWithFrame:CGRectZero];
    
	[self addSubview:_comboBoxTableView];
}

- (void)setContent:(NSString *)content {
	_selectContentLabel.text = content;
}

- (void)show {

    _comboBoxTableView.hidden = NO;
	_showComboBox = YES;
	[self setNeedsDisplay];
    
    _selectContentLabel.textColor = [UIColor orangeColor];
    _pulldownButton.titleLabel.text=@"▲";
    _pulldownButton.titleLabel.textColor=[UIColor orangeColor];
    
    //显示时，为了点击有效，必须扩大其大小
    [self resizeFrame];
}

- (void)hidden {
	_comboBoxTableView.hidden = YES;
	_showComboBox = NO;
	[self setNeedsDisplay];
    
    _selectContentLabel.textColor=[UIColor blackColor];
    _pulldownButton.titleLabel.text=@"▼";
    _pulldownButton.titleLabel.textColor=[UIColor grayColor];
    
    //隐藏时，恢复最初原始大小
    [self resetFrame];
}

#pragma mark -
#pragma mark custom event methods

- (void)pulldownButtonWasClicked:(id)sender {
	if (_showComboBox == YES) {
		[self hidden];
    }else {
		[self show];
	}
    
    [self.delegate didComboxClick:self.tag];
}

-(void)resetFrame{
    self.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y,_comboxWidth,_comboxHeight);//下拉框不显示时，要回复combox的宽度和高度，防止影响其他地方的点击事件，虽然它是透明的
}
-(void)resizeFrame{
    self.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y,TableWidth, _comboxHeight+TableHeight);//扩大它的宽度和高度，否则下拉框的事件捕获不到
}

#pragma mark -
#pragma mark UITableViewDelegate and UITableViewDatasource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [_comboBoxDatasource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"ListCellIdentifier";
	UITableViewCell *cell = [_comboBoxTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	cell.textLabel.text = (NSString *)[_comboBoxDatasource objectAtIndex:indexPath.row];
	cell.textLabel.font = [UIFont systemFontOfSize:13.0f];
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 50.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self hidden];
	_selectContentLabel.text = (NSString *)[_comboBoxDatasource objectAtIndex:indexPath.row];
    
    //回到起始位置
    NSIndexPath *first = [NSIndexPath indexPathForRow:0 inSection:0];
    [tableView scrollToRowAtIndexPath:first atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    [self.delegate didComboxSelect:self.tag value:_selectContentLabel.text];
}

- (void)drawListFrameWithFrame:(CGRect)frame withContext:(CGContextRef)context {
	CGContextSetLineWidth(context, 1.0f);
	CGContextSetRGBStrokeColor(context, 0.5, 0.5, 0.5, 0.5);
    //绘制长方形线框
	if (_showComboBox == YES) {
        CGContextAddRect(context, CGRectMake(0.0f, 0.0f, _comboxWidth, _comboxHeight));
	}else {
		CGContextAddRect(context, CGRectMake(0.0f, 0.0f, _comboxWidth, _comboxHeight));
	}
    //	CGContextDrawPath(context, kCGPathStroke);
    //	CGContextMoveToPoint(context, 0.0f, 40.0f);
    //	CGContextAddLineToPoint(context, frame.size.width, 40.0f);
    // 	CGContextMoveToPoint(context, frame.size.width, 140.0f);
    //	CGContextAddLineToPoint(context, 0.0f, 140.0f);
	
	CGContextStrokePath(context);
}


#pragma mark -
#pragma mark drawRect methods

- (void)drawRect:(CGRect)rect {
	[self drawListFrameWithFrame:self.frame withContext:UIGraphicsGetCurrentContext()];
}


#pragma mark -
#pragma mark dealloc memery methods

//- (void)dealloc {
//	_comboBoxTableView.delegate		= nil;
//	_comboBoxTableView.dataSource	= nil;
//
//	_comboBoxDatasource				= nil;
//
//}


@end
