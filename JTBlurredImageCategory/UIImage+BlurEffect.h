//
//  UIImage+BlurEffect.h
//
//  Created by Juan de la Torre on 2014-05-16.
//  Copyright (c) 2014 juandelatorre. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
  BlurEffect,
  BlurEffectLight,
  BlurEffectExtraLight,
  BlurEffectDark,
} BlurEffectType;

@interface UIImage (BlurEffect)

+ (UIImage *)getBlurredScreenshotFromView:(UIView *)view size:(CGSize)size blurffect:(BlurEffectType)effect;
+ (UIImage *)getBlurredScreenshotFromImage:(UIImage *)image blurffect:(BlurEffectType)effect;

- (UIImage *)applyEffect;
- (UIImage *)applyLightEffect;
- (UIImage *)applyExtraLightEffect;
- (UIImage *)applyDarkEffect;

- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;

@end
