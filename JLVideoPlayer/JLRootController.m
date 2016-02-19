//
//  JLRootController.m
//  JLVideoPlayer
//
//  Created by hujiele on 16/2/17.
//  Copyright © 2016年 JLHuu. All rights reserved.
//

#import "JLRootController.h"

@interface JLRootController ()

@end

@implementation JLRootController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
// 设置需要旋转的屏幕
- (BOOL)shouldAutorotate
{
    return self.topViewController.shouldAutorotate;
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
