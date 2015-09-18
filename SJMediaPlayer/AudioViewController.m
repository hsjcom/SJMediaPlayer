//
//  AudioViewController.m
//  SJMediaPlayer
//
//  Created by Soldier on 15/9/18.
//  Copyright (c) 2015年 Shaojie Hong. All rights reserved.
//

#import "AudioViewController.h"

@interface AudioViewController ()

@end



@implementation AudioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    AudioPlayerView *audioPlayerView = [[AudioPlayerView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:audioPlayerView];
}





@end
