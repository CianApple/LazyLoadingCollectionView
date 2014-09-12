//
//  LazyCell.m
//  LazyLoadingCollectionView
//
//  Created by Cian on 11/09/14.
//  Copyright (c) 2014 Cian. All rights reserved.
//

/////////////////
// Custom collectionview cell for collectionview in LazyLoadVC.

#import "LazyCell.h"

// USER DEFINED MACROS
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? YES : NO)
#define IS_IPHONE_5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)

@implementation LazyCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *arrayOfviews = [[NSBundle mainBundle] loadNibNamed:IS_IPAD?@"LazyCell_ipad":@"LazyCell_iphone"
                                                              owner:self
                                                            options:nil];
        self = [[arrayOfviews objectAtIndex:0]isKindOfClass:[UICollectionViewCell class]] ? [arrayOfviews objectAtIndex:0] : nil;
    }
    return self;

}

@end
