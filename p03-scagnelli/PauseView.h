//
//  PauseView.h
//  p03-scagnelli
//
//  Created by Eric Scagnelli on 2/17/17.
//  Copyright © 2017 escagne1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Universe.h"

@interface PauseView : UIView{
    AVAudioPlayer *audioPlayer;
}

-(IBAction)stopMusic;

@end
