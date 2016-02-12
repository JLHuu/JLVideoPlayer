//
//  JLPlayerTopBar.h
//  JLVideoPlayer
//
//  Created by hujiele on 16/2/6.
//  Copyright © 2016年 JLHuu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JLPlayerTopBar;
@protocol JLPlayerTopBarDelegate <NSObject>
@optional
// 点击返回按钮
- (void)TopBar:(JLPlayerTopBar *)topbar didSelectedBackBtn:(UIButton *)backbtn;
// 点击分享按钮
- (void)TopBar:(JLPlayerTopBar *)topbar didSelectedShareBtn:(UIButton *)sharebtn;

@end

@interface JLPlayerTopBar : UIView
// 代理
@property (nonatomic,weak) id<JLPlayerTopBarDelegate>delegate;
// default yes
@property (nonatomic,assign) BOOL showBackbtn;
@property (nonatomic,assign) BOOL showSharbtn;
@property (nonatomic,assign) BOOL showTitlelable;
// 初始化
-(instancetype)initTopBarWithFrame:(CGRect)frame;
// 设置影片title
- (void)setMovieTitle:(NSString *)title;
@end
