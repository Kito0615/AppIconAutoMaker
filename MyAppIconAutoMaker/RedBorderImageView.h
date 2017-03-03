//
//  DropImageView.h
//  MyAppIconAutoMaker
//
//  Created by AnarL on 12/15/15.
//  Copyright © 2015 AnarL. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#define CORNER_RADIUS_PERCENT 0.125

@interface RedBorderImageView : NSImageView

@property (assign, nonatomic, getter=isRoundCorner) BOOL roundCorner;

@end
