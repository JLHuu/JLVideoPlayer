//
//  JLPlayerBottomBar.m
//  JLVideoPlayer
//
//  Created by hujiele on 16/2/6.
//  Copyright © 2016年 JLHuu. All rights reserved.
//
#define Bottom_Bar_alpha 0.8
#define Font_Size 8.f
#import "JLPlayerBottomBar.h"
#import <objc/runtime.h>
@interface JLPlayerBottomBar()
// 播放进度条
@property (nonatomic,strong) UISlider *playslider;
// 缓冲进度条
@property (nonatomic,strong) UIProgressView *bufferprogress;
// 全屏点击按钮
@property (nonatomic,strong) UIButton *fullScreenBtn;
// 播放暂定按钮
@property (nonatomic,strong) UIButton *Play_PauseBtn;
@end
@implementation JLPlayerBottomBar
{
    BOOL _IsFullScreen;
}
-(instancetype)initBottomBarWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        self.frame = frame;
        self.backgroundColor = [UIColor blackColor];
        self.alpha = Bottom_Bar_alpha;
        [self initUIWithFrame:frame];
    }
    return self;
}
- (void)initUIWithFrame:(CGRect)frame
{
    _playslider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, frame.size.width*0.5, 20)];
    _playslider.center = CGPointMake(self.bounds.size.width /2.f, self.bounds.size.height/2.f);
    [_playslider setThumbImage:[UIImage imageNamed:@"thumbimg"] forState:UIControlStateNormal];
    [_playslider setThumbImage:[UIImage imageNamed:@"thumbimg_H"] forState:UIControlStateHighlighted];
    _playslider.minimumValue = 0.f;
    _playslider.maximumValue = 1.f;
    _playslider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_playslider addTarget:self action:@selector(_plysliderMoveBegain:) forControlEvents:UIControlEventTouchDown];
    [_playslider addTarget:self action:@selector(_plysliderMove:) forControlEvents:UIControlEventValueChanged];
    [_playslider addTarget:self action:@selector(_plysliderMoveEnd:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_playslider];
    // playbtn
    _Play_PauseBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _Play_PauseBtn.tintColor = [UIColor whiteColor];
    _Play_PauseBtn.frame = CGRectMake(0, 0, .1*frame.size.width,.1*frame.size.width);
    _Play_PauseBtn.center = CGPointMake(0.1*frame.size.width, self.bounds.size.height/2.f);
    _Play_PauseBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [_Play_PauseBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [self addSubview:_Play_PauseBtn];
    [_Play_PauseBtn addTarget:self action:@selector(_PlAyDidSelect:) forControlEvents:UIControlEventTouchUpInside];
    // full screen btn
    _fullScreenBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _fullScreenBtn.tintColor = [UIColor whiteColor];
    _fullScreenBtn.frame = CGRectMake(0, 0, 0.1*frame.size.width,.1*frame.size.width);
    _fullScreenBtn.center = CGPointMake(0.9*frame.size.width, self.bounds.size.height/2.f);
    _fullScreenBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [_fullScreenBtn setImage:[UIImage imageNamed:@"fullscreen"] forState:UIControlStateNormal];
    [self addSubview:_fullScreenBtn];
    [_fullScreenBtn addTarget:self action:@selector(_FullScreenDidSelect:) forControlEvents:UIControlEventTouchUpInside];
    // timelabel
    UIFont *d_font = [UIFont systemFontOfSize:Font_Size];
    _timelable_l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0.1*frame.size.width, Font_Size+5)];
    _timelable_l.center = CGPointMake(0.2*frame.size.width, _playslider.center.y);
    _timelable_l.backgroundColor = [UIColor clearColor];
    _timelable_l.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    _timelable_l.font = d_font;
    _timelable_l.textColor = [UIColor whiteColor];
    _timelable_l.text = @"00:00";
    _timelable_l.textAlignment = NSTextAlignmentRight;
    [self addSubview:_timelable_l];
    _timelable_r = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0.1*frame.size.width, Font_Size+5)];
    _timelable_r.center = CGPointMake(0.8*frame.size.width, _playslider.center.y);
    _timelable_r.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    _timelable_r.backgroundColor = [UIColor clearColor];
    _timelable_r.font = d_font;
    _timelable_r.textColor = [UIColor whiteColor];
    _timelable_r.text = @"00:00";
    _timelable_r.textAlignment = NSTextAlignmentLeft;
    [self addSubview:_timelable_r];
    // 监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_PlayStutas:) name:StutasNotifacation object:nil];
}
#pragma mark - 监听
-(void)_PlayStutas:(NSNotification *)Noti
{
    NSDictionary *dict = Noti.userInfo;
    BOOL Playbtnstutas = [dict[@"playstutas"] boolValue];
    [_Play_PauseBtn setImage:[UIImage imageNamed:Playbtnstutas == YES ? @"pause": @"play"] forState:UIControlStateNormal];
}
#pragma mark - performSEL
- (void)_FullScreenDidSelect:(UIButton *)btn
{
    _IsFullScreen = !_IsFullScreen;
    if (_IsFullScreen) {
        [btn setImage:[UIImage imageNamed:@"nonfullscreen"] forState:UIControlStateNormal];
    }else{
        [btn setImage:[UIImage imageNamed:@"fullscreen"] forState:UIControlStateNormal];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(BottomBar:didSelectedfullScreenBtn:Withfullscreen:)]) {
        [self.delegate BottomBar:self didSelectedfullScreenBtn:btn Withfullscreen:_IsFullScreen];
    }

}
- (void)_PlAyDidSelect:(UIButton *)btn
{ 
    if (self.delegate && [self.delegate respondsToSelector:@selector(BottomBar:didSelectedplay_pasueBtn:)]) {
        [self.delegate BottomBar:self didSelectedplay_pasueBtn:btn];
    }
}
#pragma mark - SliderStutas
- (void)_plysliderMoveBegain:(UISlider *)slider
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(BottomBar:PlaySilder:MoveStutas:)]) {
        [self.delegate BottomBar:self PlaySilder:slider MoveStutas:PlaySilderMoveStutasBegain];
    }
}
- (void)_plysliderMove:(UISlider *)slider
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(BottomBar:PlaySilder:MoveStutas:)]) {
        [self.delegate BottomBar:self PlaySilder:slider MoveStutas:PlaySilderMoveStutasMove];
    }
}
- (void)_plysliderMoveEnd:(UISlider *)slider
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(BottomBar:PlaySilder:MoveStutas:)]) {
        [self.delegate BottomBar:self PlaySilder:slider MoveStutas:PlaySilderMoveStutasEnd];
    }
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
