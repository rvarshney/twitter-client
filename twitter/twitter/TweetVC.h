//
//  TweetVC.h
//  twitter
//
//  Created by Ruchi Varshney on 1/30/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"
#import "NewTweetVC.h"

@protocol TweetVCDelegate <NSObject>

- (void)didFinishReplying:(Tweet *)tweet;

@end

@interface TweetVC : UIViewController <NewTweetVCDelegate>

@property (nonatomic, strong) Tweet *tweet;
@property (nonatomic, weak) id <TweetVCDelegate> delegate;

@end
