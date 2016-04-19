//
//  Photo.m
//  MultiThreadExample
//
//  Created by GaoYuan on 16/2/28.
//  Copyright © 2016年 GaoYuan. All rights reserved.
//

#import "Photo.h"
#import "StaticConsts.h"

@implementation Photo

-(instancetype)initWithName:(NSString *)name andURL:(NSURL *)url
{
    self = [self init];
    
    if (self) {
        _name = name;
        _url = url;
        _state = PhotoStateNew;
        _image = [UIImage imageNamed:kDefaultImage];
    }
    
    return self;
}

@end
