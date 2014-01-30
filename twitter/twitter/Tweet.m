//
//  Tweet.m
//  twitter
//
//  Created by Timothy Lee on 8/5/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "Tweet.h"
#import "User.h"

@implementation Tweet

- (NSString *)identifier
{
    return [self.data valueOrNilForKeyPath:@"id_str"];
}

- (void)setIdentifier:(NSString *)identifier
{
    [self.data setValue:identifier forKey:@"id_str"];
}

- (NSDate *)createDate
{
    NSString *dateString = [self.data valueOrNilForKeyPath:@"created_at"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE LLL d HH:mm:ss Z yyyy"];
    return [dateFormatter dateFromString: dateString];
}

- (void)setCreateDate:(NSDate *)createDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE LLL d HH:mm:ss Z yyyy"];
    [self.data setObject:[dateFormatter stringFromDate:createDate] forKey:@"created_at"];
}

- (NSString *)createdAt
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    return [dateFormatter stringFromDate:self.createDate];
}

- (NSString *)createdAgo
{
    NSDate *currentDate = [NSDate date];
    NSTimeInterval distanceBetweenDates = [currentDate timeIntervalSinceDate:self.createDate];
    NSUInteger hoursBetweenDates = distanceBetweenDates / 3600;
    if (hoursBetweenDates == 0) {
        NSUInteger minutesBetweenDates = distanceBetweenDates / 60;
        if (minutesBetweenDates > 0) {
            return [NSString stringWithFormat:@"%dm", minutesBetweenDates];
        }
        return [NSString stringWithFormat:@"%ds", [[NSNumber numberWithFloat: distanceBetweenDates] integerValue]];
    } else if (hoursBetweenDates <= 24) {
        return [NSString stringWithFormat:@"%dh", hoursBetweenDates];
    } else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        return [dateFormatter stringFromDate:self.createDate];
    }
}

- (NSString *)text
{
    return [self.data valueOrNilForKeyPath:@"text"];
}

- (void)setText:(NSString *)text
{
    [self.data setValue:text forKey:@"text"];
}

- (NSNumber *)retweetCount
{
    return [self.data valueForKey:@"retweet_count"];
}

- (void)setRetweetCount:(NSNumber *)retweetCount
{
    [self.data setValue:retweetCount forKey:@"retweet_count"];
}

- (NSNumber *)retweeted
{
    return [self.data valueForKey:@"retweeted"];
}

- (void)setRetweeted:(NSNumber *)retweeted
{
    [self.data setValue:[NSNumber numberWithBool:[retweeted boolValue]] forKey:@"retweeted"];
}

- (NSNumber *)favoriteCount
{
    return [self.data valueForKey:@"favorite_count"];
}

- (void)setFavoriteCount:(NSNumber *)favoriteCount
{
    [self.data setValue:favoriteCount forKey:@"favorite_count"];
}

- (NSNumber *)favorited
{
    return [self.data valueForKey:@"favorited"];
}

- (void)setFavorited:(NSNumber *)favorited
{
    [self.data setValue:[NSNumber numberWithBool:[favorited boolValue]] forKey:@"favorited"];
}

- (User *)author
{
    return [[User alloc] initWithDictionary:[self.data valueOrNilForKeyPath:@"user"]];
}

- (void)setAuthor:(User *)author
{
    [self.data setObject:author.data forKey:@"user"];
}

- (User *)retweetAuthor
{
    NSDictionary *retweetAuthorData = [self.data valueOrNilForKeyPath:@"retweeted_by_user"];
    if (retweetAuthorData) {
        return [[User alloc] initWithDictionary:retweetAuthorData];
    }
    return nil;
}

- (id)initWithDictionary:(NSDictionary *)data
{
    NSDictionary *retweet = [data valueForKey:@"retweeted_status"];
    if (retweet) {
        NSMutableDictionary *retweetData = [NSMutableDictionary dictionaryWithDictionary:retweet];
        [retweetData setValue:data[@"user"] forKey:@"retweeted_by_user"];
        return [super initWithDictionary:retweetData];
    }
    return [super initWithDictionary:data];
}

+ (NSMutableArray *)tweetsWithArray:(NSArray *)array
{
    NSMutableArray *tweets = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (NSDictionary *params in array) {
        [tweets addObject:[[Tweet alloc] initWithDictionary:params]];
    }
    return tweets;
}

@end
