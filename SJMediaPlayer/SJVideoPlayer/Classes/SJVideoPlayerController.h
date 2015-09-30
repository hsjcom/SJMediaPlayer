//
//  SJVideoPlayerController.h
//  SJVideoPlayerPlus
//
//  Created by Shaojie Hong on 15/9/15.
//  Copyright (c) 2015年 Shaojie Hong. All rights reserved.
//

#import <UIKit/UIKit.h>

@import MediaPlayer;

@interface SJVideoPlayerController : MPMoviePlayerController

/** video.view 消失 */
@property (nonatomic, copy)void(^dimissCompleteBlock)(void);
/** 进入最小化状态 */
@property (nonatomic, copy)void(^willBackOrientationPortrait)(void);
/** 进入全屏状态 */
@property (nonatomic, copy)void(^willChangeToFullscreenMode)(void);
/** 进入播放结束状态 */
@property (nonatomic, copy)void(^willFinishPlayBlock)(void);

@property (nonatomic, assign) CGRect frame;

@property (nonatomic, strong) UIView *superVideoView; //superview，用于全屏在window上时，恢复视图回到原superview

@property (nonatomic, strong) UIImage *thumbnailImage; //视频缩略图
@property (nonatomic, strong) UIImageView *videoCover; //video封面

- (instancetype)initWithFrame:(CGRect)frame contentURL:(NSString *)url;

- (void)showInWindow;

- (void)dismiss;

/**
 *  获取视频截图
 */
+ (UIImage *)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time;

- (void)constructVideoCover;

- (void)playButtonClick;

- (void)stopButtonClick;

@end
