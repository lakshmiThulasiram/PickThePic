//
//  SearchCell.h
//  PickThePic
//
//  Created by Lakshmi Thulasiram on 18/06/17.
//  Copyright © 2017 Lakshmi Thulasiram. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageViewSearch;
@property (nonatomic, strong) NSString *imageURL;
@end
