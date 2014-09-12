//
//  MainVC.m
//  LazyLoadingCollectionView
//
//  Created by Cian on 11/09/14.
//  Copyright (c) 2014 Cian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageCache : NSObject

@property (nonatomic, retain) NSCache *imgCache;

#pragma mark - Methods
+ (ImageCache*)sharedImageCache;
- (void) AddImage:(NSString *)imageURL :(UIImage *)image;
- (UIImage*) GetImage:(NSString *)imageURL;
- (BOOL) DoesExist:(NSString *)imageURL;

@end
