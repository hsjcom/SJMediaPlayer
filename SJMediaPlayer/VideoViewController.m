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
    NSString *url = @"http://7qnah8.com1.z0.glb.clouddn.com/Cinematic1.mp4";
    // http://www.itinge.com/music/15395.mp4
    // http://krtv.qiniudn.com/150522nextapp
    // http://www.itinge.com/music/15395.mp4
    
    [self addVideoPlayerWithURL:url];
}

- (void)addVideoPlayerWithURL:(NSString *)url{
    if (!self.videoController) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        self.videoController = [[SJVideoPlayerController alloc] initWithFrame:CGRectMake(0, 64, width, width * (9.0 / 16.0)) contentURL:url];
        __weak typeof(self)weakSelf = self;
        [self.videoController setDimissCompleteBlock:^{
            weakSelf.videoController = nil;
        }];
        [self.videoController setWillBackOrientationPortrait:^{
            [weakSelf toolbarHidden:NO];
        }];
        [self.videoController setWillChangeToFullscreenMode:^{
            [weakSelf toolbarHidden:YES];
        }];
        
        [self.view addSubview:self.videoController.view];
    }
}

//隐藏navigation tabbar 电池栏
- (void)toolbarHidden:(BOOL)Bool{
    self.navigationController.navigationBar.hidden = Bool;
    self.tabBarController.tabBar.hidden = Bool;
    [[UIApplication sharedApplication] setStatusBarHidden:Bool withAnimation:UIStatusBarAnimationFade];
}

@end
