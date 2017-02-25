//
//  HighScoreViewController.h
//  p03-scagnelli
//
//  Created by Eric Scagnelli on 2/19/17.
//  Copyright © 2017 escagne1. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "Universe.h"
#import "HighScore.h"

@interface HighScoreViewController : UIViewController{
    NSMutableArray *highScores;
}

@property (strong, nonatomic) IBOutlet UITextView *textView;

@end

