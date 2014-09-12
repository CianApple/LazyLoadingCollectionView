//
//  MainVC.m
//  LazyLoadingCollectionView
//
//  Created by Cian on 11/09/14.
//  Copyright (c) 2014 Cian. All rights reserved.
//

@class ImageRecord;

#import <Foundation/Foundation.h>

@interface ImageDownloader : NSObject

@property (nonatomic, strong) ImageRecord *imageRecord;
@property (nonatomic, copy) void (^completionHandler)(void);

- (void)startDownload;
- (void)cancelDownload;

@end
