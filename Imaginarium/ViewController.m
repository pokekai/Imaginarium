//
//  ViewController.m
//  Imaginarium
//
//  Created by Kai Ren on 12/22/13.
//  Copyright (c) 2013 Kai Ren. All rights reserved.
//

#import "ViewController.h"
#import "imagViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[imagViewController class]]) {
        imagViewController *ivc = (imagViewController *)segue.destinationViewController;
        ivc.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://images.apple.com/v/iphone-5s/gallery/a/images/download/%@.jpg", segue.identifier]];
        ivc.title = segue.identifier;
    }
}

@end
