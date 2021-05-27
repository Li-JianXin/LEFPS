//
//  LERunLoopFPS.h
//  LEFPS
//
//  Created by 李建新 on 2021/5/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^LERunLoopFPSMonitor)(u_int8_t fps);

@interface LERunLoopFPS : NSObject

+ (instancetype)shared;

/// 当前帧数
@property (nonatomic, assign, readonly) u_int8_t fps;


/// 设置监视器
/// @param monitor 监听器callback
- (void)setMonitor:(LERunLoopFPSMonitor)monitor;

/**
 @brief 开始检测FPS
 */
- (void)start;

/**
 @brief 停止检测FPS
 */
- (void)stop;

@end

NS_ASSUME_NONNULL_END
