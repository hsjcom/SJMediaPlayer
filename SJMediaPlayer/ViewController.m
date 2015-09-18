//
//  ViewController.m
//  SJMediaPlayer
//
//  Created by Soldier on 15/9/15.
//  Copyright (c) 2015年 Shaojie Hong. All rights reserved.
//

#import "ViewController.h"
#import "VideoViewController.h"
#import "AudioViewController.h"

@interface ViewController ()

@end




@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"MEDIA";
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(self.view.frame.size.width * 0.5 - 150 * 0.5, 200, 150, 40);
    [btn1 setTitle:@"Video" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(video) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(self.view.frame.size.width * 0.5 - 150 * 0.5, 280, 150, 40);
    [btn2 setTitle:@"Audio" forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(audio) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
}

- (void)video {
    VideoViewController *controller = [[VideoViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)audio {
    AudioViewController *controller = [[AudioViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}




@end
