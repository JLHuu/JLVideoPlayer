//
//  JLPlayerView.h
//  JLVideoPlayer
//
//  Created by hujiele on 16/2/6.
//  Copyright © 2016年 JLHuu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#define BottomBar_Height 64.f
#define TopBar_Height 44.f
typedef NS_ENUM(NSInteger,PlayerVideoMode){
    PlayerVideoModeAspect = 0,
    PlayerVideoModeAspectfill,
    PlayerVideoModeResize,
};
@class JLPlayerView;
@protocol JLPlayerViewDelegate <NSObject>
@optional
// 快进、快退
- (void)PlayerView:(JLPlayerView *)player MoviedidRunFaster:(BOOL)faster;
// 声音大小
- (void)PlayerView:(JLPlayerView *)player VolumedidLoader:(BOOL)loader;
// 屏幕亮度
- (void)PlayerView:(JLPlayerView *)player ScreendidLighter:(BOOL)lighter;

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

@property (nonatomic,readonly)CGFloat totaltime;// 总时长
// 播放
- (void)play;
// 暂停
- (void)pause;
// 停止
- (void)stopplay;
@end
