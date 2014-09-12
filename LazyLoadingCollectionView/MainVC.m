//
//  MainVC.m
//  LazyLoadingCollectionView
//
//  Created by Cian on 11/09/14.
//  Copyright (c) 2014 Cian. All rights reserved.
//

#import "MainVC.h"

// USER DEFINED MACROS
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? YES : NO)
#define IS_IPHONE_5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)

@interface MainVC ()

@end

@implementation MainVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btn_pressme_pressed:(id)sender
{
    // Fetch string of image URL's from ImageList.txt
    NSString* fileRoot = [[NSBundle mainBundle] pathForResource:@"ImageList"
                                                         ofType:@"txt"];
    // Apply NSUTF8StringEncoding to the above string
    NSString* fileContents = [NSString stringWithContentsOfFile:fileRoot
                                                       encoding:NSUTF8StringEncoding
                                                          error:nil];
    // Fetch array of URL's from the text file by check for newline.
    NSArray* allLinedStrings = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    // Note: To add more images to the project -> Just copy and paste the new list of image URL's in the ImageList.txt file. That's it.
    
    // Prepare the array for processing in LazyLoadVC. Add each URL into a separate ImageRecord object and store it in the array.
    NSMutableArray *listURLs = [NSMutableArray array];
    for (int cnt=0; cnt<[allLinedStrings count]; cnt++)
    {
        ImageRecord *obj = [[ImageRecord alloc] init];
        obj.imageURL = [allLinedStrings objectAtIndex:cnt];
        [listURLs addObject:obj];
    }
    
    // Added functionality to randomize the sequence of images. This is optional. Just comment this part of code if you are not bored to see the same images again and again.
    NSUInteger count = [listURLs count];
    for (NSUInteger i = 0; i < count; ++i) {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform(remainingCount);
        [listURLs exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
    
    // Navigate to the LazyLoadVC for watching these image urls lazy load. Just pass the prepared array to ary_images in the next class.
    LazyLoadVC *obj_LazyLoadVC = nil;
    if (IS_IPAD)
        obj_LazyLoadVC = [[LazyLoadVC alloc] initWithNibName:@"LazyLoadVC_ipad" bundle:nil];
    else
        obj_LazyLoadVC = [[LazyLoadVC alloc] initWithNibName:@"LazyLoadVC_iphone" bundle:nil];
    obj_LazyLoadVC.ary_images = listURLs;
    [self.navigationController pushViewController:obj_LazyLoadVC animated:YES];
    listURLs = nil;
}
@end
