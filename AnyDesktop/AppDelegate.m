//
//  AppDelegate.m
//  AnyDesktop
//
//  Created by leon on 2019/10/23.
//  Copyright © 2019 Leonidas. All rights reserved.
//

#import "AppDelegate.h"

#import <AVFoundation/AVFoundation.h>

@interface AppDelegate ()
@property (weak) IBOutlet NSView *view;

@property (weak) IBOutlet NSWindow *window;
@property (nonatomic, strong) AVPlayer *player;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // 设置窗口
    [self setupWindow];
    // 设置窗口为全屏
    [NSApp setPresentationOptions:NSApplicationPresentationFullScreen];
    // 开始播放视频
    [self.player play];
}

- (void)setupWindow {
    NSWindowStyleMask mask = NSWindowStyleMaskBorderless | // 无边框
                             NSWindowStyleMaskResizable | // 可变大小
                             NSWindowStyleMaskFullScreen; // 全屏
    
    self.window.styleMask = mask;
    self.window.level = kCGDesktopWindowLevel; // 窗口层次在桌面之下
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = [NSColor clearColor].CGColor; // 设置窗口contentView为透明
    self.window.backgroundColor = [NSColor clearColor]; // 设置窗口为透明
}

- (AVPlayer *)player {
    if (!_player ) {
        _player = [AVPlayer playerWithPlayerItem:[self itemWithIndex:3]];

        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        playerLayer.frame = self.view.bounds;
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;

        [self.view.layer addSublayer:playerLayer];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(runLoopTheMovie:) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
        
    }
    return _player ;
}

- (AVPlayerItem*)itemWithIndex:(NSUInteger)idx {
    NSString *resName = [NSString stringWithFormat:@"demo%ld", idx];

    NSString *path = [[NSBundle mainBundle] pathForResource:resName ofType:@"mp4"];
    NSURL *url = [NSURL fileURLWithPath:path];
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:url];
    return playerItem;
}

#pragma mark - 接收播放完成的通知，实现循环播放
- (void)runLoopTheMovie:(NSNotification *)notification {
    AVPlayerItem *playerItem = notification.object;
    __weak typeof(self) weakself = self;
    [playerItem seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        __strong typeof(self) strongself = weakself;
        [strongself->_player play];
    }];
}




@end
