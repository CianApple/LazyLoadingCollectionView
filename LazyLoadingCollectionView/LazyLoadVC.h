//
//  LazyLoadVC.h
//  LazyLoadingCollectionView
//
//  Created by Cian on 11/09/14.
//  Copyright (c) 2014 Cian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LazyCell.h"

@interface LazyLoadVC : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIDocumentInteractionControllerDelegate>
{
    
}

// PROPERTIES
@property (strong, nonatomic) NSMutableArray *ary_images;
@property (strong, nonatomic) UIDocumentInteractionController *documentInteractionController;

// OUTLETS
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end
