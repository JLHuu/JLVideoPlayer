//
//  JLPlayerTopBar.m
//  JLVideoPlayer
//
//  Created by hujiele on 16/2/6.
//  Copyright © 2016年 JLHuu. All rights reserved.
//
#define Top_Bar_alpha 0.8
#define Font_Size 16.f
#define Btn_Wifth 44.f
#import "JLPlayerTopBar.h"
@interface JLPlayerTopBar()
{
    UIButton *_backbtn;
    UIButton *_sharbtn;
    UILabel *_titlelab;
}
@end
@implementation JLPlayerTopBar
-(void)setShowBackbtn:(BOOL)showBackbtn
{
    _showBackbtn = showBackbtn;
    _backbtn.hidden = !_showBackbtn;
}
-(void)setShowSharbtn:(BOOL)showSharbtn
{
    _showSharbtn = showSharbtn;
    _sharbtn.hidden = !_showSharbtn;
}
-(void)setShowTitlelable:(BOOL)showTitlelable
{
    _showTitlelable = showTitlelable;
    _titlelab.hidden = !_showTitlelable;
}
-(instancetype)initTopBarWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.alpha = Top_Bar_alpha;
        self.frame = frame;
        [self initUIWithFream:frame];
        self.showBackbtn = YES;
        self.showSharbtn = YES;
        self.showTitlelable = YES;
    }
    return self;
}
-(void)initUIWithFream:(CGRect)frame
{
    UIFont *def_font = [UIFont systemFontOfSize:Font_Size];
    _backbtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _backbtn.frame = CGRectMake(0, 0, Btn_Wifth, frame.size.height);
    _backbtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [_backbtn setTitle:@"返回" forState:UIControlStateNormal];
    [_backbtn.titleLabel setFont:def_font];
    [_backbtn addTarget:self action:@selector(_backbtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_backbtn];
    _sharbtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _sharbtn.frame = CGRectMake(frame.size.width - Btn_Wifth, 0, Btn_Wifth, frame.size.height);
    _sharbtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [_sharbtn setTitle:@"分享" forState:UIControlStateNormal];
    [_sharbtn.titleLabel setFont:def_font];
    [_sharbtn addTarget:self action:@selector(_sharebtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_sharbtn];
    _titlelab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width - Btn_Wifth*2, frame.size.height-8)];
    _titlelab.center = CGPointMake(frame.size.width/2.f, frame.size.height/2.f);
    _titlelab.textAlignment = NSTextAlignmentCenter;
    [_titlelab setFont:def_font];
    [_titlelab setTextColor:[UIColor whiteColor]];
    _titlelab.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_titlelab];
}
-(void)setMovieTitle:(NSString *)title
{
    _titlelab.text = title;
}
-(void)_backbtnClick:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(TopBar:didSelectedBackBtn:)]) {
        [self.delegate TopBar:self didSelectedBackBtn:btn];
    }
}
-(void)_sharebtnClick:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(TopBar:didSelectedShareBtn:)]) {
        [self.delegate TopBar:self didSelectedShareBtn:btn];
    }
}

@end
