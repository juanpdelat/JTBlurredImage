//
//  UIImage+BlurEffect.m
//
//  Created by Juan de la Torre on 2014-05-16.
//  Copyright (c) 2014 juandelatorre. All rights reserved.
//

#import "UIImage+BlurEffect.h"
#import <Accelerate/Accelerate.h>
#import <float.h>

@implementation UIImage (BlurEffect)

+ (UIImage *)getBlurredScreenshotFromView:(UIView *)view size:(CGSize)size blurffect:(BlurEffectType)effect
{
  UIGraphicsBeginImageContextWithOptions(size, YES, 0);
  [view drawViewHierarchyInRect:view.frame afterScreenUpdates:NO];
  UIImage *tempImage = UIGraphicsGetImageFromCurrentImageContext();
  UIImage *newImage = tempImage;//[UIImage resizeImage:tempImage forMaxDimension:640];
  UIGraphicsEndImageContext();
  
  switch (effect) {
    case BlurEffect:
      return [newImage applyEffect];
      break;
      
    case BlurEffectLight:
      return [newImage applyLightEffect];
      break;
      
    case BlurEffectExtraLight:
      return [newImage applyExtraLightEffect];
      break;
      
    case BlurEffectDark:
      return [newImage applyDarkEffect];
      break;
      
    default:
      return [newImage applyExtraLightEffect];
      break;
  }
}

+ (UIImage *)getBlurredScreenshotFromImage:(UIImage *)image blurffect:(BlurEffectType)effect;
{
  switch (effect) {
    case BlurEffect:
      return [image applyEffect];
      break;
      
    case BlurEffectLight:
      return [image applyLightEffect];
      break;
      
    case BlurEffectExtraLight:
      return [image applyExtraLightEffect];
      break;
      
    case BlurEffectDark:
      return [image applyDarkEffect];
      break;
      
    default:
      return [image applyExtraLightEffect];
      break;
  }
}

- (UIImage *)applyEffect
{
  UIColor *tintColor = [UIColor clearColor];
  return [self applyBlurWithRadius:30 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}

- (UIImage *)applyLightEffect
{
  UIColor *tintColor = [UIColor colorWithWhite:1.0 alpha:0.5];
  return [self applyBlurWithRadius:30 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}

- (UIImage *)applyExtraLightEffect
{
  UIColor *tintColor = [UIColor colorWithWhite:1.0 alpha:0.6];
  return [self applyBlurWithRadius:50 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}

- (UIImage *)applyDarkEffect
{
  UIColor *tintColor = [UIColor colorWithWhite:0 alpha:0.4];
  return [self applyBlurWithRadius:60 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}



- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage
{
  // Check pre-conditions.
  if (self.size.width < 1 || self.size.height < 1) {
    NSLog (@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", self.size.width, self.size.height, self);
    return nil;
  }
  if (!self.CGImage) {
    NSLog (@"*** error: image must be backed by a CGImage: %@", self);
    return nil;
  }
  if (maskImage && !maskImage.CGImage) {
    NSLog (@"*** error: maskImage must be backed by a CGImage: %@", maskImage);
    return nil;
  }
  
  CGRect imageRect = { CGPointZero, self.size };
  UIImage *effectImage = self;
  
  BOOL hasBlur = blurRadius > __FLT_EPSILON__;
  BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
  if (hasBlur || hasSaturationChange) {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef effectInContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(effectInContext, 1.0, -1.0);
    CGContextTranslateCTM(effectInContext, 0, -self.size.height);
    CGContextDrawImage(effectInContext, imageRect, self.CGImage);
    
#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
    vImage_Buffer effectInBuffer;
    effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
    effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
    effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
    effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
    vImage_Buffer effectOutBuffer;
    effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
    effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
    effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
    effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
#endif
    if (hasBlur) {
      // A description of how to compute the box kernel width from the Gaussian
      // radius (aka standard deviation) appears in the SVG spec:
      // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
      //
      // For larger values of 's' (s >= 2.0), an approximation can be used: Three
      // successive box-blurs build a piece-wise quadratic convolution kernel, which
      // approximates the Gaussian kernel to within roughly 3%.
      //
      // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
      //
      // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
      //
      CGFloat inputRadius = blurRadius * [[UIScreen mainScreen] scale];
      NSUInteger radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
      if (radius % 2 != 1) {
        radius += 1; // force radius to be odd so that the three box-blur methodology works.
      }
#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
      vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
      vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
      vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
#endif
    }
    BOOL effectImageBuffersAreSwapped = NO;
    if (hasSaturationChange) {
      CGFloat s = saturationDeltaFactor;
      CGFloat floatingPointSaturationMatrix[] = {
        0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
        0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
        0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
        0,                    0,                    0,  1,
      };
      const int32_t divisor = 256;
      NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
      int16_t saturationMatrix[matrixSize];
      for (NSUInteger i = 0; i < matrixSize; ++i) {
        saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
      }
      if (hasBlur) {
#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
        vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
#endif
        effectImageBuffersAreSwapped = YES;
      }
      else {
#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
        (&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
#endif
      }
    }
    if (!effectImageBuffersAreSwapped)
      effectImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (effectImageBuffersAreSwapped)
      effectImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
  }
  
  // Set up output context.
  UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
  CGContextRef outputContext = UIGraphicsGetCurrentContext();
  CGContextScaleCTM(outputContext, 1.0, -1.0);
  CGContextTranslateCTM(outputContext, 0, -self.size.height);
  
  // Draw base image.
  CGContextDrawImage(outputContext, imageRect, self.CGImage);
  
  // Draw effect image.
  if (hasBlur) {
    CGContextSaveGState(outputContext);
    if (maskImage) {
      CGContextClipToMask(outputContext, imageRect, maskImage.CGImage);
    }
    CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
    CGContextRestoreGState(outputContext);
  }
  
  // Add in color tint.
  if (tintColor) {
    CGContextSaveGState(outputContext);
    CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
    CGContextFillRect(outputContext, imageRect);
    CGContextRestoreGState(outputContext);
  }
  
  // Output image is ready.
  UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return outputImage;
}

+ (UIImage *)resizeImage:(UIImage *)sourceImage forMaxDimension:(CGFloat)maxDimension {
  CGFloat maxSourceImageDimention = sourceImage.size.height;
  if (sourceImage.size.height < sourceImage.size.width) {
    maxSourceImageDimention = sourceImage.size.width;
  }
  
  if (maxSourceImageDimention <= maxDimension) {
    return sourceImage;
  }
  // calculate zoom coefficient
  CGFloat scaleCoefficient = maxDimension / maxSourceImageDimention;
  CGSize scaledSize = CGSizeMake(sourceImage.size.width * scaleCoefficient,
                                 sourceImage.size.height * scaleCoefficient);
  // resize
  UIGraphicsBeginImageContext(scaledSize);
  CGRect drawRect = {.origin = CGPointZero, .size = scaledSize};
  [sourceImage drawInRect:drawRect];
  UIImage *resultImage = nil;
  resultImage = UIGraphicsGetImageFromCurrentImageContext();
  if (!resultImage) {
    return sourceImage;
  }
  
  return resultImage;
}

@end
