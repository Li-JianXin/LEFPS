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

- (instancetype)init {
    if (self = [super init]) {
        _refreshStartTime = YES;
        _loopCount = 0;
        _frame = 1.f / 60.f;
        _lose = 0;
        _fpsStartTime = CFAbsoluteTimeGetCurrent();
    }
    return self;
}

#pragma mark - Public Methods
- (void)setMonitor:(LERunLoopFPSMonitor)monitor {
    _monitor = monitor;
}

- (void)start {
    [self _timerStart];
    [self _monitorStart];
}

- (void)stop {
    [self _timerStop];
    [self _monitorStop];
}

#pragma mark - Event Response
- (void)timerAction:(NSTimer *)timer {
    [self _translation];
}

#pragma mark - Private Methods
- (void)_timerStart {
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

- (void)_timerStop {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)_translation {
    _loopCount++;
    NSTimeInterval loopEndTime = CFAbsoluteTimeGetCurrent();
    NSTimeInterval interval = loopEndTime - _fpsStartTime;
    
    if (interval >= 1) {
        loopEndTime = _fpsStartTime + 1;
    }
    
    NSTimeInterval loopInterval = loopEndTime - _loopStartTime;
    _lose += loopInterval / _frame;
    
    if (interval >= 1) {
        _refreshStartTime = YES;
        // 1s内loop次数
        int fps1 = _loopCount / interval + 0.5f;
        // 1s内超过16.67ms的次数
        int fps2 = 60 - _lose;
        
        if (fps1 >= 60) {
            _fps = fps2;
        } else {
            _fps = MAX(fps1, fps2);
        }
        
        if (_monitor) {
            _monitor(_fps);
        }
    }
}

- (void)_monitorStart {
    if (!_sleepObserver) {
        _sleepObserver = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopBeforeWaiting, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
            [self _translation];
        });
        // 修改监听优先级
        _wakeupObserver = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAfterWaiting, YES, NSUIntegerMax, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
            if (_refreshStartTime) {
                _refreshStartTime = NO;
                _loopCount = 0;
                _lose = 0;
                _fpsStartTime = CFAbsoluteTimeGetCurrent();
            }
            _loopStartTime = CFAbsoluteTimeGetCurrent();
        });
        
        CFRunLoopAddObserver(CFRunLoopGetMain(), _sleepObserver, kCFRunLoopCommonModes);
        CFRunLoopAddObserver(CFRunLoopGetMain(), _wakeupObserver, kCFRunLoopCommonModes);
    }
}

- (void)_monitorStop {
    if (_sleepObserver) {
        CFRunLoopRemoveObserver(CFRunLoopGetMain(), _sleepObserver, kCFRunLoopCommonModes);
        CFRunLoopRemoveObserver(CFRunLoopGetMain(), _wakeupObserver, kCFRunLoopCommonModes);
        
        _sleepObserver = NULL;
        _wakeupObserver = NULL;
    }
}

#pragma mark - Get
- (u_int8_t)fps {
    return _fps;
}

@end
