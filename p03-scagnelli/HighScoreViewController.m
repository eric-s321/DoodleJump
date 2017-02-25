//
//  HighScoreViewController.m
//  p03-scagnelli
//
//  Created by Eric Scagnelli on 2/19/17.
//  Copyright © 2017 escagne1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HighScoreViewController.h"

@implementation HighScoreViewController
@synthesize textView;

-(void)viewDidLoad{
    [super viewDidLoad];
   
    highScores = [[Universe sharedInstance] getHighScores];
    
    HighScore *newScore = highScores[[highScores count] - 1];  //Newest score is appended to the array
    
    NSArray *sortedHighScores = [highScores sortedArrayUsingComparator:
                                        ^NSComparisonResult (HighScore *a, HighScore *b){
                                            int score1 = [a score];
                                            int score2 = [b score];
                                            return score1 < score2;
                                        }];
    
    NSLog(@"Newest score is %@", newScore);
    NSLog(@"Printing the sorted array...");
    for (HighScore *highScore in sortedHighScores){
        NSLog(@"%@", highScore);
    }
    
//    [textView setBackgroundColor:[UIColor clearColor]];
    
    textView.editable = NO;
    
    NSMutableAttributedString *highScoreInfo = [[NSMutableAttributedString alloc] initWithString:@""];
    int place = 1;
    for (HighScore *highScore in sortedHighScores){
        
        if([highScore isEqual:newScore]){
            NSMutableAttributedString *scoreRow = [[NSMutableAttributedString alloc]
                     initWithString:[[NSString stringWithFormat:@"%d. %@:",place, [highScore name]]
                            stringByPaddingToLength:20 withString:@" " startingAtIndex:0]];
            
            [scoreRow addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Super Mario 256"
                                size:20] range:NSMakeRange(0, [scoreRow length])];
            
            [scoreRow addAttribute:NSStrokeColorAttributeName value:[UIColor yellowColor]
                    range:NSMakeRange(0, [scoreRow length])];
            
            NSMutableAttributedString *scoreNum = [[NSMutableAttributedString alloc]
                            initWithString:[NSString stringWithFormat:@"%d\n", [highScore score]]];
            
            [scoreNum addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Super Mario 256"
                                size:20] range:NSMakeRange(0, [scoreNum length])];
            
            [scoreNum addAttribute:NSStrokeColorAttributeName value:[UIColor yellowColor]
                    range:NSMakeRange(0, [scoreNum length])];
            
            [scoreRow appendAttributedString:scoreNum];
            [highScoreInfo appendAttributedString:scoreRow];
        }
        else{
            NSMutableAttributedString *scoreRow = [[NSMutableAttributedString alloc]
                     initWithString:[[NSString stringWithFormat:@"%d. %@:",place, [highScore name]]
                            stringByPaddingToLength:20 withString:@" " startingAtIndex:0]];
            
            [scoreRow addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Super Mario 256"
                                size:20] range:NSMakeRange(0, [scoreRow length])];
            
            [scoreRow addAttribute:NSStrokeColorAttributeName value:[UIColor whiteColor]
                    range:NSMakeRange(0, [scoreRow length])];
            
            NSMutableAttributedString *scoreNum = [[NSMutableAttributedString alloc]
                            initWithString:[NSString stringWithFormat:@"%d\n", [highScore score]]];
            
            [scoreNum addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Super Mario 256"
                                size:20] range:NSMakeRange(0, [scoreNum length])];
            
            [scoreNum addAttribute:NSStrokeColorAttributeName value:[UIColor whiteColor]
                    range:NSMakeRange(0, [scoreNum length])];
            
            
            [scoreRow appendAttributedString:scoreNum];
            [highScoreInfo appendAttributedString:scoreRow];
        }
        
        /*
        NSString *nameColumn = [[NSString stringWithFormat:@"%d. %@:",place, [highScore name]] stringByPaddingToLength:20
                                              withString:@" " startingAtIndex:0];
        
        textView.text = [textView.text stringByAppendingString:
                         [NSString stringWithFormat:@"%@%d\n", nameColumn, [highScore score]]];
        NSLog(@"Just appended\n%@",
                         [NSString stringWithFormat:@"%@%d\n", nameColumn, [highScore score]]);
//                          [NSString stringWithFormat:@"%d. %@\n", place, highScore]];
         */
        place++;
    }
    
//    textView.attributedText = highScoreInfo;
    
    [textView setAttributedText:highScoreInfo];
//    [textView scrollRangeToVisible:NSMakeRange(0, 0)];
    
    NSLog(@"Printing the attributed text...");
    NSLog(@"%@", highScoreInfo);
    
    NSString *text = textView.text;
    NSAttributedString *attrStr = textView.attributedText;
    
    NSLog(@"Regular text was...\n%@", text);
    NSLog(@"Attributed text was...\n%@", attrStr);
}

@end
