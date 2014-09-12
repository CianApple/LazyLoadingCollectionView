//
//  LazyLoadVC.m
//  LazyLoadingCollectionView
//
//  Created by Cian on 11/09/14.
//  Copyright (c) 2014 Cian. All rights reserved.
//

/////////////////////////////
//
// *** LazyLoadingCollectionView ***
//
// This project is used to demonstrate the lazy loading of large number of images in a collectionview. This same technique can be used to display
// images in a tableview or scrollview lazily.
//
// I have tried to use all the different techniques that can be utilised for lazy loading. So far I think this is the best way to lazy load
// list of images in a collectionview, tableview or scrollview.
// https://github.com/path/FastImageCache  - Refer this link. It has the best documentation for learning different logics to help improve lazy
// loading. I myself referred this project to combine all the best methods which led me to develop this project which I think is by far the best
// memory efficient, fast, without lag lazy loading example. I personally have tested this collectionview with more than 5400 images and it works
// excellently. Just copy the url multiple times in ImageList.txt file to test it yourself.
//
// Initially in my live projects, I noticed that such functionality is needed in every other project whether it be collectionview,
// pageviewcontroller, tableview or scrollview. But I was really frustrated for not finding out a good solution for it. This piece of project can
// be utilised in every other project of yours too.
//
// Lazy loading of image is inspired from apple's example and it works perfectly. Hope this will help you guys in your projects too. If anyone
// finds any bugs in this project, please do let me know about it.
//
//
// Images hosted on http://postimage.org
//

#import "LazyLoadVC.h"
#import "ImageRecord.h"
#import "ImageDownloader.h"
#import "ImageCache.h"

// USER DEFINED MACROS
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? YES : NO)
#define IS_IPHONE_5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)

static NSString * const kCellReuseIdentifier = @"ReuseID";

@interface LazyLoadVC () <UIScrollViewDelegate>
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;
@end

@implementation LazyLoadVC
// SYNTHESIZERS
@synthesize ary_images;

/////////////////////////////////////
//   View Delegates
/////////////////////////////////////
#pragma mark - View Delegates
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
    [self setupCollectionView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:NO];
    self.title = [NSString stringWithFormat:@"Lazy Loading UICollectionView - %d Images",self.ary_images.count];
    [self emptyDocumentsDir];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    // If memory warning is issued, then we can clear the objects to free some memory. Here we are simply removing all the images. But we can use a bit more logic to handle the memory here.
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    [self.imageDownloadsInProgress removeAllObjects];
}

/////////////////////////////////////
//   UICollectionView Delegates
/////////////////////////////////////
#pragma mark - UICollectionView Delegates
-(void)setupCollectionView
{
    [self.collectionView registerClass:[LazyCell class] forCellWithReuseIdentifier:kCellReuseIdentifier];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    if (IS_IPAD) [flowLayout setSectionInset:UIEdgeInsetsMake(20,30,20,30)];
    else        [flowLayout setSectionInset:UIEdgeInsetsMake(15, 15, 15, 15)];
    
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.0f];
    [self.collectionView setPagingEnabled:NO];
    [self.collectionView setCollectionViewLayout:flowLayout];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.ary_images count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LazyCell *cell = (LazyCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellReuseIdentifier forIndexPath:indexPath];
    
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[cell.imageView viewWithTag:505];
    
    // Set up the cell...
    // Fetch a image record from the array
    ImageRecord *imgRecord = [self.ary_images objectAtIndex:indexPath.row];
    
    // Set thumbimage
    // Check if the image exists in cache. If it does exists in cache, directly fetch it and display it in the cell
    if ([[ImageCache sharedImageCache] DoesExist:imgRecord.imageURL] == true)
    {
        [activityIndicator stopAnimating];
        [activityIndicator removeFromSuperview];

        cell.imageView.image = [[ImageCache sharedImageCache] GetImage:imgRecord.imageURL];
    }
    // If it does not exist in cache, download it
    else
    {
        // Add activity indicator
        if (activityIndicator) [activityIndicator removeFromSuperview];
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityIndicator.hidesWhenStopped = YES;
        activityIndicator.hidden = NO;
        [activityIndicator startAnimating];
        activityIndicator.center = cell.imageView.center;
        activityIndicator.tag = 505;
        [cell.imageView addSubview:activityIndicator];
        
        // Only load cached images; defer new downloads until scrolling ends
        if (!imgRecord.thumbImage)
        {
            if (self.collectionView.dragging == NO && self.collectionView.decelerating == NO)
            {
                [self startIconDownload:imgRecord forIndexPath:indexPath];
            }
            // if a download is deferred or in progress, return a placeholder image
            cell.imageView.image = [UIImage imageNamed:@"placeholder.png"];
        }
        else
        {
            cell.imageView.image = imgRecord.thumbImage;
        }
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Fetch image from array and store it in documents directory for displaying it in documents directory.
    ImageRecord *selectedObj = [self.ary_images objectAtIndex:indexPath.row];
    if (selectedObj.thumbImage) {
        
        dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
        dispatch_async(myQueue, ^{
            //NSData *pngData = UIImagePNGRepresentation(selectedObj.thumbImage);
            NSData *pngData = [NSData dataWithContentsOfURL:[NSURL URLWithString:selectedObj.imageURL]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsPath = [paths objectAtIndex:0];                                  //Get the docs directory
                NSString *filePath = [documentsPath stringByAppendingPathComponent:@"image.png"];   //Add the file name
                [pngData writeToFile:filePath atomically:YES];                                      //Write the file
                
                NSURL *URL = [[NSURL alloc] initFileURLWithPath:filePath];
                if (URL) {
                    // Initialize Document Interaction Controller
                    self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:URL];
                    // Configure Document Interaction Controller
                    [self.documentInteractionController setDelegate:self];
                    // Preview Image
                    [self.documentInteractionController presentPreviewAnimated:YES];
                }
            });
        });
        
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return IS_IPAD?CGSizeMake(160, 160):CGSizeMake(90, 90);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    if(IS_IPAD)
        return 20.0;
    else
        return 15.0;
    return 0.0;
}

/////////////////////////////////////
//   Helper Methods
/////////////////////////////////////
#pragma mark - Helper Methods
- (void)startIconDownload:(ImageRecord *)imgRecord forIndexPath:(NSIndexPath *)indexPath
{
    ImageDownloader *imgDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (imgDownloader == nil)
    {
        imgDownloader = [[ImageDownloader alloc] init];
        imgDownloader.imageRecord = imgRecord;
        [imgDownloader setCompletionHandler:^{
            
            LazyCell *cell = (LazyCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            
            // Display the newly loaded image
            cell.imageView.image = imgRecord.thumbImage;
            
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:indexPath];
            
            UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[cell.imageView viewWithTag:505];
            [activityIndicator stopAnimating];
            [activityIndicator removeFromSuperview];
        }];
        [self.imageDownloadsInProgress setObject:imgDownloader forKey:indexPath];
        [imgDownloader startDownload];
    }
}
- (void)loadImagesForOnscreenRows
{
    if ([self.ary_images count] > 0)
    {
        NSArray *visiblePaths = [self.collectionView indexPathsForVisibleItems];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            ImageRecord *imgRecord = [self.ary_images objectAtIndex:indexPath.row];
            
            if (!imgRecord.thumbImage)
                // Avoid downloading if the image is already downloaded
            {
                [self startIconDownload:imgRecord forIndexPath:indexPath];
            }
        }
    }
}

/////////////////////////////////////
//   Scrollview Delegates
/////////////////////////////////////
#pragma mark - Scrollview Delegates
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
        [self loadImagesForOnscreenRows];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

/////////////////////////////////////
//   UIDocumentInteractionController Delegate
/////////////////////////////////////
#pragma mark - UIDocumentInteractionController Delegate
- (UIViewController *) documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller {
    return self;
}

/////////////////////////////////////
//   Documents Directory
/////////////////////////////////////
#pragma mark - Documents Directory
-(void)emptyDocumentsDir
{
    NSFileManager *fileMgr = [[NSFileManager alloc] init];
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSArray *files = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:nil];
    
    while (files.count > 0) {
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSArray *directoryContents = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error];
        if (error == nil) {
            for (NSString *path in directoryContents) {
                NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:path];
                BOOL removeSuccess = [fileMgr removeItemAtPath:fullPath error:&error];
                files = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:nil];
                if (!removeSuccess) {
                    // Error
                }
            }
        } else {
            // Error
        }
    }
}

@end
