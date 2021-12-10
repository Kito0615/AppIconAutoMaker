//
//  AppDelegate.h
//  MyAppIconAutoMaker
//
//  Created by AnarL on 12/9/15.
//  Copyright © 2015 AnarL. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RedBorderImageView.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    CALayer * _bigIconLayer;
}
@property (weak) IBOutlet NSComboBox *platformSelection;

@property (weak) IBOutlet RedBorderImageView *BigIcon;
@property (weak) IBOutlet NSTextField *pathFiled;
@property (weak) IBOutlet NSButton *roundedCheckButton;
@property (weak) IBOutlet NSButton *zoomInCheckButton;
@property (weak) IBOutlet NSButton *zoomOutCheckButton;



- (IBAction)Generate:(NSButton *)sender;
- (IBAction)selectSavePath:(NSButton *)sender;
- (IBAction)zoomCheck:(id)sender;
@end

