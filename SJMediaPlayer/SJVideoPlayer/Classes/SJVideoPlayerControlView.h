//
//  SJVideoPlayerControlView.h
//  SJVideoPlayerPlus
//
//  Created by Shaojie Hong on 15/9/15.
//  Copyright (c) 2015年 Shaojie Hong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJVideoPlayerControlView : UIView

@property (nonatomic, strong, readonly) UIView *topBar;
@property (nonatomic, strong, readonly) UIView *bottomBar;
@property (nonatomic, strong, readonly) UIButton *playButton;
@property (nonatomic, strong, readonly) UIButton *pauseButton;
@property (nonatomic, strong, readonly) UIButton *fullScreenButton;
@property (nonatomic, strong, readonly) UIButton *shrinkScreenButton;
@property (nonatomic, strong, readonly) UISlider *progressSlider;
@property (nonatomic, strong, readonly) UIButton *closeButton;
@property (nonatomic, strong, readonly) UILabel *timeLabel;
@property (nonatomic, strong, readonly) UIActivityIndicatorView *indicatorView;

- (void)animateHide;

- (void)animateShow;

- (void)autoFadeOutControlBar;

- (void)cancelAutoFadeOutControlBar;

@end
