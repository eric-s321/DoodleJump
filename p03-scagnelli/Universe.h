//
//  Universe.h
//  p03-scagnelli
//
//  Created by Eric Scagnelli on 2/17/17.
//  Copyright © 2017 escagne1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Universe : NSObject

@property (nonatomic) int currentScore;

+(Universe *)sharedInstance;

@end
