//
//  HighScore.h
//  p03-scagnelli
//
//  Created by Eric Scagnelli on 2/18/17.
//  Copyright © 2017 escagne1. All rights reserved.
//


@interface HighScore : NSObject <NSCoding>

@property (strong, nonatomic) NSString *name;
@property (nonatomic) int score;

@end
