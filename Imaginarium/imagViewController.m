//
//  imagViewController.m
//  Imaginarium
//
//  Created by Kai Ren on 12/22/13.
//  Copyright (c) 2013 Kai Ren. All rights reserved.
//

#import "imagViewController.h"

@interface imagViewController () <UIScrollViewDelegate>
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UIImage *image;
@property (weak, nonatomic) IBOutlet UIScrollView *scroll;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@end

@implementation imagViewController

#pragma mark - View Controller Lifecycle

// add the UIImageView to the MVC's View

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scroll addSubview:self.imageView];
}

#pragma mark - Properties

// lazy instantiation

- (UIImageView *)imageView
{
    if (!_imageView) _imageView = [[UIImageView alloc] init];
    return _imageView;
}

// image property does not use an _image instance variable
// instead it just reports/sets the image in the imageView property
// thus we don't need @synthesize even though we implement both setter and getter

- (UIImage *)image
{
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image; // does not change the frame of the UIImageView
    [self.imageView sizeToFit];   // update the frame of the UIImageView
    
    // self.scrollView could be nil on the next line if outlet-setting has not happened yet
    self.scroll.contentSize = self.image ? self.image.size : CGSizeZero;
    
    [self.spinner stopAnimating];
}

- (void)setScrollView:(UIScrollView *)scroll
{
    _scroll = scroll;
    
    // next three lines are necessary for zooming
    _scroll.minimumZoomScale = 0.2;
    _scroll.maximumZoomScale = 2.0;
    _scroll.delegate = self;
    
    // next line is necessary in case self.image gets set before self.scrollView does
    // for example, prepareForSegue:sender: is called before outlet-setting phase
    self.scroll.contentSize = self.image ? self.image.size : CGSizeZero;
}

#pragma mark - UIScrollViewDelegate

// mandatory zooming method in UIScrollViewDelegate protocol

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

#pragma mark - Setting the Image from the Image's URL

- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    //    self.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.imageURL]]; // blocks main queue!
    [self startDownloadingImage];
}

- (void)startDownloadingImage
{
    self.image = nil;
    
    if (self.imageURL)
    {
        [self.spinner startAnimating];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:self.imageURL];
        
        // another configuration option is backgroundSessionConfiguration (multitasking API required though)
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        
        // create the session without specifying a queue to run completion handler on (thus, not main queue)
        // we also don't specify a delegate (since completion handler is all we need)
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                        completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
                                                            // this handler is not executing on the main queue, so we can't do UI directly here
                                                            if (!error) {
                                                                if ([request.URL isEqual:self.imageURL]) {
                                                                    // UIImage is an exception to the "can't do UI here"
                                                                    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:localfile]];
                                                                    // but calling "self.image =" is definitely not an exception to that!
                                                                    // so we must dispatch this back to the main queue
                                                                    dispatch_async(dispatch_get_main_queue(), ^{ self.image = image; });
                                                                }
                                                            }
                                                        }];
        [task resume]; // don't forget that all NSURLSession tasks start out suspended!
    }
}


@end
