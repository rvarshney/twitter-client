//
//  NewTweetVC.h
//  twitter
//
//  Created by Ruchi Varshney on 1/30/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NewTweetVCDelegate <NSObject>

- (void)didFinishTweeting:(Tweet *)tweet;

@end

@interface NewTweetVC : UIViewController <UITextViewDelegate>

@property (nonatomic, strong) NSString *startTweetText;
@property (nonatomic, strong) NSString *replyStatusId;
@property (nonatomic, weak) id <NewTweetVCDelegate> delegate;

@end
