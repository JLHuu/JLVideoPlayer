//
//  ViewController.m
//  JLVideoPlayer
//
//  Created by hujiele on 16/2/6.
//  Copyright © 2016年 JLHuu. All rights reserved.
//

#import "ViewController.h"
#import "JLVideoController.h"
@interface ViewController ()<JLPlayerViewDelegate>
- (IBAction)OnClick1:(UIButton *)sender;
- (IBAction)Onclick2:(UIButton *)sender;

- (IBAction)Onclick3:(UIButton *)sender;

- (IBAction)Present:(UIButton *)sender;
@end

@implementation ViewController
{
    JLPlayerView *playview;
    BOOL _isfullScreen;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    playview = [[JLPlayerView alloc] initWithFrame:CGRectMake(10, 10, 300, 350)];
    [self.view addSubview:playview];
    NSURL *movieurl = nil;
        // 远程视频URL
        NSString * videoPath = @"http://hc30.aipai.com/user/855/43516855/7600978/card/28437153/card.mp4?l=c";
        movieurl = [NSURL URLWithString:videoPath];
        [playview setMovieurl:movieurl];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_FullScreen:) name:PlayFullScreenNotifaction object:nil];
    
}
- (void)_FullScreen:(NSNotification *)noti
{
    NSDictionary *dict = noti.userInfo;
    _isfullScreen = [dict[@"isfullscreen"] boolValue];
    // 刷新StatusBar
    [self setNeedsStatusBarAppearanceUpdate];
}
-(BOOL)prefersStatusBarHidden
{
    if (_isfullScreen) {
        return YES;
    }
    return NO;
}
// 此页禁止旋转屏幕
- (BOOL)shouldAutorotate
{
    return NO;
}
- (IBAction)OnClick1:(UIButton *)sender {
    playview.VideoMode = PlayerVideoModeAspect;
}

- (IBAction)Onclick3:(UIButton *)sender {
    playview.VideoMode = PlayerVideoModeAspectfill;

}
- (IBAction)Onclick2:(UIButton *)sender {
    playview.VideoMode = PlayerVideoModeResize;
    
}
- (IBAction)Present:(UIButton *)sender {
    JLVideoController *vc = [[JLVideoController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
