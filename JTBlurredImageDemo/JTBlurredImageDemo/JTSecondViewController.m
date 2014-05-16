//
//  JTSecondViewController.m
//  JTBlurredImageDemo
//
//  Created by Juan de la Torre on 2014-05-16.
//  Copyright (c) 2014 juandelatorre. All rights reserved.
//

#import "JTSecondViewController.h"

@interface JTSecondViewController ()

@end

@implementation JTSecondViewController

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
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:_blurredBackgroundImage];
}

- (IBAction)dismissButtonPressed:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}


@end
