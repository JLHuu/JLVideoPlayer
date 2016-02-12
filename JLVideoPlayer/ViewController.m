//
//  ViewController.m
//  JLVideoPlayer
//
//  Created by hujiele on 16/2/6.
//  Copyright © 2016年 JLHuu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
- (IBAction)OnClick1:(UIButton *)sender;
- (IBAction)Onclick2:(UIButton *)sender;

- (IBAction)Onclick3:(UIButton *)sender;

@end

@implementation ViewController
{
    JLPlayerView *playview;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    playview = [[JLPlayerView alloc] initWithFrame:CGRectMake(10, 10, 300, 350)];
//    playview.cantouchchange = YES;
    playview.VideoMode = PlayerVideoModeAspectfill;
    [self.view addSubview:playview];
    NSURL *movieurl = nil;
    if(/* DISABLES CODE */ (YES)){
        // 远程视频URL
        NSString * videoPath = @"http://hc30.aipai.com/user/855/43516855/7600978/card/28437153/card.mp4?l=c";
        movieurl = [NSURL URLWithString:videoPath];
    }else{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"YY" ofType:@"mp4"];
        movieurl = [NSURL fileURLWithPath:path];
    }
    [playview setMovieurl:movieurl];
//    [playview play];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)OnClick1:(UIButton *)sender {
    playview.VideoMode = 0;
}

- (IBAction)Onclick3:(UIButton *)sender {
    playview.VideoMode = 1;

}
- (IBAction)Onclick2:(UIButton *)sender {
    playview.VideoMode = 2;

}
@end
