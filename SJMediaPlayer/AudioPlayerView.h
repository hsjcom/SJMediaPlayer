//
//  AudioPlayerView.h
//  SJMediaPlayer
//
//  Created by Soldier on 15/9/18.
//  Copyright (c) 2015年 Shaojie Hong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioPlayer.h"

@interface AudioPlayerView : UIView<AudioPlayerDelegate> {
@private
	NSTimer *_timer;
	UISlider *_slider;
	UIButton *_playButton;
	UIButton *_playFromHTTPButton;
	UIButton *_playFromLocalFileButton;
    
    UILabel *_durationLabel;
    UILabel *_curTimeLabel;
}

@property (nonatomic, strong) AudioPlayer *audioPlayer;

@end
