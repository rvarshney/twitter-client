//
//  NewTweetVC.m
//  twitter
//
//  Created by Ruchi Varshney on 1/30/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "UIImageView+AFNetworking.h"
#import "Toast+UIView.h"

#import "NewTweetVC.h"
#import "User.h"
#import "TwitterClient.h"
#import "Tweet.h"

@interface NewTweetVC ()
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;
@property (weak, nonatomic) IBOutlet UIImageView *currentUserProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *currentUserNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentUserScreenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *charCounterLabel;

- (void)onCancelButton;
- (void)onTweetButton;

@end

@implementation NewTweetVC

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

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButton)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Tweet" style:UIBarButtonItemStylePlain target:self action:@selector(onTweetButton)];

    self.currentUserNameLabel.text = [User currentUser].name;
    self.currentUserScreenNameLabel.text = [User currentUser].screenName;

    [self.currentUserProfileImage setImageWithURL:[NSURL URLWithString:[User currentUser].profileImageUrl]];
    self.currentUserProfileImage.layer.cornerRadius = 5.0;
    self.currentUserProfileImage.layer.masksToBounds = YES;

    self.tweetTextView.delegate = self;
    self.tweetTextView.text = self.startTweetText;
    [self.tweetTextView becomeFirstResponder];

    self.charCounterLabel.text = [NSString stringWithFormat:@"%d", (140 - self.tweetTextView.text.length)];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Private methods

- (void)onCancelButton
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onTweetButton
{
    Tweet *tweet = [[Tweet alloc] initWithDictionary:[[NSMutableDictionary alloc] init]];
    tweet.text = self.tweetTextView.text;
    tweet.createDate = [NSDate date];
    tweet.retweetCount = [NSNumber numberWithInt:0];
    tweet.retweeted = [NSNumber numberWithBool:NO];
    tweet.favoriteCount = [NSNumber numberWithInt:0];
    tweet.favorited = [NSNumber numberWithBool:NO];
    tweet.author = [User currentUser];

    // Actually post the tweet to Twitter
    [[TwitterClient instance] updateStatusWithText:tweet.text replyStatusId:self.replyStatusId success:^(AFHTTPRequestOperation *operation, id response) {
        tweet.identifier = [((NSDictionary *)response) valueForKey:@"id_str"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.navigationController.view makeToast:@"Failed to post tweet" duration:2.0 position:@"top"];
    }];

    [self.delegate didFinishTweeting:tweet];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Text view delegate

- (void)textViewDidChange:(UITextView *)textView
{
    NSUInteger charCount = textView.text.length;
    if (charCount > 140) {
        self.charCounterLabel.textColor = [UIColor redColor];
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    } else if (charCount == 0) {
        self.charCounterLabel.textColor = [UIColor blackColor];
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    } else {
        self.charCounterLabel.textColor = [UIColor blackColor];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
    self.charCounterLabel.text = [NSString stringWithFormat:@"%d", (140 - textView.text.length)];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

@end
