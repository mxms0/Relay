//
//  UIImage+Filters.m
//  Relay
//
//  Created by Max Shavrick on 6/21/13.
//

#import "UIImage+Filters.h"

@implementation UIImage (Gaussian)

- (UIImage *)imageWith3x3GaussianBlur {
    
	const CGFloat filter[3][3] = {
		{1.0f/16.0f, 2.0f/16.0f, 1.0f/16.0f},
		{2.0f/16.0f, 4.0f/16.0f, 2.0f/16.0f},
		{1.0f/16.0f, 2.0f/16.0f, 1.0f/16.0f}
	};
	
	CGImageRef imgRef = [self CGImage];
	size_t width = CGImageGetWidth(imgRef);
	size_t height = CGImageGetHeight(imgRef);
    
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	size_t bitsPerComponent = 8;
	size_t bytesPerPixel = 4;
	size_t bytesPerRow = bytesPerPixel * width;
	size_t totalBytes = bytesPerRow * height;
    uint8_t *rawData = malloc(totalBytes);
    
	CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
	CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    for (int y = 0; y < height; y++) {
		for (int x = 0; x < width; x++) {
            uint8_t *pixel = rawData + (bytesPerRow * y) + (x * bytesPerPixel);
            CGFloat sumRed = 0;
			CGFloat sumGreen = 0;
			CGFloat sumBlue = 0;
			for (int j = 0; j < 3; j++) {
				for (int i = 0; i < 3; i++) {
					if ((y + j - 1) >= height || (y + j - 1) < 0) {
						continue;
					}
					if ((x + i - 1) >= width || (x + i - 1) < 0) {
						continue;
					}
                    uint8_t *kernelPixel = rawData + (bytesPerRow * (y + j - 1)) + ((x + i - 1) * bytesPerPixel);
                    
					sumRed += kernelPixel[0] * filter[j][i];
					sumGreen += kernelPixel[1] * filter[j][i];
					sumBlue += kernelPixel[2] * filter[j][i];
				}
			}
			pixel[0] = roundf(sumRed);
			pixel[1] = roundf(sumGreen);
			pixel[2] = roundf(sumBlue);
		}
	}
	CGImageRef newImg = CGBitmapContextCreateImage(context);
	CGColorSpaceRelease(colorSpace);
	CGContextRelease(context);
	free(rawData);
	UIImage *image = [UIImage imageWithCGImage:newImg];
	CGImageRelease(newImg);
	return image;
}

@end
