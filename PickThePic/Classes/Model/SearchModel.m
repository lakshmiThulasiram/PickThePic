//
//  SearchModel.m
//  PickThePic
//
//  Created by Lakshmi Thulasiram on 17/06/17.
//  Copyright © 2017 Lakshmi Thulasiram. All rights reserved.
//

#import "SearchModel.h"
#import "SearchRequest.h"
#import "AppMacros.h"
#import "Reachability.h"
#import <UIKit/UIKit.h>

#define kUrlToconnect @"https://www.googleapis.com/customsearch/v1"
#define kItemsKey   @"items"
#define kNoResultsKey @"searchInformation.totalResults"
#define kSearchErrorPath @"error.errors.message"
#define kSearchInfoTotalResultsPath @"searchInformation.totalResults"
@interface SearchModel()

@property (nonatomic, strong) NSMutableDictionary       *searchResults;
@property (nonatomic, strong) NSOperationQueue          *searchOperationQueue;

@end

@implementation SearchModel
-(id)init
{
    self = [super init];
    if(self)
    {
       
    }
    return self;
}
#pragma mark-
#pragma mark Requester
-(void)sendRequest:(NSString *)requestContent andCompletionHandler:(void (^) (id response))completionHandler
{

    NSMutableURLRequest *requestToSend = [[NSMutableURLRequest alloc]init];
    [requestToSend setTimeoutInterval:30.0];
    [requestToSend setHTTPMethod:kGET];
    
    

    [requestToSend setURL:[NSURL URLWithString:[self formulateRequest:requestContent]]];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    if([Reachability reachabilityForInternetConnection])
    {
        [[session dataTaskWithRequest:requestToSend completionHandler:^(NSData *data,
                                                                        NSURLResponse *response,
                                                                        NSError *error){
            if(!error)
            {
                NSError *jsonError = nil;
                NSDictionary *json = [NSJSONSerialization
                                      JSONObjectWithData:data
                                      options:kNilOptions
                                      error:&jsonError];
                completionHandler(json);            
            }
            else
            {
                completionHandler(error.localizedDescription);

            }
            
        }] resume];
    }
    else
    {
        completionHandler(NSLocalizedString(@"INTERNET_CONNECTIVITY",nil));
    }
    

}
-(void)searchPicturesFor:(NSString *)searchStr andCompletionHandler:(void (^) (BOOL success))completionHandler

{
    [self prepareOperationQueue];
    [self.searchOperationQueue cancelAllOperations];
    [self saveInRecentsList:searchStr];
    
    [self.searchOperationQueue addOperationWithBlock:^{
        SearchRequest *request      = [[SearchRequest alloc] init];
        request.searchStr           = searchStr;
        request.startIndex          = [self getResultsCount]+1;
       
        [self sendRequest:request.requestParams andCompletionHandler:^(id response){
            if(response)
            {
                if([self isValidResponse:response])
                {
                    if([response objectForKey:kItemsKey])
                    {
                        if(!self.searchResults)
                        {
                            self.searchResults      = [NSMutableDictionary dictionary];
                            self.searchResults      = [response mutableCopy];
                        }
                        else{
                            [self mergeSearchResults:response];
                        }
                        completionHandler(YES);
                    }
                    else
                    {
                        [self handleError:response];
                        completionHandler(NO);
                    }
                }
                else
                {
                    [self handleError:response];
                    completionHandler(NO);
                }
                                
            }
            
        }];
    }];
    
    
    
}
#pragma mark-
#pragma mark Helpers
-(NSInteger)getResultsCount
{
    if(self.searchResults)
        return [[self.searchResults objectForKey:kItemsKey] count];
    return 0;
}
-(NSInteger)getTotalResultsCount
{
    if(self.searchResults)
        return [[self.searchResults valueForKeyPath:kSearchInfoTotalResultsPath] integerValue];
    return 0;
}
-(NSString *)imageURLAtIndex:(NSInteger)index
{
    NSDictionary *searchData    = [[self.searchResults objectForKey:kItemsKey] objectAtIndex:index];
    return [searchData objectForKey:kImageLinkPath];
    
}
-(void)saveInRecentsList:(NSString *)searchStr
{
    [[DataManager sharedManager] saveSearchStringToRecentsList:searchStr];
}
-(BOOL)isNewSearch:(NSString *)searchStr
{
    if([searchStr isEqualToString:[self getLatestSearchKeyword]])
    {
        return NO;
    }
    return YES;
}
-(void)clearSearchData
{
    self.searchResults = nil;
}
-(NSString *)getLatestSearchKeyword
{
    if([[[DataManager sharedManager] retrieveRecentsList] count])
        return [[[DataManager sharedManager] retrieveRecentsList] objectAtIndex:0];
    return @"";
}
-(void)prepareOperationQueue
{
    if(!self.searchOperationQueue)
    {
        self.searchOperationQueue = [[NSOperationQueue alloc]init];
        self.searchOperationQueue.maxConcurrentOperationCount = 4;
        
    }

}
-(void)mergeSearchResults:(NSDictionary *)response
{
    NSMutableArray *searchResultArray  = [NSMutableArray array];
    searchResultArray   = [[self.searchResults objectForKey:kItemsKey] mutableCopy];
    [searchResultArray addObjectsFromArray:[response objectForKey:kItemsKey]];
    [self.searchResults setValue:searchResultArray forKey:kItemsKey];
}
-(NSString *)formulateRequest:(NSString *)requestContent
{
        return [kUrlToconnect stringByAppendingString:[NSString stringWithFormat:@"?%@",requestContent]];
}

-(BOOL)isValidResponse:(id)response
{
    
    if([response isKindOfClass:[NSDictionary class]])
    {
        return YES;
    }
    return NO;
}

#pragma mark Error handler
-(void)handleError:(id)response
{
    if([self isValidResponse:response])
    {
        //Handle other error from APi such as no records forund and API hit exceed.
        if([[response valueForKeyPath:kNoResultsKey] floatValue] == 0)
        {
            self.searchError    = NSLocalizedString(@"NO_RECORDS_FOUND",nil);
        }
        if([response valueForKeyPath:kSearchErrorPath])
        {
            if([[response valueForKeyPath:kSearchErrorPath] isKindOfClass:[NSArray class]])
            {
                self.searchError        = [[response valueForKeyPath:kSearchErrorPath] count]?[[response valueForKeyPath:kSearchErrorPath] objectAtIndex:0]:@"";
            }
            else{
                if([[response valueForKeyPath:kSearchErrorPath] isKindOfClass:[NSString class]])
                    self.searchError        = @"";
            }
        }
    }
    else{
        if([response isKindOfClass:[NSString class]])// Network error
            self.searchError    = response;
    }
}
@end
