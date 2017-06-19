//
//  DataManager.h
//  PickThePic
//
//  Created by Lakshmi Thulasiram on 19/06/17.
//  Copyright © 2017 Lakshmi Thulasiram. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject
+(instancetype)sharedManager;
-(void)saveSearchStringToRecentsList:(NSString *)searchStr;
-(NSArray *)retrieveRecentsList;
+ (void)saveData;
+ (void)loadData;
@end
