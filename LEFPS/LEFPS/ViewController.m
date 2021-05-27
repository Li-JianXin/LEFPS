//
//  ViewController.m
//  LEFPS
//
//  Created by 李建新 on 2021/5/27.
//

#import "ViewController.h"
#import "LERunLoopFPS.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initFPS];
}

- (void)initFPS {
    LERunLoopFPS *fps = [LERunLoopFPS shared];
    [fps setMonitor:^(u_int8_t fps) {
        NSLog(@"current fps:%d", fps);
    }];
    [fps start];
}

@end
