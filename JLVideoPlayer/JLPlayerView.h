//
//  JLPlayerView.h
//  JLVideoPlayer
//
//  Created by hujiele on 16/2/6.
//  Copyright © 2016年 JLHuu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "JLPlayerBottomBar.h"
#import "JLPlayerTopBar.h"
#import <AVFoundation/AVFoundation.h>

#define FullScreenDidSelectedNotifaction @"FullScreenDidSelectedNotifaction"
#define BottomBar_Height 64.f
#define TopBar_Height 44.f
typedef NS_ENUM(NSInteger,PlayerVideoMode){
     //原始比例
    PlayerVideoModeAspect = 0,
     //填充
    PlayerVideoModeAspectfill,
     //比例填充
    PlayerVideoModeResize,
};
typedef NS_ENUM(NSInteger,PlayStatus){
    PlayStatusStop,// 停止状态
    PlayStatusPlaying,// 正在播放
    PlayStatusPause,// 暂停状态
    PlayStatusError,// 播放错误
};
@class JLPlayerView;
@protocol JLPlayerViewDelegate <NSObject>
@optional
// 快进、快退
- (void)PlayerView:(JLPlayerView *)player MoviedidRunFaster:(BOOL)faster;
// 当前播放状态
- (void)PlayerView:(JLPlayerView *)player CurrentStutas:(PlayStatus)stasus Error:(NSError *)error;
// 点击分享按钮
- (void)PlayerView:(JLPlayerView *)player didSelectShareBtn:(UIButton *)btn;
// 点击返回按钮
- (void)PlayerView:(JLPlayerView *)player didSelectBackbtn:(UIButton *)btn;
@end

@interface JLPlayerView : UIView
// 当前View的layer
@property (nonatomic,strong,readonly) AVPlayerLayer *playerlayer;
@property (nonatomic,weak) id<JLPlayerViewDelegate>delegate;
@property (nonatomic,strong)NSURL *movieurl;// movie url地址
// 视频填充类型,defaulet= PlayerVideoModeAspect;
@property (nonatomic,assign)PlayerVideoMode VideoMode;
// 是否可以触摸view改变声音和亮度，默认为YES
@property (nonatomic,assign)BOOL TouchControl;
// default yes
@property (nonatomic,assign)BOOL showTopbar;
@property (nonatomic,assign)BOOL showBottombar;
// 当前播放状态
@property (nonatomic,assign)PlayStatus currentstutas;
@property (nonatomic,readonly)CGFloat totaltime;// 总时长
// 播放
- (void)play;
// 暂停
- (void)pause;
// 停止
- (void)stopplay;
@end
