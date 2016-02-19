//
//  JLPlayerBottomBar.h
//  JLVideoPlayer
//
//  Created by hujiele on 16/2/6.
//  Copyright © 2016年 JLHuu. All rights reserved.
//

#import <UIKit/UIKit.h>
#define IMG_NAME(name) [UIImage imageWithContentsOfFile: [[[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"IMG.bundle"] stringByAppendingPathComponent:name]]

#define StutasNotifacation @"StutasNotifacation"

typedef NS_ENUM(NSInteger,PlaySilderMoveStutas){
    PlaySilderMoveStutasBegain = 0,// slider将要移动
    PlaySilderMoveStutasMove,// slider正在移动
    PlaySilderMoveStutasEnd,// slider移动结束
};
@class JLPlayerBottomBar;
@protocol JlPlayerBottomBarDelegate <NSObject>
// 播放暂停按钮
- (void)BottomBar:(JLPlayerBottomBar *)bar didSelectedplay_pasueBtn:(UIButton *)btn;
// 全屏点击
- (void)BottomBar:(JLPlayerBottomBar *)bar didSelectedfullScreenBtn:(UIButton *)btn Withfullscreen:(BOOL)isfullscreen;
// 进度条拖动状态
- (void)BottomBar:(JLPlayerBottomBar *)bar PlaySilder:(UISlider *)slider MoveStutas:(PlaySilderMoveStutas)stutas;

@end
@interface JLPlayerBottomBar : UIView
@property (nonatomic,weak) id<JlPlayerBottomBarDelegate>delegate;
// currenttime
@property (nonatomic,strong) UILabel *timelable_l;
// totaltime
@property (nonatomic,strong) UILabel *timelable_r;
// 缓冲进度条
@property (nonatomic,strong) UIProgressView *bufferprogress;
-(instancetype)initBottomBarWithFrame:(CGRect)frame;
@end
