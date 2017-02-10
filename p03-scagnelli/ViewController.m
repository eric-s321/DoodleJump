//
//  ViewController.m
//  p03-scagnelli
//
//  Created by Eric Scagnelli on 2/9/17.
//  Copyright © 2017 escagne1. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize gameView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    displayLink = [CADisplayLink displayLinkWithTarget:gameView selector:@selector(update:)];
    [displayLink setPreferredFramesPerSecond:50];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)changeTilt:(id)sender{
    
    UISlider *slider = sender;
    [gameView setTilt:(double)[slider value]];
    
}


@end
