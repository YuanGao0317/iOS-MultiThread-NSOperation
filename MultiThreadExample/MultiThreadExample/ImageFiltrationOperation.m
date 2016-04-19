//
//  ImageFiltrationOperation.m
//  MultiThreadExample
//
//  Created by GaoYuan on 16/2/28.
//  Copyright © 2016年 GaoYuan. All rights reserved.
//

#import "ImageFiltrationOperation.h"
#import "StaticConsts.h"

@implementation ImageFiltrationOperation

-(instancetype) initWithPhoto:(Photo *)photo
{
    self = [self init];
    
    if (self) {
        _photo = photo;
    }
    
    return self;
}

-(void)main
{
    if (self.cancelled) {
        return;
    }
    
    if (self.cancelled) {
        return;
    }
    
    if (self.photo.state == PhotoStateDownloaded) {
        UIImage *filteredImage = [self _applySepiaFilter:self.photo.image];
        
        if (filteredImage) {
            self.photo.image = filteredImage;
            self.photo.state = PhotoStateFiltered;
        }
    }
}

-(UIImage *) _applySepiaFilter:(UIImage *)image
{
    CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
    
    if (self.cancelled) {
        return nil;
    }
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:@0.8 forKey:@"inputIntensity"];
    
    CIImage *outputImage = filter.outputImage;
    
    if (self.cancelled) {
        return nil;
    }
    
    UIImage *filteredImage = [UIImage imageWithCGImage:[context createCGImage:outputImage fromRect:outputImage.extent]];
    return filteredImage;
}
@end
