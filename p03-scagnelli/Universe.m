//
//  Universe.m
//  p03-scagnelli
//
//  Created by Eric Scagnelli on 2/17/17.
//  Copyright © 2017 escagne1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Universe.h"

@implementation Universe
@synthesize currentScore;

static Universe *singleton = nil;

-(id)init{
    
    if(singleton)
        return singleton;
    
    self = [super init];
    
    if(self){
        singleton = self;
        highScores = [[NSMutableArray alloc] init];
    }
    
    return self;
}
    
+(Universe *)sharedInstance{
    
    if(singleton)
        return singleton;
    
    return [[Universe alloc] init];
}
    
-(void)setAVPlayer:(AVAudioPlayer *) player{
    audioPlayer = player;
}

-(AVAudioPlayer *)getAVPlayer{
    
    if(audioPlayer)
        return audioPlayer;
    
    return [[AVAudioPlayer alloc] init];
}

-(void)save{
    NSLog(@"In save");
    
    NSArray *dirs = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
    NSError *err;
    [[NSFileManager defaultManager] createDirectoryAtURL:[dirs objectAtIndex:0] withIntermediateDirectories:YES attributes:nil error:&err];
    
    NSURL *url = [NSURL URLWithString:@"high_scores.archive" relativeToURL:[dirs objectAtIndex:0]];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
    for (HighScore *highScore in highScores){
        NSLog(@"Name: %@   Score: %d", highScore.name, highScore.score);
    }
    
    [archiver encodeObject:highScores forKey:@"highScores"];
    
    [archiver finishEncoding];
    [data writeToURL:url atomically:YES];
    
//    NSLog(@"Save the value %d for the counter", counter);
    
}

-(void)load{
    NSLog(@"In load");
    
    NSArray *dirs = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
    NSError *err;
    [[NSFileManager defaultManager] createDirectoryAtURL:[dirs objectAtIndex:0] withIntermediateDirectories:YES attributes:nil error:&err];
    NSURL *url = [NSURL URLWithString:@"high_scores.archive" relativeToURL:[dirs objectAtIndex:0]];
    
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    if (!data)
        return;
    
    NSKeyedUnarchiver *unarchiver;
    
    unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    highScores = [unarchiver decodeObjectForKey:@"highScores"];
    
    NSLog(@"Just loaded high scores:");
    for (HighScore *highScore in highScores){
        NSLog(@"Name: %@   Score: %d", highScore.name, highScore.score);
    }
    
}

-(void)addHighScore:(HighScore *) highScore{
    NSLog(@"Beginning of adding score");
    [self load];  //Load first so we dont overwrite old scores
    [highScores addObject:highScore];
    [self save];
    NSLog(@"End of adding score");
}

-(NSMutableArray *)getHighScores{
    return highScores;
}

@end
