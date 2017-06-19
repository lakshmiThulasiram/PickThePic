//
//  DataManager.m
//  PickThePic
//
//  Created by Lakshmi Thulasiram on 19/06/17.
//  Copyright © 2017 Lakshmi Thulasiram. All rights reserved.
//

#import "DataManager.h"
#define kDBName @"dataStore.db"
#define kRecentsSearchKey @"RecentSearch"

static DataManager *sharedInstance;
@interface DataManager()
@property (nonatomic, strong)NSMutableArray        *recentSearchArray;

@end
@implementation DataManager

+(instancetype)sharedManager {
    
    if(!sharedInstance) {
        sharedInstance = [[DataManager alloc] init];
    }
    return sharedInstance;
}
-(instancetype)init {
    self = [super init];
    if(self){
        self.recentSearchArray  = [NSMutableArray array];
    }
    return self;
}
#pragma mark - Data Manager

+ (void)loadData {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kDBName])
    {
        NSData *data = [[NSMutableData alloc] initWithData:[[NSUserDefaults standardUserDefaults] objectForKey:kDBName]];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        sharedInstance = [unarchiver decodeObjectForKey:kDBName];
        [unarchiver finishDecoding];
    }
}

+ (void)saveData {
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:sharedInstance forKey:kDBName];
    [archiver finishEncoding];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kDBName];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

#pragma mark - Coder & Deocoder
- (id)initWithCoder:(NSCoder *)aDecoder {
    self.recentSearchArray =  [aDecoder decodeObjectForKey:kRecentsSearchKey];
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.recentSearchArray forKey:kRecentsSearchKey];
}
-(void)saveSearchStringToRecentsList:(NSString *)searchStr
{
    if([sharedInstance.recentSearchArray containsObject:searchStr])
       [sharedInstance.recentSearchArray removeObject:searchStr];
    [sharedInstance.recentSearchArray insertObject:searchStr atIndex:0];
    [DataManager saveData];
}
-(NSArray *)retrieveRecentsList
{
    return sharedInstance.recentSearchArray;
}

@end
