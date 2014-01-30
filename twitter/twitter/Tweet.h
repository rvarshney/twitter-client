//
//  Tweet.h
//  twitter
//
//  Created by Timothy Lee on 8/5/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tweet : RestObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *createdAt;
@property (nonatomic, strong) NSString *createdAgo;
@property (nonatomic, strong) NSDate * createDate;
@property (nonatomic, strong) User *author;
@property (nonatomic, strong) User *retweetAuthor;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSNumber *retweetCount;
@property (nonatomic, strong) NSNumber *retweeted;
@property (nonatomic, strong) NSNumber *favoriteCount;
@property (nonatomic, strong) NSNumber *favorited;

+ (NSMutableArray *)tweetsWithArray:(NSArray *)array;

@end
