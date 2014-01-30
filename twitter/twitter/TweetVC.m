//
//  TweetVC.m
//  twitter
//
//  Created by Ruchi Varshney on 1/30/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "UIImageView+AFNetworking.h"
#import "Toast+UIView.h"

#import "TweetVC.h"
#import "Tweet.h"
#import "NewTweetVC.h"
#import "TwitterClient.h"

@interface TweetVC ()

@property (weak, nonatomic) IBOutlet UIImageView *authorProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *authorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorScreenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdAtLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *favoriteCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;

@property (strong, nonatomic) Tweet *retweet;

- (IBAction)onReplyButton:(id)sender;
- (IBAction)onRetweetButton:(id)sender;
- (IBAction)onFavoriteButton:(id)sender;

@end

@implementation TweetVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reply" style:UIBarButtonItemStylePlain target:self action:@selector(onReplyButton:)];
    self.title = @"Tweet";

    [self.authorProfileImage setImageWithURL:[NSURL URLWithString:self.tweet.author.profileImageUrl]];
    self.authorProfileImage.layer.cornerRadius = 5.0;
    self.authorProfileImage.layer.masksToBounds = YES;

    self.authorNameLabel.text = self.tweet.author.name;
    self.authorScreenNameLabel.text = [NSString stringWithFormat:@"@%@", self.tweet.author.screenName];
    self.tweetTextLabel.text = self.tweet.text;
    self.createdAtLabel.text = self.tweet.createdAt;

    // These need to be localized to handle singular
    self.retweetCountLabel.text = [NSString stringWithFormat:@"%@ RETWEETS", self.tweet.retweetCount];
    self.favoriteCountLabel.text = [NSString stringWithFormat:@"%@ FAVORITES", self.tweet.favoriteCount];

    if (self.tweet.favorited == [NSNumber numberWithBool:YES]) {
        [self.favoriteButton setImage:[UIImage imageNamed:@"glyphicons_favorited.png"] forState:UIControlStateNormal];
        [self.favoriteButton setAlpha:1.0];
    } else {
        [self.favoriteButton setImage:[UIImage imageNamed:@"glyphicons_unfavorited.png"] forState:UIControlStateNormal];
        [self.favoriteButton setAlpha:0.5];
    }

    if (self.tweet.retweeted == [NSNumber numberWithBool:YES]) {
        [self.retweetButton setImage:[UIImage imageNamed:@"glyphicons_retweeted.png"] forState:UIControlStateNormal];
        [self.retweetButton setAlpha:1.0];
    } else {
        [self.retweetButton setImage:[UIImage imageNamed:@"glyphicons_unretweeted.png"] forState:UIControlStateNormal];
        [self.retweetButton setAlpha:0.5];
    }

    // The user cannot retweet their own tweet
    if ([self.tweet.author.screenName isEqualToString:[User currentUser].screenName]) {
        [self.retweetButton setHidden:YES];
    }

    [self.replyButton setImage:[UIImage imageNamed:@"glyphicons_replied.png"] forState:UIControlStateNormal];
    [self.replyButton setAlpha:0.5];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Private methods

- (IBAction)onReplyButton:(id)sender;
{
    NSLog(@"Reply Button");
    NewTweetVC *newTweetVC = [[NewTweetVC alloc] init];
    newTweetVC.delegate = self;
    newTweetVC.startTweetText = [NSString stringWithFormat:@"@%@ ", self.tweet.author.screenName];
    newTweetVC.replyStatusId = self.tweet.identifier;
    UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:newTweetVC];
    [self presentViewController:navC animated:YES completion:nil];
}

- (void) didFinishTweeting:(Tweet *)tweet
{
    [self.delegate didFinishReplying:tweet];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)onRetweetButton:(id)sender
{
    NSLog(@"Retweet Button");
    if (self.tweet.retweeted == [NSNumber numberWithBool:NO]) {
        self.tweet.retweetCount = [NSNumber numberWithInt:[self.tweet.retweetCount intValue] + 1];
        self.tweet.retweeted = [NSNumber numberWithBool:YES];
        [[TwitterClient instance] retweetStatus:self.tweet.identifier success:^(AFHTTPRequestOperation *operation, id response) {
            self.retweet = [[Tweet alloc] initWithDictionary:response];
        } failure:nil];
        [self.retweetButton setImage:[UIImage imageNamed:@"glyphicons_retweeted.png"] forState:UIControlStateNormal];
        [self.retweetButton setAlpha:1.0];
    } else {
        self.tweet.retweetCount = [NSNumber numberWithInt:[self.tweet.retweetCount intValue] - 1];
        self.tweet.retweeted = [NSNumber numberWithBool:NO];
        [[TwitterClient instance] destroyStatus:self.retweet.identifier success:nil failure:nil];
        self.retweet = nil;
        [self.retweetButton setImage:[UIImage imageNamed:@"glyphicons_unretweeted.png"] forState:UIControlStateNormal];
        [self.retweetButton setAlpha:0.5];
    }

    self.retweetCountLabel.text = [NSString stringWithFormat:@"%@ RETWEETS", self.tweet.retweetCount];
}

- (IBAction)onFavoriteButton:(id)sender
{
    NSLog(@"Favorite Button");
    if (self.tweet.favorited == [NSNumber numberWithBool:NO]) {
        self.tweet.favoriteCount = [NSNumber numberWithInt:[self.tweet.favoriteCount intValue] + 1];
        self.tweet.favorited = [NSNumber numberWithBool:YES];
        [[TwitterClient instance] favoriteStatus:self.tweet.identifier success:nil failure:nil];
        [self.favoriteButton setImage:[UIImage imageNamed:@"glyphicons_favorited.png"] forState:UIControlStateNormal];
        [self.favoriteButton setAlpha:1.0];
    } else {
        self.tweet.favoriteCount = [NSNumber numberWithInt:[self.tweet.favoriteCount intValue] - 1];
        self.tweet.favorited = [NSNumber numberWithBool:NO];
        [[TwitterClient instance] unfavoriteStatus:self.tweet.identifier success:nil failure:nil];
        [self.favoriteButton setImage:[UIImage imageNamed:@"glyphicons_unfavorited.png"] forState:UIControlStateNormal];
        [self.favoriteButton setAlpha:0.5];
    }
    self.favoriteCountLabel.text = [NSString stringWithFormat:@"%@ FAVORITES", self.tweet.favoriteCount];
}

@end
