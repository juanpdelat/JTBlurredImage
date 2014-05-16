JTBlurredImage
==============

Simple category that helps you create a blurred image iOS7-style based on another image or a view (e.g: myViewController.view).

#### Instructions
1. Copy the folder JTBlurredImage to your XCode project
2. Import the category in the parent View Controller, or where the original image you need to apply the blur effect is located, using ```#import "UIImage+BlurEffect.h"```
3. Create a new ```UImage``` with ```UIImage *backgroundBlurredImage = [UIImage getBlurredScreenshotFromView:self.view size:[[UIScreen mainScreen] bounds].size blurffect:BlurEffect];``` and pass this image to the presenting View Controller 
5. Apply the blurred image to the view controller background with ```self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:_blurredBackgroundImage];```

#### Requirements
iOS 7 is required for the blurred effects to work.

#### Options
It comes with 4 pre-defined blurred effects but you could play with the values to get some different effects.
* BlurEffect
* BlurEffectLight
* BlurEffectExtraLight
* BlurEffectDark

#### License 
Released under the terms of the MIT license.

Enjoy ☺