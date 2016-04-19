//
//  ViewController.m
//  MultiThread
//
//  Created by GaoYuan on 16/2/27.
//  Copyright © 2016年 GaoYuan. All rights reserved.
//

#import "ViewController.h"
#import "StaticConsts.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation ViewController

static NSString* const kCell = @"Cell";

#pragma mark - Initiallization
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;

    _photos = [[NSMutableArray alloc] init];
    
    _operationController = [[OperationController alloc] initOperationController];
    
    /**
     * We do not need to create a downloadDataSourceOperation and add it into a queue.
     * NSURLSession will create queue itself.
     * Here just for test.
     **/
    NSInvocationOperation *downloadDataSourceOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(fetchPhotosDataIntoDataSource:) object:self.photos];
    [self.operationController.downloadDataSourceQueue addOperation:downloadDataSourceOperation];
}


-(void) fetchPhotosDataIntoDataSource:(NSMutableArray *)photos
{
    NSURL *url = [NSURL URLWithString:@"http://www.raywenderlich.com/downloads/ClassicPhotosDictionary.plist"];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // Download data source
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"Failed to fetch datasource: %@", error.localizedDescription);
            return;
        }
        
        if (data) {
            NSMutableDictionary *dictionary = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:nil error:nil];
            
            for (id key in dictionary) {
                NSString *name = key;
                NSURL *url = [NSURL URLWithString:[dictionary valueForKey:key]];
                
                Photo *photo = [[Photo alloc] initWithName:name andURL:url];
                [self.photos addObject:photo];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            });
            
        }
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
    
    [task resume];
}


#pragma mark - UITableViewDataSource, UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _photos.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCell forIndexPath:indexPath];
    
    // Set activity indicator
    if (!cell.accessoryView) {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        cell.accessoryView = activityIndicator;
    }
    
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)cell.accessoryView;
    
    Photo *photo = [self.photos objectAtIndex:indexPath.row];
    if (photo) {
        
        cell.textLabel.text = photo.name;
        cell.imageView.image = photo.image;
        
        // Resize image
        CGSize itemSize = CGSizeMake(80, 80);
        UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
        CGRect imageRect = CGRectMake(10, 10, itemSize.width, itemSize.height);
        [cell.imageView.image drawInRect:imageRect];
        cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // Download image
        switch (photo.state) {
            case PhotoStateNew:
                [activityIndicator startAnimating];
                
            case PhotoStateDownloaded:
                if (!tableView.dragging && !tableView.decelerating) {
                    [self _startOperationsForPhoto:photo atIndexPath:indexPath];
                }
                break;
                
            case PhotoStateFiltered:
                [activityIndicator stopAnimating];
                break;
                
            case PhotoStateFailed:
                [activityIndicator stopAnimating];
                cell.textLabel.text = @"Failed to load";
                cell.imageView.image = [UIImage imageNamed:kNoImage];
                break;
            default:
                break;
        }
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self _suspendAllOperations];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self _loadImagesForOnscreenCells];
        [self _resumeAllOperations];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self _loadImagesForOnscreenCells];
    [self _resumeAllOperations];
}

#pragma mark - Local methods
-(void) _startOperationsForPhoto:(Photo *)photo atIndexPath:(NSIndexPath *)indexPath
{
//    switch (photo.state) {
//            
//        case PhotoStateNew:
//            [self _startDownloadForPhoto:photo atIndexPath:indexPath];
//            break;
//        case PhotoStateDownloaded:
//            [self _startFiltrationForPhoto:photo atIndexPath:indexPath];
//            break;
//        default:
//            break;
//    }
    
    if (photo.state == PhotoStateNew) {
        [self _startDownloadForPhoto:photo atIndexPath:indexPath];
        [self _startFiltrationForPhoto:photo atIndexPath:indexPath];
    }
}

-(void) _startDownloadForPhoto:(Photo *)photo atIndexPath:(NSIndexPath *)indexPath
{
    // Image is downloading
    if ([[self.operationController.downloadsInProgress allKeys] containsObject:indexPath]) {
        return;
    }
    
    ImageDownloadOperation *imageDownloadOperation = [[ImageDownloadOperation alloc] initWithPhoto:photo];
    
    __unsafe_unretained __typeof(ImageDownloadOperation *) weakOperation = imageDownloadOperation;
    imageDownloadOperation.completionBlock = ^{
        if (weakOperation.isCancelled) {
            return;
        }
        // download finished
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.operationController.downloadsInProgress removeObjectForKey:indexPath];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        });
    };
    
    // Images in downloading progress
    [self.operationController.downloadsInProgress setObject:imageDownloadOperation forKey:indexPath];
    // Add into download queue and start download
    [self.operationController.imageDownloadQueue addOperation:imageDownloadOperation];
}

-(void) _startFiltrationForPhoto:(Photo *)photo atIndexPath:(NSIndexPath *)indexPath
{
    // Image is filtering
    if ([[self.operationController.filtrationsInProgress allKeys] containsObject:indexPath]) {
        return;
    }
    
    ImageFiltrationOperation *imageFiltrationOperation = [[ImageFiltrationOperation alloc] initWithPhoto:photo];
    
    __unsafe_unretained __typeof(ImageFiltrationOperation *) weakSelf = imageFiltrationOperation;
    imageFiltrationOperation.completionBlock = ^{
        if (weakSelf.isCancelled) {
            return;
        }
        // download finished
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.operationController.filtrationsInProgress removeObjectForKey:indexPath];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        });
    };
    
    // Add dependency to image download operation
    ImageDownloadOperation *imageDownloadOperation = (ImageDownloadOperation *)(self.operationController.downloadsInProgress[indexPath]);
    [imageFiltrationOperation addDependency:imageDownloadOperation];
    
    // Images in downloading progress
    [self.operationController.filtrationsInProgress setObject:imageFiltrationOperation forKey:indexPath];
    
    // Add into download queue and start download
    [self.operationController.imageFiltrationQueue addOperation:imageFiltrationOperation];
}

-(void) _suspendAllOperations
{
    self.operationController.imageDownloadQueue.suspended = YES;
    self.operationController.imageFiltrationQueue.suspended = YES;
}

-(void) _resumeAllOperations
{
    self.operationController.imageDownloadQueue.suspended = NO;
    self.operationController.imageFiltrationQueue.suspended = NO;
}

-(void) _loadImagesForOnscreenCells
{
    NSArray *indexPaths = self.tableView.indexPathsForVisibleRows;
    
    if (indexPaths) {
        NSMutableSet *operationsInProgress = [NSMutableSet setWithArray:[self.operationController.downloadsInProgress allKeys]];
        NSSet *visiblePaths = [NSSet setWithArray:indexPaths];
        NSMutableSet *operationsToBeCancelled = operationsInProgress;
        [operationsToBeCancelled minusSet:visiblePaths];
        
        for (NSIndexPath *indexPath in operationsToBeCancelled) {
            if ([[self.operationController.downloadsInProgress allKeys] containsObject:indexPath]) {
                [[self.operationController.downloadsInProgress objectForKey:indexPath] cancel];
                [self.operationController.downloadsInProgress removeObjectForKey:indexPath];
            }
        }
        
        for (NSIndexPath *indexPath in visiblePaths) {
            Photo *photoToBeDownloaded = self.photos[indexPath.row];
            [self _startOperationsForPhoto:photoToBeDownloaded atIndexPath:indexPath];
        }
    }
    
}

#pragma mark - Getter & Setter
-(NSMutableArray *)photos
{
    if (!_photos) {
        _photos = [NSMutableArray new];
    }
    
    return _photos;
}

@end
