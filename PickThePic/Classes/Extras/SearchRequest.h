//
//  SearchRequest.h
//  PickThePic
//
//  Created by Lakshmi Thulasiram on 17/06/17.
//  Copyright © 2017 Lakshmi Thulasiram. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchRequest : NSObject
@property (nonatomic, strong) NSString      *searchStr;
@property (nonatomic, assign) NSInteger     startIndex;
@property (nonatomic, strong, getter=getRequestParams)NSString     *requestParams;
@end
