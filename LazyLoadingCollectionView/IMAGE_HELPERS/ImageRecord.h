//
//  MainVC.m
//  LazyLoadingCollectionView
//
//  Created by Cian on 11/09/14.
//  Copyright (c) 2014 Cian. All rights reserved.
//

////////////////////////
// This is just a model class that stores values of the image like imageURL and the original thumbimage. If needed we can also store many other
// details of an image by adding those properties to this class. This class works in tandem with ImageDownloader class to achieve lazy loading
// effect.

#import <Foundation/Foundation.h>

@interface ImageRecord : NSObject

@property (nonatomic, strong) UIImage *thumbImage;
@property (nonatomic, strong) NSString *imageURL;

@end
