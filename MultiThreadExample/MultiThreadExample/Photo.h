//
//  Photo.h
//  MultiThreadExample
//
//  Created by GaoYuan on 16/2/28.
//  Copyright © 2016年 GaoYuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PhotoState) {
    PhotoStateNew,
    PhotoStateDownloaded,
    PhotoStateFiltered,
    PhotoStateFailed
};

@interface Photo : NSObject

@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSURL *url;
@property (nonatomic,assign) PhotoState state;
@property (nonatomic,strong) UIImage *image;

-(instancetype)initWithName:(NSString *)name andURL:(NSURL *)url;

@end
