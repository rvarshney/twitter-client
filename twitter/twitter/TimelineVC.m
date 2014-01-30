//
//  TimelineVC.m
//  twitter
//
//  Created by Timothy Lee on 8/4/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "UIImageView+AFNetworking.h"
#import "Toast+UIView.h"

#import "TimelineVC.h"
#import "TweetVC.h"
#import "NewTweetVC.h"
#import "TweetCell.h"

@interface TimelineVC ()

@property (nonatomic, strong) NSMutableArray *tweets;
@property BOOL loadingTweets;

- (void)onSignOutButton;
- (void)onNewButton;

- (void)loadNewerTweets;
- (void)loadOlderTweets;

@end

@implementation TimelineVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Twitter";
        
        [self loadNewerTweets];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:@"TweetCell"];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sign Out" style:UIBarButtonItemStylePlain target:self action:@selector(onSignOutButton)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Compose" style:UIBarButtonItemStylePlain target:self action:@selector(onNewButton)];

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(loadNewerTweets) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;

    UIColor *twitterBlue = [UIColor colorWithRed:0.251 green:0.6 blue:1 alpha:1.0];
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
        self.navigationController.navigationBar.barTintColor = twitterBlue;
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    } else {
        self.navigationController.navigationBar.tintColor = twitterBlue;
    }
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TweetCell";
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    Tweet *tweet = self.tweets[indexPath.row];
    cell.tweetText.text = tweet.text;
    cell.dateLabel.text = tweet.createdAgo;

    NSRange boldedRange = NSMakeRange(0, tweet.author.name.length);
    NSString *authorString = [NSString stringWithFormat:@"%@ @%@", tweet.author.name, tweet.author.screenName];
    UIFont *boldFont = [UIFont boldSystemFontOfSize:12];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:authorString];
    [attrString addAttribute:NSFontAttributeName value:boldFont range:boldedRange];
    [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:boldedRange];
    cell.authorNameLabel.attributedText = attrString;

    [cell.authorProfileImage setImageWithURL:[NSURL URLWithString:tweet.author.profileImageUrl]];
    cell.authorProfileImage.layer.cornerRadius = 5.0f;
    cell.authorProfileImage.layer.masksToBounds = YES;

    if (tweet.retweetAuthor) {
        cell.retweetAuthorLabel.text = [NSString stringWithFormat:@"@%@ retweeted", tweet.retweetAuthor.screenName];
        cell.retweetAuthorHeightConstraint.constant = 14.0f;
    } else {
        cell.retweetAuthorLabel.text = @"";
        cell.retweetAuthorHeightConstraint.constant = 0.0f;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat margin = 15.0f;
    CGFloat authorStringHeight = 16.0f;
    CGFloat imageHeight = 48.0f;

    Tweet *tweet = self.tweets[indexPath.row];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:12.0], NSFontAttributeName, nil];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:tweet.text attributes:attributes];

    CGSize constraint = CGSizeMake(234.0f - 8.0f, CGFLOAT_MAX);
    CGSize size = [attributedString boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil].size;

    CGFloat totalTextHeight = margin * 2 + authorStringHeight + 4.0f + size.height;
    CGFloat totalImageHeight = margin * 2 + imageHeight;
    if (tweet.retweetAuthor) {
        totalImageHeight += 14.0f;
        totalTextHeight += 14.0f;
    }

    return MAX(totalTextHeight, totalImageHeight);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat contentOffset = scrollView.contentOffset.y;
    CGFloat contentHeight = scrollView.contentSize.height;
    CGFloat scrollViewHeight = scrollView.bounds.size.height;

    CGFloat distanceToBottom = contentHeight - contentOffset - scrollViewHeight;
    if (distanceToBottom <= 100.0f && contentHeight != 0 && self.loadingTweets == NO) {
        [self loadOlderTweets];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    Tweet *selectedTweet = self.tweets[indexPath.row];
    TweetVC *tweetVC = [[TweetVC alloc] init];
    tweetVC.delegate = self;
    tweetVC.tweet = selectedTweet;

    [self.navigationController pushViewController:tweetVC animated:YES];
}

#pragma mark - Private methods

- (void)onSignOutButton
{
    [User setCurrentUser:nil];
}

- (void)onNewButton
{
    NSLog(@"New Button");
    NewTweetVC *newTweetVC = [[NewTweetVC alloc] init];
    newTweetVC.startTweetText = @"";
    newTweetVC.replyStatusId = @"0";
    newTweetVC.delegate = self;
    UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:newTweetVC];
    [self presentViewController:navC animated:YES completion:nil];
}

- (void)didFinishTweeting:(Tweet *)tweet
{
    NSLog(@"Did finish tweeting %@", tweet.text);
    [self addNewTweetToTimeline:tweet];
}

- (void)didFinishReplying:(Tweet *)tweet
{
    NSLog(@"Did finish replying %@", tweet.text);
    [self addNewTweetToTimeline:tweet];
}

- (void)addNewTweetToTimeline:(Tweet *)tweet
{
    NSMutableArray *tweetArray = [[NSMutableArray alloc] initWithObjects:tweet, nil];
    [tweetArray addObjectsFromArray:self.tweets];
    self.tweets = tweetArray;
    [self.tableView reloadData];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

- (void)loadNewerTweets
{
    self.loadingTweets = YES;
    NSString *sinceId = self.tweets.count > 0 ? ((Tweet *)[self.tweets firstObject]).identifier : @"0";
    [[TwitterClient instance] homeTimelineWithCount:20 sinceId:sinceId maxId:@"0" success:^(AFHTTPRequestOperation *operation, id response) {
        NSMutableArray *tweetsArray = [Tweet tweetsWithArray:response];
        [tweetsArray addObjectsFromArray:self.tweets];
        self.tweets = tweetsArray;
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
        self.loadingTweets = NO;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.navigationController.view makeToast:@"Network error" duration:2.0 position:@"top"];
        [self.refreshControl endRefreshing];
        self.loadingTweets = NO;
    }];
}

- (void)loadOlderTweets
{
    self.loadingTweets = YES;
    NSString *maxId = self.tweets.count > 0 ? ((Tweet *)[self.tweets lastObject]).identifier : @"0";
    [[TwitterClient instance] homeTimelineWithCount:20 sinceId:@"0" maxId:maxId success:^(AFHTTPRequestOperation *operation, id response) {
        [self.tweets addObjectsFromArray:[Tweet tweetsWithArray:response]];
        [self.tableView reloadData];
        self.loadingTweets = NO;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.navigationController.view makeToast:@"Network error" duration:2.0 position:@"top"];
        self.loadingTweets = NO;
    }];
}

@end
