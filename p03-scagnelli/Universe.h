//
//  Universe.h
//  p03-scagnelli
//
//  Created by Eric Scagnelli on 2/17/17.
//  Copyright © 2017 escagne1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface Universe : NSObject{
    AVAudioPlayer *audioPlayer;
}

@property (nonatomic) int currentScore;

+(Universe *)sharedInstance;

-(void)setAVPlayer:(AVAudioPlayer *) player;
-(AVAudioPlayer *)getAVPlayer;
-(void)save;
-(void)load;

@end
