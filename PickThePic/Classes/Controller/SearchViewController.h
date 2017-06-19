//
//  SearchViewController.h
//  PickThePic
//
//  Created by Lakshmi Thulasiram on 17/06/17.
//  Copyright © 2017 Lakshmi Thulasiram. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UIViewController
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITableView *tableViewRecents;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end
