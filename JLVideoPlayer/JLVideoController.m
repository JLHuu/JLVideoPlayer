//
//  JLVideoController.m
//  JLVideoPlayer
//
//  Created by hujiele on 16/2/13.
//  Copyright © 2016年 JLHuu. All rights reserved.
//

#import "JLVideoController.h"
#import "JLPlayerView.h"

@interface JLVideoController ()

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
    NSString * videoPath = @"http://hc30.aipai.com/user/855/43516855/7600978/card/28437153/card.mp4?l=c";
    playview.movieurl = [NSURL URLWithString:videoPath];
    [playview play];
}
-(void)loadView
{
    JLPlayerView *playview = [[JLPlayerView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreeHeight)];
    self.view = playview;
}
#pragma mark - 隐藏状态栏
-(BOOL)prefersStatusBarHidden
{
    return YES;
}
#pragma mark - 旋转屏幕
-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}
-(BOOL)shouldAutorotate
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
