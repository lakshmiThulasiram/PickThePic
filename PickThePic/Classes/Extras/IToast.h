//
//  IToast.h
//  IToast
//
//  Created by Sahana D on 7/15/16.
//  Copyright © 2016 Sahana D. All rights reserved.
//


// Itoast to display short message to user for a second(s) and remove.

#import <UIKit/UIKit.h>

@interface IToast : UIView

//method to display itoast
+ (void)displayItoastToolTipWithMessage:(NSString *)strToDisplay;
+ (void)displayItoastWithMessage:(NSString *)strToDisplay andDisplayTime:(CGFloat )displayTime;
//set message and duration to display the message.
- (id)initWithText:(NSString *)strToDisplay andDisplayTime:(CGFloat )displayTime;

@end
