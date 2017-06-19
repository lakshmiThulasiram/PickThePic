//
//  SearchViewController.m
//  PickThePic
//
//  Created by Lakshmi Thulasiram on 17/06/17.
//  Copyright © 2017 Lakshmi Thulasiram. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchCell.h"
#import "SearchModel.h"
#import "SearchCollectionFooter.h"
#import "SearchCollectionHeader.h"
#import "AppMacros.h"
#import "IToast.h"

#define kFooterHgt 50
#define kSearchCellID @"SearchCell"
#define kFooterID @"FooterView"

@interface SearchViewController ()<UISearchBarDelegate, UISearchControllerDelegate>
@property (nonatomic, strong)UISearchController *searchVC;
@property (nonatomic, strong)SearchModel        *model;
@property (nonatomic, strong)NSOperationQueue   *imageOperationQueue;
@property (nonatomic, strong)NSCache            *imageCache;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loaderView;

@end

@implementation SearchViewController

static NSString * const reuseIdentifier = kSearchCellID;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    [self prepareController];
    // Do any additional setup after loading the view.
}
-(void)prepareController
{
    self.imageOperationQueue = [[NSOperationQueue alloc]init];
    self.imageOperationQueue.maxConcurrentOperationCount = 10;
    
    self.imageCache = [[NSCache alloc] init];
    self.model      = [[SearchModel alloc] init];

    [self.loaderView stopAnimating];
    [self.searchBar becomeFirstResponder];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.model getResultsCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SearchCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    NSString *imageLink     = [self.model imageURLAtIndex:indexPath.row];
    UIImage *imageFromCache = [self.imageCache objectForKey:imageLink];
    cell.backgroundColor    = [UIColor lightGrayColor];
    cell.imageViewSearch.image  = nil;
    cell.imageURL           = imageLink;
    if (imageFromCache) {
        cell.imageViewSearch.image = imageFromCache;
    }
    else
    {
        
        [self.imageOperationQueue addOperationWithBlock:^{
            NSURL *imageurl = [NSURL URLWithString:imageLink];
            UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageurl]];
            
            if (img) {
                
                // update cache
                [self.imageCache setObject:img forKey:imageLink];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    if([cell.imageURL isEqualToString:imageLink])
                        [cell.imageViewSearch setImage:img];
                }];
            }
        }];
    }
    return cell;

}

#pragma mark <UICollectionViewDelegate>


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.collectionView.frame.size.width/2 - 1 ,self.collectionView.frame.size.width/2 - 1);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(self.collectionView.frame.size.width, kFooterHgt);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0;
}
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    SearchCollectionFooter *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionFooter) {
        SearchCollectionFooter *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kFooterID forIndexPath:indexPath];
        
        //This check as Google API returns only first 100 search results
        if([self.model getTotalResultsCount] != 0 && [self canSendNextSearchRequest])
            footerview.loaderView.hidden    = NO;
        else
            footerview.loaderView.hidden    = YES;
        reusableview = footerview;
    }
    else if (kind == UICollectionElementKindSectionHeader) {
        
    }
    return reusableview;
    
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self resignKeyboard];
    if (scrollView.contentOffset.y + scrollView.frame.size.height == scrollView.contentSize.height)
    {
        if([self canSendNextSearchRequest])//This check as Google API returns only first 100 search results
        {
            [self fetchPhotoForSearchKey:self.searchBar.text];

        }
    }
}
#pragma mark-
#pragma mark UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[DataManager sharedManager] retrieveRecentsList] count]<=kRecentSearchCountLimit?[[[DataManager sharedManager] retrieveRecentsList] count]:kRecentSearchCountLimit;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kRecentSearchListReuseID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] init];
    }
    cell.textLabel.text = [[[DataManager sharedManager] retrieveRecentsList] objectAtIndex:indexPath.row]; //[self.displayedItems objectAtIndex:anIndexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.searchBar.text = [[[DataManager sharedManager] retrieveRecentsList] objectAtIndex:indexPath.row];
    [self resignKeyboard];
    [self fetchPhotoForSearchKey:self.searchBar.text];
    [self shouldShowRecentList:NO];
}
#pragma mark-
#pragma mark UISearchDelegate
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self shouldShowRecentList:YES];    
    [self.tableViewRecents reloadData];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self resignKeyboard];
    [self shouldShowRecentList:NO];
    [self fetchPhotoForSearchKey:searchBar.text];
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    if([self.searchBar.text length]>0)
    {
        self.searchBar.text     = [self.model getLatestSearchKeyword];
    }
    else{
        [self emptyTheTable];
    }
    [self shouldShowRecentList:NO];
    [self resignKeyboard];
}
#pragma mark-
#pragma mark Helpers
-(void)fetchPhotoForSearchKey:(NSString *)searchStr
{
    if([self isSearchKeywordValid:searchStr])
    {
        if([self.model isNewSearch:searchStr])
        {
            [self emptyTheTable];
        }
        [self.loaderView startAnimating];
        [self.model searchPicturesFor:searchStr andCompletionHandler:^(BOOL success){
            if(success)
            {
                [self.loaderView stopAnimating];
                [self.collectionView reloadData];
            }else{
                [self showError:self.model.searchError];
            }
        }];
    }
    else
    {
        [self showError:NSLocalizedString(@"VALID_KEYWORD_ERROR", nil)];
    }
    
}
-(void)shouldShowRecentList:(BOOL)shouldShow
{
    self.tableViewRecents.hidden = !shouldShow;
    self.collectionView.hidden=shouldShow;
}
-(void)resignKeyboard
{
    [self.searchBar endEditing:YES];
    [self.searchBar resignFirstResponder];
}
-(void)emptyTheTable
{
    [self.model clearSearchData];
    [self.collectionView reloadData];
}
-(void)showError:(NSString *)error
{
//    [self emptyTheTable];
    [self.loaderView stopAnimating];
    [IToast displayItoastWithMessage:error andDisplayTime:kDefaultToastDuration];
  
}

-(BOOL)canSendNextSearchRequest
{
    if([self.model getResultsCount] <= 100 && [self.model getResultsCount] != [self.model getTotalResultsCount])//This check as Google API returns only first 100 search results
    {
        return YES;
    }
    return NO;
}
-(BOOL)isSearchKeywordValid:(NSString *)searchStr;
{
    if([[searchStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length])
    {
        return YES;
    }
    return NO;
}
@end
