//
//  JLPlayerView.m
//  JLVideoPlayer
//
//  Created by hujiele on 16/2/6.
//  Copyright © 2016年 JLHuu. All rights reserved.
//
#define Touch_Range 30.f

#import "JLPlayerView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "JLPlayerBottomBar.h"
#import "JLPlayerTopBar.h"
@interface JLPlayerView()<JlPlayerBottomBarDelegate,JLPlayerTopBarDelegate,UIGestureRecognizerDelegate>
@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic,strong)AVPlayerItem *playeritem;
@property (nonatomic,strong)AVURLAsset *asset;
@property (nonatomic,strong)MPVolumeView *volumeview; // 声音调节
// 顶部栏
@property (nonatomic,strong)JLPlayerTopBar *topbar;
// 底部控制栏
@property (nonatomic,strong)JLPlayerBottomBar *bottombar;
@end
@implementation JLPlayerView
{
    CGFloat _starX;// 手指触摸开始点X
    CGFloat _starY;// 手指触摸开始点Y
    BOOL _isplaying; // 播放状态
    UITapGestureRecognizer *_tap;// 单击事件
}
// 改变view底层layer,影片播放layer
+(Class)layerClass
{
    return [AVPlayerLayer class];
}
-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initUIWith:frame];
    }
    return self;
}
- (void)initUIWith:(CGRect)frame
{
    [self setBackgroundColor:[UIColor blackColor]];
    _topbar = [[JLPlayerTopBar alloc] initTopBarWithFrame:CGRectMake(0, 0, frame.size.width, TopBar_Height)];
    _topbar.delegate = self;
    [self addSubview:_topbar];
    _bottombar = [[JLPlayerBottomBar alloc] initBottomBarWithFrame:CGRectMake(0, frame.size.height - BottomBar_Height, frame.size.width, BottomBar_Height)];
    _bottombar.delegate = self;
    [self addSubview:_bottombar];
    self.cantouchchange = YES;
    self.showBottombar = YES;
    self.showTopbar = YES;
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_OnTap:)];
    _tap.delegate = self;
    [self addGestureRecognizer:_tap];
    
}
-(AVPlayerLayer *)playerlayer
{
    return (AVPlayerLayer *)[self layer];
}
-(CGFloat)totaltime
{
    CMTime Time = _playeritem.duration;
    return (CGFloat)Time.value/Time.timescale;
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
            // kvo
        [self.player play];
        _isplaying = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:StutasNotifacation object:nil userInfo:@{@"playstutas":@YES,@"fullstutas":@YES}];
        }
}
- (void)pause
{
    if (self.player) {
        [self.player pause];
        _isplaying = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:StutasNotifacation object:nil userInfo:@{@"playstutas":@NO,@"fullstutas":@YES}];
    }
}
-(void)stopplay
{
    if (self.player) {
        _isplaying = NO;
        [self.player seekToTime:CMTimeMake(0, 1) completionHandler:^(BOOL finished) {
            [self.player setRate:0];
            [[NSNotificationCenter defaultCenter] postNotificationName:StutasNotifacation object:nil userInfo:@{@"playstutas":@NO,@"fullstutas":@YES}];
        }];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"]) {
        if (AVPlayerItemStatusReadyToPlay == _player.currentItem.status){            [_bottombar.timelable_r setText:[self _TimetoStringWith:self.totaltime]];
            }
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
    NSLog(@"进入前台");
}
// 进入后台
- (void)applicationWillResignActive:(NSNotification *)Noti
{
    // 暂停播放
    if (_isplaying) {
        [self pause];
    }
}
#pragma mark - delegate
-(void)BottomBar:(JLPlayerBottomBar *)bar didSelectedfullScreenBtn:(UIButton *)btn Withfullscreen:(BOOL)isfullscreen
{
    NSLog(@"fullscreen%d",isfullscreen);
}
-(void)BottomBar:(JLPlayerBottomBar *)bar didSelectedplay_pasueBtn:(UIButton *)btn 
{
    if (_isplaying) {
        [self pause];
    }else{
        [self play];
    }
}
-(void)TopBar:(JLPlayerTopBar *)topbar didSelectedBackBtn:(UIButton *)backbtn
{
    NSLog(@"Backbtn");
}
-(void)TopBar:(JLPlayerTopBar *)topbar didSelectedShareBtn:(UIButton *)sharebtn
{
    NSLog(@"shareBtn");
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
}
#pragma mark - touch
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    if (!_cantouchchange) {
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint starPoint = [touch locationInView:self];
    _starX = starPoint.x;
    _starY = starPoint.y;
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    if (!_cantouchchange) {
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint endpoint = [touch locationInView:self];
    CGFloat _endY = endpoint.y;
    // 左边为亮度调节，右边为声音调节
    BOOL _leftPoint;
    _leftPoint = _starX < self.frame.size.width/2 ? YES : NO;
    if (_leftPoint) {
        UISlider *VolumeSlider = nil;
        for (UIControl *subview in [self.volumeview subviews]) {
            if ([subview isKindOfClass:[UISlider class]]) {
                VolumeSlider = (UISlider *)subview;
            }
        }
        CGFloat currentValue = VolumeSlider.value;
        if (_endY - _starY > Touch_Range || _endY - _starY < -Touch_Range) {// 声音变化
            currentValue -= (_endY-_starY > Touch_Range ? (_endY-_starY-Touch_Range):(_endY-_starY+Touch_Range))/(self.frame.size.height*.75);
            currentValue = currentValue < 0 ? 0 : currentValue;
            currentValue = currentValue > 1 ? 1 : currentValue;
            [VolumeSlider setValue:currentValue animated:YES];
        }
    }else{
        CGFloat bright = [UIScreen mainScreen].brightness;
        if (_endY - _starY > Touch_Range || _endY - _starY < -Touch_Range) {// 亮度变化
            bright -= (_endY-_starY > Touch_Range ? (_endY-_starY-Touch_Range):(_endY-_starY+Touch_Range))/(self.frame.size.height *.75);
            bright = bright < 0 ? 0 : bright;
            bright = bright > 1 ? 1 : bright;
            [[UIScreen mainScreen] setBrightness:bright];
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if (!_cantouchchange) {
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint endpoint = [touch locationInView:self];
    CGFloat _endX = endpoint.x;
    if (_endX - _starX > Touch_Range || _endX - _starX < -Touch_Range) {// 快进or快退
        BOOL faster = _endX - _starX > Touch_Range ? YES : NO;
        if (self.delegate && [self.delegate respondsToSelector:@selector(PlayerView:MoviedidRunFaster:)]) {
            [self.delegate PlayerView:self MoviedidRunFaster:faster];
        }
    }
}
@end
