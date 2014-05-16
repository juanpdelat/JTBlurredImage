//
//  JTViewController.m
//  JTBlurredImageDemo
//
//  Created by Juan de la Torre on 2014-05-16.
//  Copyright (c) 2014 juandelatorre. All rights reserved.
//

#import "JTViewController.h"
#import "UIImage+BlurEffect.h"
#import "JTSecondViewController.h"

@interface JTViewController () <UIViewControllerTransitioningDelegate>

@end

@implementation JTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  UIImage *backgroundBlurredImage;
  switch (((UIButton*)sender).tag) {
    case BlurEffect:
      backgroundBlurredImage = [UIImage getBlurredScreenshotFromView:self.view size:[[UIScreen mainScreen] bounds].size blurffect:BlurEffect];
      break;
      
    case BlurEffectLight:
      backgroundBlurredImage = [UIImage getBlurredScreenshotFromView:self.view size:[[UIScreen mainScreen] bounds].size blurffect:BlurEffectLight];
      break;
      
    case BlurEffectExtraLight:
      backgroundBlurredImage = [UIImage getBlurredScreenshotFromView:self.view size:[[UIScreen mainScreen] bounds].size blurffect:BlurEffectExtraLight];
      break;
      
    case BlurEffectDark:
      backgroundBlurredImage = [UIImage getBlurredScreenshotFromView:self.view size:[[UIScreen mainScreen] bounds].size blurffect:BlurEffectDark];
      break;
      
    default:
      break;
  }
  

  JTSecondViewController *vc = [segue destinationViewController];
  vc.blurredBackgroundImage = backgroundBlurredImage;
}

- (IBAction)buttonPressed:(UIButton *)sender {
  [self performSegueWithIdentifier: @"myModalSegue" sender:sender];
}


@end
