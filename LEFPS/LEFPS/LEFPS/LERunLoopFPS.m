//
//  LERunLoopFPS.m
//  LEFPS
//
//  Created by 李建新 on 2021/5/27.
//

#import "LERunLoopFPS.h"

@implementation LERunLoopFPS {
    LERunLoopFPSMonitor _monitor;
    
    // 定时器，避免由于主线程长时间休眠导致帧数收集异常
    NSTimer *_timer;
    
    // 本次帧数收集的开始时间
    NSTimeInterval _fpsStartTime;
    // 本次loop开始时间
    NSTimeInterval _loopStartTime;
    
    // 帧
    NSTimeInterval _frame;
    // 帧数
    u_int64_t _loopCount;
    // 丢帧数
    u_int32_t _lose;
    // 帧率
    u_int8_t _fps;
    
    // 是否刷新帧数收集的开始时间
    BOOL _refreshStartTime;
    
    // 监听MainRunLoop进入休眠前的状态
    CFRunLoopObserverRef _sleepObserver;
    // 监听MainRunLoop进入即将唤醒的状态
    CFRunLoopObserverRef _wakeupObserver;
}

+ (instancetype)shared {
    static LERunLoopFPS *fps;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        fps = [LERunLoopFPS new];
    });
    return fps;
}

@end
