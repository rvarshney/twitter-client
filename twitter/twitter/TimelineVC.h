//
//  TimelineVC.h
//  twitter
//
//  Created by Timothy Lee on 8/4/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewTweetVC.h"
#import "TweetVC.h"

@interface TimelineVC : UITableViewController <NewTweetVCDelegate, TweetVCDelegate>

@end
