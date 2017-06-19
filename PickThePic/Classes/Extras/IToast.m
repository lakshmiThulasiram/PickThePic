//
//  IToast.m
//  IToast
//
//  Created by Sahana D on 7/15/16.
//  Copyright © 2016 Sahana D. All rights reserved.
//

#import "IToast.h"
#import "AppMacros.h"
#define kDefaultAnimationDuration 0.5
@interface IToast ()
{
    //label where user string is displayed.
    UILabel *lblDisplay;
}

//string to display in itoast.
@property (nonatomic ,strong) NSString *strToShow;
//duration for how long itoast should be displayed.
@property (nonatomic ,assign) CGFloat displayDuration;

@end

@implementation IToast


/**
 To display tips

 @param strToDisplay Tips string
 */

+ (void)displayItoastToolTipWithMessage:(NSString *)strToDisplay {
    IToast *toast = [[IToast alloc]initWithText:strToDisplay andDisplayTime:0];
    [toast displayTips];
}

//class method for initilizing Itoast.
+ (void)displayItoastWithMessage:(NSString *)strToDisplay andDisplayTime:(CGFloat)displayTime {
    
    IToast *toast = [[IToast alloc]initWithText:strToDisplay andDisplayTime:displayTime];
    
    [toast displayItoast];
}

//Itoast initilization method.
- (id)initWithText:(NSString *)strToDisplay andDisplayTime:(CGFloat)displayTime {
    
    self = [super init];
    
    if (self) {
        
        self.strToShow = strToDisplay;
        
        self.displayDuration = displayTime;
        
        [self createIToastView];
        
        [self setBackgroundColor:[UIColor grayColor]];
    }
    
    return self;
}

//Itoast view are created
- (void)createIToastView {
    self.layer.cornerRadius = 5.0f;
    self.layer.borderWidth = 1.5f;
    self.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.layer.shadowRadius = 8.0f;
    self.layer.shadowOpacity = 1.5f;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    
    CGRect frameSize = [[UIApplication sharedApplication] keyWindow].bounds;
    
    CGRect expectedFrame = [self.strToShow boundingRectWithSize:
                            CGSizeMake(frameSize.size.width-80, 9999)
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                      attributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                  [UIFont systemFontOfSize:13.0f], NSFontAttributeName, nil]context:nil];
   
    int containerHeight = expectedFrame.size.height>50?expectedFrame.size.height+10:50;
    
    self.frame = CGRectMake(20, frameSize.size.height-containerHeight-10, frameSize.size.width-40, containerHeight);
    
    lblDisplay = [[UILabel alloc]initWithFrame:CGRectMake(self.bounds.origin.x + 20, 5,
                                                          self.frame.size.width - 40, 40)];
    
    lblDisplay.numberOfLines = 0;
    
    lblDisplay.text = self.strToShow;
    
    lblDisplay.font = [UIFont systemFontOfSize:13.0f];
    
    lblDisplay.textAlignment = NSTextAlignmentCenter;
    
    lblDisplay.textColor = [UIColor whiteColor];
    
    CGRect lblFrame = lblDisplay.frame;
    
    lblFrame.size = expectedFrame.size;
    
    lblFrame.size.height = ceil(lblFrame.size.height);
    
    lblFrame.size.width = self.frame.size.width-10;
    
    lblFrame.origin.x = self.frame.size.width / 2 - lblFrame.size.width / 2;
    
    lblFrame.origin.y = (self.frame.size.height - lblFrame.size.height) / 2;
    
    lblDisplay.frame = lblFrame;
    
    [self addSubview:lblDisplay];
}

//method to display iToast.
- (void)displayItoast {
    [[[[UIApplication sharedApplication] windows] firstObject] addSubview:self];
    
    self.alpha = 0;
    [UIView animateWithDuration:kDefaultAnimationDuration
                        animations:^{
                            self.alpha = 1;
                        }completion:^(BOOL finished) {
                            if (finished) {
                                [UIView animateWithDuration:kDefaultAnimationDuration/2 delay:self.displayDuration options:UIViewAnimationOptionCurveEaseInOut animations:^{
                                    self.alpha = 0;
                                } completion:^(BOOL finished) {
                                    [self removeFromSuperview];
                                }];
                            }
                        }];
}


/**
 To display tips
 */
-(void)displayTips {
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    [[[[UIApplication sharedApplication] windows] firstObject] addSubview:backgroundView];
    backgroundView.frame = [[[UIApplication sharedApplication] windows] firstObject].bounds;
    [backgroundView addSubview:self];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [backgroundView addGestureRecognizer:tapGesture];
    
}

-(void)tapAction:(UITapGestureRecognizer *)gesture {
    [gesture.view removeFromSuperview];
}

@end
