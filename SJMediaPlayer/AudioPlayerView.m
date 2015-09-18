/**********************************************************************************
 AudioPlayer.m
 
 Created by Thong Nguyen on 14/05/2012.
 https://github.com/tumtumtum/audjustable
 
 Copyright (c) 2012 Thong Nguyen (tumtumtum@gmail.com). All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 1. Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 3. All advertising materials mentioning features or use of this software
 must display the following acknowledgement:
 This product includes software developed by Thong Nguyen (tumtumtum@gmail.com)
 4. Neither the name of Thong Nguyen nor the
 names of its contributors may be used to endorse or promote products
 derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY Thong Nguyen ''AS IS'' AND ANY
 EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THONG NGUYEN BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 **********************************************************************************/

#import "AudioPlayerView.h"

@interface AudioPlayerView()

-(void)setupTimer;

-(void)updateControls;

@end



@implementation AudioPlayerView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
	
    if (self) {
		CGSize size = CGSizeMake(180, 50);
        _audioPlayer = [[AudioPlayer alloc] init];
        _audioPlayer.delegate = self;
        [self updateControls];

		_playFromHTTPButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		_playFromHTTPButton.frame = CGRectMake((frame.size.width - size.width) / 2, 160, size.width, size.height);
		[_playFromHTTPButton addTarget:self action:@selector(playFromHTTPButtonTouched) forControlEvents:UIControlEventTouchUpInside];
		[_playFromHTTPButton setTitle:@"Play from HTTP" forState:UIControlStateNormal];

		_playFromLocalFileButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		_playFromLocalFileButton.frame = CGRectMake((frame.size.width - size.width) / 2, 220, size.width, size.height);
		[_playFromLocalFileButton addTarget:self action:@selector(playFromLocalFileButtonTouched) forControlEvents:UIControlEventTouchUpInside];
		[_playFromLocalFileButton setTitle:@"Play from Local File" forState:UIControlStateNormal];
	
		_playButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		_playButton.frame = CGRectMake((frame.size.width - size.width) / 2, 350, size.width, size.height);
		[_playButton addTarget:self action:@selector(playButtonPressed) forControlEvents:UIControlEventTouchUpInside];
		
		_slider = [[UISlider alloc] initWithFrame:CGRectMake(20, 280, frame.size.width - 40, 20)];
		_slider.continuous = YES;
        //隐藏滑块
//        [_slider setThumbTintColor:[UIColor clearColor]];
        _slider.minimumTrackTintColor = [UIColor orangeColor];
        _slider.maximumTrackTintColor = [UIColor blackColor];
		[_slider addTarget:self action:@selector(sliderChanged) forControlEvents:UIControlEventValueChanged];
        
        _durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(_slider.frame.origin.x + _slider.frame.size.width - 50, _slider.frame.origin.y + 30, 50, 20)];
        _durationLabel.textColor = [UIColor blackColor];
        
        _curTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(_slider.frame.origin.x + 10, _slider.frame.origin.y + 30, 50, 20)];
        _curTimeLabel.textColor = [UIColor orangeColor];
        
		[self addSubview:_slider];
		[self addSubview:_playButton];
		[self addSubview:_playFromHTTPButton];
		[self addSubview:_playFromLocalFileButton];
        [self addSubview:_durationLabel];
        [self addSubview:_curTimeLabel];
		
		[self setupTimer];
    }
	
    return self;
}

-(void)sliderChanged {
	if (!_audioPlayer) {
		return;
	}
	
	NSLog(@"Slider Changed: %f", _slider.value);
	
	[self.audioPlayer seekToTime:_slider.value];
}

-(void)setupTimer {
	_timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(tick) userInfo:nil repeats:YES];
	
	[[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

-(void)tick{
	if (!_audioPlayer || _audioPlayer.duration == 0) {
		_slider.value = 0;
		
		return;
	}
	
	_slider.minimumValue = 0;
	_slider.maximumValue = self.audioPlayer.duration;
	
	_slider.value = self.audioPlayer.progress;
    
    _curTimeLabel.text = [self.class dateForMinSec:[NSString stringWithFormat:@"%f", _audioPlayer.progress]];
    _durationLabel.text = [self.class dateForMinSec:[NSString stringWithFormat:@"%f", _audioPlayer.duration]];
}

-(void)playFromHTTPButtonTouched {
	[self audioPlayerViewPlayFromHTTPSelected:self];
}

-(void)playFromLocalFileButtonTouched {
	[self audioPlayerViewPlayFromLocalFileSelected:self];
}

-(void)playButtonPressed {
	if (!self.audioPlayer) {
		return;
	}
	
	if (self.audioPlayer.state == AudioPlayerStatePaused) {
		[self.audioPlayer resume];
	}
	else {
		[self.audioPlayer pause];
	}
}

-(void)updateControls {
	if (self.audioPlayer == nil) {
		[_playButton setTitle:@"Play" forState:UIControlStateNormal];
	}
	else if (self.audioPlayer.state == AudioPlayerStatePaused) {
		[_playButton setTitle:@"Resume" forState:UIControlStateNormal];
	}
	else if (self.audioPlayer.state == AudioPlayerStatePlaying) {
		[_playButton setTitle:@"Pause" forState:UIControlStateNormal];
	}
	else {
		[_playButton setTitle:@"Play" forState:UIControlStateNormal];
	}
}

#pragma mark - AudioPlayerDelegate

-(void)audioPlayer:(AudioPlayer *)audioPlayer stateChanged:(AudioPlayerState)state {
	[self updateControls];
}

-(void)audioPlayer:(AudioPlayer *)audioPlayer didEncounterError:(AudioPlayerErrorCode)errorCode {
	[self updateControls];
}

-(void)audioPlayer:(AudioPlayer *)audioPlayer didStartPlayingQueueItemId:(NSObject *)queueItemId {
	[self updateControls];
}

-(void)audioPlayer:(AudioPlayer *)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject *)queueItemId {
	[self updateControls];
}

-(void)audioPlayer:(AudioPlayer *)audioPlayer didFinishPlayingQueueItemId:(NSObject *)queueItemId withReason:(AudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration {
	[self updateControls];
}

//秒数转为分秒：73.4 -> 1:13
+ (NSString *)dateForMinSec:(NSString *)second {
    float floatsSec = [second integerValue];
    if (floatsSec < 0) {
        floatsSec = 0;
    }
    int min = floatsSec / 60.0;
    int sec = fmodf(floatsSec, 60);
    NSString *str = sec < 10 ? [NSString stringWithFormat:@"%d:0%d", min, sec] : [NSString stringWithFormat:@"%d:%d", min, sec];
    return str;
}

-(void)audioPlayerViewPlayFromHTTPSelected:(AudioPlayerView *)audioPlayerView {
    NSURL *url = [NSURL URLWithString:@"http://sc.111ttt.com/up/mp3/80979/0A314FB20108D7E0AD282BCC8C8038BD.mp3"];
    
    [self.audioPlayer setDataSource:[self.audioPlayer dataSourceFromURL:url] withQueueItemId:url];
}

-(void)audioPlayerViewPlayFromLocalFileSelected:(AudioPlayerView *)audioPlayerView {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"m4a"];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    [self.audioPlayer setDataSource:[self.audioPlayer dataSourceFromURL:url] withQueueItemId:url];
}

@end
