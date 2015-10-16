//
//  SJVideoPlayerController.m
//  SJVideoPlayerPlus
//
//  Created by Shaojie Hong on 15/9/15.
//  Copyright (c) 2015年 Shaojie Hong. All rights reserved.
//

#import "SJVideoPlayerController.h"
#import "SJVideoPlayerControlView.h"
#import <AVFoundation/AVFoundation.h>

static const CGFloat kVideoPlayerControllerAnimationTimeinterval = 0.3f;

@interface SJVideoPlayerController()

@property (nonatomic, strong) SJVideoPlayerControlView *videoControl;
@property (nonatomic, strong) UIView *movieBackgroundView;
@property (nonatomic, assign) BOOL isFullscreenMode;
@property (nonatomic, assign) CGRect originFrame;
@property (nonatomic, strong) NSTimer *durationTimer;

@end


@implementation SJVideoPlayerController

- (void)dealloc {
    [self cancelObserver];
    [self stopDurationTimer];
}

- (instancetype)initWithFrame:(CGRect)frame contentURL:(NSString *)url {
    self = [super init];
    if (self) {
        self.view.frame = frame;
        self.view.backgroundColor = [UIColor blackColor];
        self.controlStyle = MPMovieControlStyleNone;
        [self configObserver];
        [self configControlAction];
        [self ListeningRotating];
        
        NSURL *contentUrl = [NSURL URLWithString:url];
        self.contentURL = contentUrl;
        
        self.shouldAutoplay = NO;
        [self showViewCover];
        
        [self.view addSubview:self.videoControl];
        self.videoControl.frame = self.view.bounds;
    }
    return self;
}

#pragma mark - Override Method

- (void)setContentURL:(NSURL *)contentURL {
    [self stop];
    [super setContentURL:contentURL];
//    [self play];
}

#pragma mark - Publick Method

- (void)showInWindow {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    if (!keyWindow) {
        keyWindow = [[[UIApplication sharedApplication] windows] firstObject];
    }
    [keyWindow addSubview:self.view];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)dismiss {
    [self stopDurationTimer];
    [self stop];
    [UIView animateWithDuration:kVideoPlayerControllerAnimationTimeinterval animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        if (self.dimissCompleteBlock) {
            self.dimissCompleteBlock();
        }
    }];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

#pragma mark - Private Method

- (void)configObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerPlaybackStateDidChangeNotification) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerLoadStateDidChangeNotification) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerReadyForDisplayDidChangeNotification) name:MPMoviePlayerReadyForDisplayDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMovieDurationAvailableNotification) name:MPMovieDurationAvailableNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerPlaybackDidFinishNotification) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    //获取视频截图完成
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(videoThumbnailLoadComplete:) name:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:nil];
}

- (void)cancelObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configControlAction {
    [self.videoControl.playButton addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.pauseButton addTarget:self action:@selector(pauseButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.closeButton addTarget:self action:@selector(closeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.fullScreenButton addTarget:self action:@selector(fullScreenButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.shrinkScreenButton addTarget:self action:@selector(shrinkScreenButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.progressSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.videoControl.progressSlider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    [self.videoControl.progressSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.progressSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpOutside];
    [self.videoControl.progressSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchCancel];
    
    [self setProgressSliderMaxMinValues];
    [self monitorVideoPlayback];
}

- (void)onMPMoviePlayerPlaybackStateDidChangeNotification {
    if (self.playbackState == MPMoviePlaybackStatePlaying) {
        self.videoControl.pauseButton.hidden = NO;
        self.videoControl.playButton.hidden = YES;
        [self startDurationTimer];
        [self.videoControl.indicatorView stopAnimating];
        [self.videoControl autoFadeOutControlBar];
        
        [self dismissVideoCover];
    } else {
        self.videoControl.pauseButton.hidden = YES;
        self.videoControl.playButton.hidden = NO;
        [self stopDurationTimer];
        if (self.loadState == MPMovieLoadStateStalled) {
            [self.videoControl.indicatorView startAnimating];
        }
        if (self.playbackState == MPMoviePlaybackStateStopped) {
            [self.videoControl animateShow];
        }
    }
}

- (void)onMPMoviePlayerLoadStateDidChangeNotification {
    if (self.loadState & MPMovieLoadStateStalled) {
        [self.videoControl.indicatorView startAnimating];
    }
}

- (void)onMPMoviePlayerReadyForDisplayDidChangeNotification{
}

- (void)onMPMovieDurationAvailableNotification {
    [self setProgressSliderMaxMinValues];
}

- (void)onMPMoviePlayerPlaybackDidFinishNotification {
    self.videoControl.progressSlider.value = 0;
    [self stopDurationTimer];
    [self showViewCover];
    [self backOrientationPortrait];
    
    if (self.willFinishPlayBlock) {
        self.willFinishPlayBlock();
    }
}

- (void)playButtonClick {
    [self play];
    self.videoControl.playButton.hidden = YES;
    self.videoControl.pauseButton.hidden = NO;
}

- (void)stopButtonClick {
    self.videoControl.progressSlider.value = 0;
    self.videoControl.playButton.hidden = NO;
    self.videoControl.pauseButton.hidden = YES;
    [self stopDurationTimer];
    [self showViewCover];
    [self stop];
    
    if (self.willFinishPlayBlock) {
        self.willFinishPlayBlock();
    }
}

- (void)pauseButtonClick {
    [self pause];
    self.videoControl.playButton.hidden = NO;
    self.videoControl.pauseButton.hidden = YES;
    
    if (self.willPausehPlayBlock) {
        self.willPausehPlayBlock();
    }
}

- (void)closeButtonClick {
    [self dismiss];
}

- (void)fullScreenButtonClick {
    if (self.isFullscreenMode) {
        return;
    }
    [self setDeviceOrientationLandscapeRight];
    
    [self resetVideoCover];
}

- (void)shrinkScreenButtonClick {
    if (!self.isFullscreenMode) {
        return;
    }
    
    [self backOrientationPortrait];
    
    [self resetVideoCover];
}

#pragma mark - 设备旋转监听 改变视频全屏状态显示方向 

//监听设备旋转方向
- (void)ListeningRotating{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDeviceOrientationChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil
     ];
}

- (void)onDeviceOrientationChange {
    if (!self.playbackState == MPMoviePlaybackStatePlaying) {
        return;
    }
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    switch (interfaceOrientation) {
            /**  case UIInterfaceOrientationUnknown:
             NSLog(@"未知方向");
             break;
             */
        case UIInterfaceOrientationPortraitUpsideDown:{
            NSLog(@"第3个旋转方向---电池栏在下");
            [self backOrientationPortrait];
        }
            break;
        case UIInterfaceOrientationPortrait:{
            NSLog(@"第0个旋转方向---电池栏在上");
            [self backOrientationPortrait];
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            NSLog(@"第2个旋转方向---电池栏在右");
            
            [self setDeviceOrientationLandscapeLeft];
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            
            NSLog(@"第1个旋转方向---电池栏在左");
            
            [self setDeviceOrientationLandscapeRight];
            
        }
            break;
            
        default:
            break;
    }
}

//返回小屏幕
- (void)backOrientationPortrait {
    if (!self.isFullscreenMode) {
        return;
    }
    /*
     * 若在windows上显示
     */
//    [self.superVideoView addSubview:self.view];
    
    [UIView animateWithDuration:0.3f animations:^{
        [self.view setTransform:CGAffineTransformIdentity];
        self.frame = self.originFrame;
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    } completion:^(BOOL finished) {
        self.isFullscreenMode = NO;
        self.videoControl.fullScreenButton.hidden = NO;
        self.videoControl.shrinkScreenButton.hidden = YES;
        if (self.willBackOrientationPortrait) {
            self.willBackOrientationPortrait();
        }
    }];
}

//电池栏在左全屏
- (void)setDeviceOrientationLandscapeRight{
    if (self.isFullscreenMode) {
        return;
    }
    
    self.originFrame = self.view.frame;
    CGFloat height = [[UIScreen mainScreen] bounds].size.width;
    CGFloat width = [[UIScreen mainScreen] bounds].size.height;
    CGRect frame = CGRectMake((height - width) / 2, (width - height) / 2, width, height);
    /*
     * 若要在windows上显示
     */
//    [self showInWindow];
    
    [UIView animateWithDuration:0.3f animations:^{
        self.frame = frame;
        [self.view setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    } completion:^(BOOL finished) {
        self.isFullscreenMode = YES;
        self.videoControl.fullScreenButton.hidden = YES;
        self.videoControl.shrinkScreenButton.hidden = NO;
        if (self.willChangeToFullscreenMode) {
            self.willChangeToFullscreenMode();
        }
    }];
}

//电池栏在右全屏
- (void)setDeviceOrientationLandscapeLeft {
    if (self.isFullscreenMode) {
        return;
    }
    self.originFrame = self.view.frame;
    CGFloat height = [[UIScreen mainScreen] bounds].size.width;
    CGFloat width = [[UIScreen mainScreen] bounds].size.height;
    CGRect frame = CGRectMake((height - width) / 2, (width - height) / 2, width, height);
    /*
     * 若要在windows上显示
     */
//    [self showInWindow];
    
    [UIView animateWithDuration:0.3f animations:^{
        self.frame = frame;
        [self.view setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
    } completion:^(BOOL finished) {
        self.isFullscreenMode = YES;
        self.videoControl.fullScreenButton.hidden = YES;
        self.videoControl.shrinkScreenButton.hidden = NO;
        if (self.willChangeToFullscreenMode) {
            self.willChangeToFullscreenMode();
        }
    }];
}

- (void)setProgressSliderMaxMinValues {
    CGFloat duration = self.duration;
    self.videoControl.progressSlider.minimumValue = 0.f;
    self.videoControl.progressSlider.maximumValue = duration;
}

- (void)progressSliderTouchBegan:(UISlider *)slider {
    [self pause];
    [self.videoControl cancelAutoFadeOutControlBar];
}

- (void)progressSliderTouchEnded:(UISlider *)slider {
    [self setCurrentPlaybackTime:floor(slider.value)];
    [self play];
    [self.videoControl autoFadeOutControlBar];
}

- (void)progressSliderValueChanged:(UISlider *)slider {
    double currentTime = floor(slider.value);
    double totalTime = floor(self.duration);
    [self setTimeLabelValues:currentTime totalTime:totalTime];
}

- (void)monitorVideoPlayback {
    double currentTime = floor(self.currentPlaybackTime);
    double totalTime = floor(self.duration);
    [self setTimeLabelValues:currentTime totalTime:totalTime];
    self.videoControl.progressSlider.value = ceil(currentTime);
}

- (void)setTimeLabelValues:(double)currentTime totalTime:(double)totalTime {
    double minutesElapsed = floor(currentTime / 60.0);
    double secondsElapsed = fmod(currentTime, 60.0);
    NSString *timeElapsedString = [NSString stringWithFormat:@"%02.0f:%02.0f", minutesElapsed, secondsElapsed];
    
    double minutesRemaining = floor(totalTime / 60.0);;
    double secondsRemaining = floor(fmod(totalTime, 60.0));;
    NSString *timeRmainingString = [NSString stringWithFormat:@"%02.0f:%02.0f", minutesRemaining, secondsRemaining];
    
    self.videoControl.timeLabel.text = [NSString stringWithFormat:@"%@/%@",timeElapsedString,timeRmainingString];
}

- (void)startDurationTimer {
    if (!_durationTimer) {
        _durationTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(monitorVideoPlayback) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_durationTimer forMode:NSDefaultRunLoopMode];
    }
}

- (void)stopDurationTimer {
    [_durationTimer invalidate];
    _durationTimer = nil;
}

- (void)fadeDismissControl {
    [self.videoControl animateHide];
}

#pragma mark - Property

- (SJVideoPlayerControlView *)videoControl {
    if (!_videoControl) {
        _videoControl = [[SJVideoPlayerControlView alloc] init];
    }
    return _videoControl;
}

- (UIView *)movieBackgroundView {
    if (!_movieBackgroundView) {
        _movieBackgroundView = [UIView new];
        _movieBackgroundView.alpha = 0.0;
        _movieBackgroundView.backgroundColor = [UIColor blackColor];
    }
    return _movieBackgroundView;
}

- (void)setFrame:(CGRect)frame {
    [self.view setFrame:frame];
    [self.videoControl setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [self.videoControl setNeedsLayout];
    [self.videoControl layoutIfNeeded];
}

- (void)showViewCover {
    if (!self.thumbnailImage) {
        [self getThumbnailImageForVideo];
    } else {
        [self constructVideoCover];
    }
}

- (void)videoThumbnailLoadComplete:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
//    NSNumber *timecode =[userInfo objectForKey:MPMoviePlayerThumbnailTimeKey];
    self.thumbnailImage = [userInfo objectForKey:MPMoviePlayerThumbnailImageKey];
    
    if (self.playbackState != MPMoviePlaybackStatePlaying) {
        [self stop];
        [self constructVideoCover];
    }
}

- (void)constructVideoCover {
    if (!_videoCover) {
        _videoCover = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _videoCover.userInteractionEnabled = YES;
        _videoCover.image = self.thumbnailImage;
        [self.view insertSubview:_videoCover belowSubview:self.videoControl];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playButtonClick)];
        [_videoCover addGestureRecognizer:tap];
    }
}

- (void)resetVideoCover {
    if (_videoCover) {
        _videoCover.frame = self.view.bounds;
    }
}

- (void)dismissVideoCover {
    if (_videoCover) {
        [UIView animateWithDuration:0.5 animations:^{
            _videoCover.alpha = 0;
        } completion:^(BOOL finished) {
            [_videoCover removeFromSuperview];
            _videoCover = nil;
        }];
    }
}

#pragma mark - 获取视频图片

/**
 *  获取视频截图 同步
 */
+ (UIImage *)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60) actualTime:NULL error:&thumbnailImageGenerationError];
    
    if (!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
    
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef] : nil;
    
    return thumbnailImage;
}

/**
 *  获取视频截图 异步
 */
- (void)asynchronouslyThumbnailImageForVideo:(NSURL *)videoURL {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
            NSParameterAssert(asset);
            AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
            assetImageGenerator.appliesPreferredTrackTransform = YES;
            assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
            
            NSMutableArray *thumbnails = [NSMutableArray  arrayWithObjects:[NSNumber numberWithDouble:5], nil];
            [assetImageGenerator generateCGImagesAsynchronouslyForTimes:thumbnails completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
                
                if (image) {
                    UIImage *coverImg = [[UIImage alloc] initWithCGImage:image];
                    self.videoCover.image = coverImg;
                }
            }];
        }
    });
}

/**
 *  获取视频截图 异步 MPMoviePlayerController方法
 */
- (void)getThumbnailImageForVideo {
    NSMutableArray *allThumbnails = [NSMutableArray  arrayWithObjects:[NSNumber numberWithDouble:0.5],nil];
    [self requestThumbnailImagesAtTimes:allThumbnails timeOption:MPMovieTimeOptionExact];
}


@end
