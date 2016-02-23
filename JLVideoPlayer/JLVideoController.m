//
//  JLVideoController.m
//  JLVideoPlayer
//
//  Created by hujiele on 16/2/13.
//  Copyright © 2016年 JLHuu. All rights reserved.
//

#import "JLVideoController.h"
#import "JLPlayerView.h"

@interface JLVideoController ()<JLPlayerViewDelegate>

@end

@implementation JLVideoController
{
    CGFloat ScreenWidth;
    CGFloat ScreeHeight;
    BOOL _isfullscreen;
}
-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        CGRect ScreenBounds = [UIScreen mainScreen].bounds;
        ScreenWidth = ScreenBounds.size.width < ScreenBounds.size.height ? ScreenBounds.size.width:ScreenBounds.size.height;
        ScreeHeight = ScreenBounds.size.height > ScreenBounds.size.width ? ScreenBounds.size.height: ScreenBounds.size.width;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.hidesBarsOnTap = YES;
    JLPlayerView *playview = (JLPlayerView *)self.view;
    playview.delegate = self;
    NSString * videoPath = @"http://hc30.aipai.com/user/855/43516855/7600978/card/28437153/card.mp4?l=c";
    playview.movieurl = [NSURL URLWithString:videoPath];
}
-(void)loadView
{
    JLPlayerView *playview = [[JLPlayerView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreeHeight)];
    playview.showFullScreenBtn = NO;
    self.view = playview;
}
#pragma mark - delegate
-(void)PlayerView:(JLPlayerView *)player CurrentStutas:(PlayStatus)stasus Error:(NSError *)error
{
    NSLog(@"stutas%ld",(long)stasus);
    if (error) {
        NSLog(@"error");
    }
}
-(void)PlayerView:(JLPlayerView *)player didSelectBackbtn:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)PlayerView:(JLPlayerView *)player didSelectShareBtn:(UIButton *)btn
{
    NSLog(@"分享功能");
}
#pragma mark - 隐藏状态栏
-(BOOL)prefersStatusBarHidden
{
    return YES;
}
#pragma mark - 旋转屏幕
-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}
-(BOOL)shouldAutorotate
{
    return YES;
}

@end
