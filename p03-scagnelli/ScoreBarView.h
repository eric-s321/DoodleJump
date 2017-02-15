//
//  ScoreBar.h
//  p03-scagnelli
//
//  Created by Eric Scagnelli on 2/14/17.
//  Copyright © 2017 escagne1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScoreBarView : UIView{
    int scoreInt;
}

@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;

-(void) incrementScore;

@end
