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
    NSOpenPanel * _openPanel;
}
@property (weak) IBOutlet NSComboBox *platformSelection;

@property (weak) IBOutlet RedBorderImageView *BigIcon;
@property (weak) IBOutlet NSTextField *pathFiled;
@property (weak) IBOutlet NSButton *roundedCheckButton;

- (IBAction)Generate:(NSButton *)sender;
- (IBAction)selectSavePath:(NSButton *)sender;
@end

