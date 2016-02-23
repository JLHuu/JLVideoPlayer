//
//  JLPlayerView.m
//  JLVideoPlayer
//
//  Created by hujiele on 16/2/6.
//  Copyright © 2016年 JLHuu. All rights reserved.
//
#define Touch_Range (self.frame.size.height/12.f)

#import "JLPlayerView.h"

@interface JLPlayerView()<JlPlayerBottomBarDelegate,JLPlayerTopBarDelegate,UIGestureRecognizerDelegate>
@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic,strong)AVPlayerItem *playeritem;
@property (nonatomic,strong)AVURLAsset *asset;
@property (nonatomic,strong)MPVolumeView *volumeview; // 声音调节
@end
@implementation JLPlayerView
{
    CGFloat _starX;// 手指触摸开始点X
    CGFloat _starY;// 手指触摸开始点Y
    BOOL _isplaying; // 播放状态
    UITapGestureRecognizer *_tap;// 单击事件
    CGFloat _VolumeValue;// 声音值
    CGFloat _Bright;// 亮度值
    BOOL _leftPoint;// 触摸点位置左、右
    CGRect _OriginFrame; // 全屏点击前的frame
    UIView *video_superview;// 原始父视图
}
// 改变view底层layer,影片播放layer
+(Class)layerClass
{
    return [AVPlayerLayer class];
}
-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self _initUIWith:frame];
        [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}
- (void)_initUIWith:(CGRect)frame
{
    [self setBackgroundColor:[UIColor blackColor]];
    _topbar = [[JLPlayerTopBar alloc] initTopBarWithFrame:CGRectMake(0, 0, frame.size.width, TopBar_Height)];
    _topbar.delegate = self;
    _topbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_topbar];
    _bottombar = [[JLPlayerBottomBar alloc] initBottomBarWithFrame:CGRectMake(0, frame.size.height - BottomBar_Height, frame.size.width, BottomBar_Height)];
    _bottombar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _bottombar.delegate = self;
    [self addSubview:_bottombar];
    self.TouchControl = YES;
    self.showBottombar = YES;
    self.showTopbar = YES;
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_OnTap:)];
    _tap.delegate = self;
    [self addGestureRecognizer:_tap];
    self.currentstutas = PlayStatusStop;
}

-(AVPlayerLayer *)playerlayer
{
    return (AVPlayerLayer *)[self layer];
}
-(CGFloat)totaltime
{
    return CMTimeGetSeconds(_playeritem.duration);
}
-(void)setShowBottombar:(BOOL)showBottombar{
    _showBottombar = showBottombar;
    _bottombar.hidden = !_showBottombar;
}
-(void)setShowTopbar:(BOOL)showTopbar
{
    _showTopbar = showTopbar;
    _topbar.hidden = !_showTopbar;
}
-(void)setCurrentstutas:(PlayStatus)currentstutas
{
    _currentstutas = currentstutas;
    if (self.delegate && [self.delegate respondsToSelector:@selector(PlayerView:CurrentStutas:Error:)]) {
        [self.delegate PlayerView:self CurrentStutas:_currentstutas Error:_player.currentItem.error];
    }
}
-(void)setVideoMode:(PlayerVideoMode)VideoMode
{
    _VideoMode = VideoMode;
    switch (_VideoMode) {
        case PlayerVideoModeAspect:
            [self.playerlayer setVideoGravity:AVLayerVideoGravityResizeAspect];
            break;
        case PlayerVideoModeAspectfill:
            [self.playerlayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
            break;
        case PlayerVideoModeResize:
            [self.playerlayer setVideoGravity:AVLayerVideoGravityResize];
            break;
        default:
            break;
    }
}
-(void)setMovieurl:(NSURL *)movieurl
{
    _movieurl = movieurl;
    self.asset = [AVURLAsset URLAssetWithURL:movieurl options:nil];
    self.playeritem = [AVPlayerItem playerItemWithAsset:self.asset];
    self.player = [AVPlayer playerWithPlayerItem:_playeritem];
    [self.playerlayer setPlayer:_player];
    [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.player.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self _updateSlider];
    [self addNotification];
}
// 更新Slider
- (void)_updateSlider
{
    __weak UISlider *slider;
    for (UIView *aview in _bottombar.subviews) {
        if ([aview isKindOfClass:[UISlider class]]) {
            slider = (UISlider *)aview;
        }
    }
    __weak JLPlayerView *WE_SELF = self;
    // 检测频率1s/次
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_global_queue(0, 0) usingBlock:^(CMTime time) {
        CMTime currenttime = WE_SELF.player.currentItem.currentTime;
        CGFloat currtime = (CGFloat)currenttime.value/currenttime.timescale;
        dispatch_async(dispatch_get_main_queue(), ^{
            [slider setValue:currtime/WE_SELF.totaltime animated:YES];
            [WE_SELF.bottombar.timelable_l setText:[WE_SELF _TimetoStringWith:currtime]];
        });
    }];

}
- (MPVolumeView *)volumeview
{
    if (!_volumeview) {
        _volumeview = [[MPVolumeView alloc] initWithFrame:CGRectZero];
        _volumeview.showsVolumeSlider = YES;
        _volumeview.hidden = YES;
        [self addSubview:_volumeview];
    }
    return _volumeview;
}
#pragma mark - status
-(void)play
{
    if (self.player) {
        [self.player play];
        if (_playeritem.error) {
            _isplaying = NO;
            self.currentstutas = PlayStatusError;
            }else{
                _isplaying = YES;
                self.currentstutas = PlayStatusPlaying;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:StutasNotifacation object:nil userInfo:@{@"playstutas":@NO}];
        }
}
- (void)pause
{
    if (self.player) {
        if (self.player.currentItem.status != AVPlayerItemStatusReadyToPlay) {
            return;
        }
        [self.player pause];
        _isplaying = NO;
        self.currentstutas = PlayStatusPause;
        [[NSNotificationCenter defaultCenter] postNotificationName:StutasNotifacation object:nil userInfo:@{@"playstutas":@YES}];
    }
}
-(void)stopplay
{
    if (self.player) {
        _isplaying = NO;
        self.currentstutas = PlayStatusStop;
        if (self.player.currentItem.status == AVPlayerStatusReadyToPlay) {
            [self.player seekToTime:CMTimeMake(0, 1) completionHandler:^(BOOL finished) {
            }];
         }else{
            [self.player pause];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:StutasNotifacation object:nil userInfo:@{@"playstutas":@YES}];
        }
}
#pragma mark - GestureRecognizerDelegate
// 解决手势冲突
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[self class]]) {
        return YES;
    }
    return NO;
}
#pragma mark - 监听
- (void)addNotification
{
    // 添加视频播放完成的notifation
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    // 程序进入前台的notifation
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:)name:UIApplicationWillEnterForegroundNotification object:nil];
    // 程序进入后台的notifation
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)name:UIApplicationWillResignActiveNotification object:nil];
}
// 移除所有监听
-(void)RemoveAllObserveAndNoTi
{
    [self.playeritem removeObserver:self forKeyPath:@"status"];
    [self removeObserver:self forKeyPath:@"frame"];
    [self.playeritem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"]) {
        if (AVPlayerItemStatusReadyToPlay == _player.currentItem.status){            [_bottombar.timelable_r setText:[self _TimetoStringWith:self.totaltime]];
            }
    }
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
       CMTimeRange range = [[self.player.currentItem.loadedTimeRanges firstObject] CMTimeRangeValue];
        // 缓冲时长
       CGFloat progesstime = CMTimeGetSeconds(range.start) + CMTimeGetSeconds(range.duration);
        // 更新缓冲进度条
        [self.bottombar.bufferprogress setProgress:progesstime/self.totaltime];
    }
    if ([keyPath isEqualToString:@"frame"]) {
        [_topbar setFrame:CGRectMake(0, 0, self.frame.size.width, TopBar_Height)];
        [_bottombar setFrame:CGRectMake(0, self.frame.size.height - BottomBar_Height, self.frame.size.width, BottomBar_Height)];
    }
}

- (NSString *)_TimetoStringWith:(CGFloat)time
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:time/3600 >= 1 ? @"HH:mm:ss": @"mm:ss"];
    return [formatter stringFromDate:date];
}
#pragma mark - Ontap
-(void)_OnTap:(UITapGestureRecognizer *)tap
{
    // 隐藏Bar
    if (self.showBottombar) {
        _bottombar.hidden = !_bottombar.hidden;
    }
    if (self.showTopbar) {
        _topbar.hidden = !_topbar.hidden;
    }
}
#pragma mark - Noti事件
// 播放完成
- (void)moviePlayDidEnd:(NSNotification *)Noti
{
    [self stopplay];
}
// 进入前台
- (void)applicationWillEnterForeground:(NSNotification *)Noti
{
    if (_isplaying) {
        [self play];
    }else{
        [self pause];
    }

}
// 进入后台
- (void)applicationWillResignActive:(NSNotification *)Noti
{
    if (_isplaying) {
        [self pause];
        _isplaying = YES;
        self.currentstutas = PlayStatusPlaying;
    }
}
-(void)BottomBar:(JLPlayerBottomBar *)bar didSelectedplay_pasueBtn:(UIButton *)btn
{
    if (_isplaying) {
        [self pause];
    }else{
        [self play];
    }
}
#pragma mark - fullScreen
-(void)BottomBar:(JLPlayerBottomBar *)bar didSelectedfullScreenBtn:(UIButton *)btn Withfullscreen:(BOOL)isfullscreen
{
    if (isfullscreen) {
        [self _didSelectfullscreenfinished:^(BOOL finished) {
        }];
    }else{
        [self _didSelectFullScreenOrigin:^(BOOL finsihed) {
            video_superview = nil;
           _OriginFrame = CGRectZero;
        }];
    }
    // 发送全屏通知
    [[NSNotificationCenter defaultCenter] postNotificationName:PlayFullScreenNotifaction object:btn userInfo:@{@"isfullscreen":@(isfullscreen)}];
}
// 变为全屏
- (void)_didSelectfullscreenfinished:(void(^)(BOOL finished)) isfinished
{
// 把其添加到window上，设置为全屏
    // 记录点击全屏前的superview，frame
    video_superview = self.superview;
    _OriginFrame = self.frame;
    [self removeFromSuperview];
    CGSize size = [UIScreen mainScreen].bounds.size;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [UIView animateWithDuration:0.3 animations:^{
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        [self setFrame:CGRectMake(0, 0, size.height, size.width)];
        self.transform = CGAffineTransformMakeRotation(M_PI_2);
        self.center = CGPointMake(size.width/2.f, size.height/2.f);
    } completion:^(BOOL finished) {
        isfinished(finished);
    }];
}
// 变为原样
-(void)_didSelectFullScreenOrigin:(void (^)(BOOL finsihed)) isfinished
{
    if (video_superview !=nil && &_OriginFrame != NULL) {
        [video_superview bringSubviewToFront:self];
        [UIView animateWithDuration:0.3 animations:^{
            self.transform = CGAffineTransformIdentity;
            [self setFrame:_OriginFrame];
            [self removeFromSuperview];
            [video_superview addSubview:self];
        } completion:^(BOOL finished) {
            isfinished(finished);
        }];
    }
}
#pragma mark - Delegate

-(void)TopBar:(JLPlayerTopBar *)topbar didSelectedBackBtn:(UIButton *)backbtn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(PlayerView:didSelectBackbtn:)]) {
        [self.delegate PlayerView:self didSelectBackbtn:backbtn];
    }
}
-(void)TopBar:(JLPlayerTopBar *)topbar didSelectedShareBtn:(UIButton *)sharebtn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(PlayerView:didSelectShareBtn:)]) {
        [self.delegate PlayerView:self didSelectShareBtn:sharebtn];
    }
}
-(void)BottomBar:(JLPlayerBottomBar *)bar PlaySilder:(UISlider *)slider MoveStutas:(PlaySilderMoveStutas)stutas
{

    if (stutas == PlaySilderMoveStutasBegain) {
        [self pause];
    }else if (stutas == PlaySilderMoveStutasMove){
        CMTime Time = CMTimeMake(slider.value * self.totaltime, 1);
        [_player seekToTime:Time completionHandler:^(BOOL finished) {
            
        }];
    }else{
        [self play];
    }
}
#pragma mark - dealloc
-(void)dealloc
{
    [self RemoveAllObserveAndNoTi];
    [self stopplay];
}
#pragma mark - touch
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    if (!_TouchControl) {
        return;
    }
    UISlider *VolumeSlider = nil;
    for (UIControl *subview in [self.volumeview subviews]) {
        if ([subview isKindOfClass:[UISlider class]]) {
            VolumeSlider = (UISlider *)subview;
        }
    }
    _VolumeValue = VolumeSlider.value;
    _Bright = [UIScreen mainScreen].brightness;
    UITouch *touch = [touches anyObject];
    CGPoint starPoint = [touch locationInView:self];
    _starX = starPoint.x;
    _starY = starPoint.y;
    _leftPoint = _starX < self.frame.size.width/2 ? YES : NO;
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    if (!_TouchControl) {
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint endpoint = [touch locationInView:self];
    CGFloat _endY = endpoint.y;
    // 左边为亮度调节，右边为声音调节
    if (_leftPoint) {
        if (_endY - _starY > Touch_Range || _endY - _starY < -Touch_Range) {// 声音变化
            if (_endY - _starY > Touch_Range) {
                _VolumeValue -= 0.1;

            }else{
                _VolumeValue += 0.1;

            }
            UISlider *VolumeSlider = nil;
            for (UIControl *subview in [self.volumeview subviews]) {
                if ([subview isKindOfClass:[UISlider class]]) {
                    VolumeSlider = (UISlider *)subview;
                }
            }
           _VolumeValue = _VolumeValue > 1 ? 1:_VolumeValue;
           _VolumeValue = _VolumeValue < 0 ? 0:_VolumeValue;
            [VolumeSlider setValue:_VolumeValue animated:YES];
            _starY = _endY;
        }
    }else{
        if (_endY - _starY > Touch_Range || _endY - _starY < -Touch_Range) {// 亮度变化
            if (_endY - _starY > Touch_Range) {
                _Bright -= 0.1;
            }else{
                _Bright += 0.1;
            }
            _Bright = _Bright < 0 ? 0 : _Bright;
            _Bright = _Bright > 1 ? 1 : _Bright;
            [[UIScreen mainScreen] setBrightness:_Bright];
            _starY = _endY;
        }
    }
}

@end
