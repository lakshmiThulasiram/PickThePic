//
//  SearchRequest.m
//  PickThePic
//
//  Created by Lakshmi Thulasiram on 17/06/17.
//  Copyright © 2017 Lakshmi Thulasiram. All rights reserved.
//

#import "SearchRequest.h"
#import "AppMacros.h"

@implementation SearchRequest
-(id)init
{
    self    = [super init];
    if (self) {
        self.startIndex     = 1;
    }
    return self;
}
-(NSString *)getRequestParams
{
    return [[self buildRequestParams] componentsJoinedByString:@"&"];
    
}
-(NSArray *)buildRequestParams
{
    NSMutableArray *params      = [NSMutableArray array];
    [params addObject:[NSString stringWithFormat:@"%@=%@",kQueryKey,self.searchStr]];
    [params addObject:[NSString stringWithFormat:@"%@=%ld",kStartIndex,(long)self.startIndex]];
    [params addObject:[NSString stringWithFormat:@"%@=%@",kSearchTypeKey,kSearchTypeImage]];
    [params addObject:[NSString stringWithFormat:@"%@=%@",kImageSizeKey,kImageSizeMedium]];
    [params addObject:[NSString stringWithFormat:@"%@=%@",kContextIDKey,kContextID]];
    [params addObject:[NSString stringWithFormat:@"%@=%@",kApiKey,KEY]];

    return params;
}
@end
