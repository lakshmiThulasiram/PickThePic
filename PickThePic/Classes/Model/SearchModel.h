//
//  SearchModel.h
//  PickThePic
//
//  Created by Lakshmi Thulasiram on 17/06/17.
//  Copyright © 2017 Lakshmi Thulasiram. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataManager.h"

@interface SearchModel : NSObject<NSURLSessionDelegate>
@property (nonatomic, strong) NSString                  *searchError;

-(void)searchPicturesFor:(NSString *)searchStr andCompletionHandler:(void (^) (BOOL success))completionHandler;
-(NSInteger)getResultsCount;
-(NSString *)imageURLAtIndex:(NSInteger)index;
-(BOOL)isNewSearch:(NSString *)searchStr;
-(void)clearSearchData;
-(NSString *)getLatestSearchKeyword;
-(NSInteger)getTotalResultsCount;
@end
