//
//  HighScore.m
//  p03-scagnelli
//
//  Created by Eric Scagnelli on 2/18/17.
//  Copyright © 2017 escagne1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HighScore.h"

@implementation HighScore
@synthesize name, score;

-(id) initWithCoder:(NSCoder *)aDecoder{
    
    self = [self init];
    
    if (self) {
        name = [aDecoder decodeObjectForKey:@"name"];
        score = [aDecoder decodeIntForKey:@"score"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:name forKey:@"name"];
    [encoder encodeInt:score forKey:@"score"];
}

- (NSString *)description{
    NSString *nameColumn = [[NSString stringWithFormat:@"%@:", name] stringByPaddingToLength:20
                                              withString:@" " startingAtIndex:0];
    return [NSString stringWithFormat:@"%@%d", nameColumn, score];

//    return [NSString stringWithFormat:@"%@\t%d", self.name, self.score];
}

-(BOOL)isEqual:(HighScore *) otherScore{
    return [name isEqualToString:otherScore.name] && score == otherScore.score;
}

@end
