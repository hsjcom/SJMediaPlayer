//
//  VideoViewController.m
//  SJMediaPlayer
//
//  Created by Soldier on 15/9/15.
//  Copyright (c) 2015年 Shaojie Hong. All rights reserved.
//

#import "VideoViewController.h"
#import "SJVideoPlayerController.h"

@interface VideoViewController ()

@property (nonatomic, strong) SJVideoPlayerController *videoController;

@end




@implementation VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"VIDEO";
    
    [self playVideo];
}

- (void)playVideo{
    self.url = @"http://www.itinge.com/music/15395.mp4";
    // http://7qnah8.com1.z0.glb.clouddn.com/Cinematic1.mp4
    // http://www.itinge.com/music/15395.mp4
    // http://krtv.qiniudn.com/150522nextapp
    
    [self videoController];
    [self setConfig];
}

- (void)setConfig {
    __weak typeof(self)weakSelf = self;
    
    [self.videoController setWillFinishPlayBlock:^{
        
    }];
    
    [self.videoController setDimissCompleteBlock:^{
        weakSelf.videoController = nil;
    }];
    
    [self.videoController setWillBackOrientationPortrait:^{
        [weakSelf toolbarHidden:NO];
    }];
    
    [self.videoController setWillChangeToFullscreenMode:^{
        [weakSelf toolbarHidden:YES];
    }];
}

//隐藏navigation tabbar 电池栏
- (void)toolbarHidden:(BOOL)Bool{
    self.navigationController.navigationBar.hidden = Bool;
    self.tabBarController.tabBar.hidden = Bool;
    [[UIApplication sharedApplication] setStatusBarHidden:Bool withAnimation:UIStatusBarAnimationFade];
}

//MPMoviePlayerController 系统机制，只能有一个在播放
- (void)stop {
    [self.videoController stopButtonClick];
    //释放
    _videoController = nil;
}

- (SJVideoPlayerController *)videoController {
    if (!_videoController) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        _videoController = [[SJVideoPlayerController alloc] initWithFrame:CGRectMake(0, 64, width, width * (9.0 / 16.0)) contentURL:self.url];
        
        /*
         * 若要在windows上显示
         */
        self.videoController.superVideoView = self.view;
        
        [self.view addSubview:self.videoController.view];
    }
//    _videoController.contentURL = [NSURL URLWithString:self.url];
    return _videoController;
}

@end
