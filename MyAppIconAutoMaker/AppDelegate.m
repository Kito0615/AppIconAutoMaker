//
//  AppDelegate.m
//  MyAppIconAutoMaker
//
//  Created by AnarL on 12/9/15.
//  Copyright © 2015 AnarL. All rights reserved.
//

#import "AppDelegate.h"

#define CORNER_RADIUS_PERCENT 0.2237

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"savePath"]) {
        self.pathFiled.stringValue = NSHomeDirectory();
    } else {
        self.pathFiled.stringValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"savePath"];
    }
    [self.platformSelection selectItemAtIndex:0];

}
- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (IBAction)selectSavePath:(NSButton *)sender {
    
    _openPanel = [NSOpenPanel openPanel];
    _openPanel.canChooseFiles = NO;
    _openPanel.canChooseDirectories = YES;
    _openPanel.directoryURL = [NSURL URLWithString:NSHomeDirectory()];
    _openPanel.allowsMultipleSelection = NO;
    [_openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSOKButton) {
            self.pathFiled.stringValue = [[[_openPanel URLs] objectAtIndex:0] path];
        }
        [[NSUserDefaults standardUserDefaults] setObject:[[[_openPanel URLs] objectAtIndex:0] path] forKey:@"savePath"];
        
        
    }];
}

- (IBAction)platformSelected:(NSComboBox *)sender {
    NSLog(@"platform selected index:%ld", (long)sender.indexOfSelectedItem);
    [self.roundedCheckButton setHidden:!(sender.indexOfSelectedItem == 4)];
    self.roundedCheckButton.state = 0;
    self.BigIcon.layer.cornerRadius = 0;
}

- (IBAction)roundedChecked:(NSButton *)sender {
    if (sender.state) {
        self.BigIcon.layer.cornerRadius = CORNER_RADIUS_PERCENT * self.BigIcon.frame.size.width;
    }else {
        self.BigIcon.layer.cornerRadius = 0;
    }
}



- (IBAction)Generate:(NSButton *)sender {
    
    if (!self.BigIcon.image || self.platformSelection.indexOfSelectedItem == -1) {
        
        NSAlert * alert = [NSAlert alertWithMessageText:@"Please drag an image into the Red Border View Or select a platform." defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
        alert.alertStyle = NSWarningAlertStyle;
        
        [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
            
        }];
        
        return;
    } else {
        [self generateIconsWithImage:self.BigIcon.image];
    }
    
}

- (void)generateIconsWithImage:(NSImage *)image
{
    
    NSString * plistPath = [[NSBundle mainBundle] pathForResource:@"SizeFile.plist" ofType:nil];
    
    NSArray * sizeArr = [[NSArray alloc] initWithContentsOfFile:plistPath];
    
    NSDictionary * iPhoneSizeDict = sizeArr[0];
    
    NSArray * iPhoneSizeKeys = [iPhoneSizeDict allKeys];
    
    NSDictionary * iPadSizeDict = sizeArr[1];
    
    NSArray * iPadSizeKeys = [iPadSizeDict allKeys];
    
    NSDictionary * appleWatchDict = sizeArr[2];
    
    NSArray * appleWatchSizeKeys = [appleWatchDict allKeys];
    
    NSDictionary * macOSXSizeDict = sizeArr[3];
    
    NSArray * macOSXSizeKeys = [macOSXSizeDict allKeys];
    
    NSDictionary * iOSLaunchImageDict = sizeArr[4];
    
    NSArray * iOSLaunchSizeKeys = [iOSLaunchImageDict allKeys];
    
    NSLog(@"%ld", self.platformSelection.indexOfSelectedItem);
    
    switch (self.platformSelection.indexOfSelectedItem) {
        case 0:
            [self outputImage:image InfoDict:iPhoneSizeDict keysArr:iPhoneSizeKeys];
            break;
        case 1:
            [self outputImage:image InfoDict:iPadSizeDict keysArr:iPadSizeKeys];
            break;
        case 2:
            [self outputImage:image InfoDict:iPhoneSizeDict keysArr:iPhoneSizeKeys];
            [self outputImage:image InfoDict:iPadSizeDict keysArr:iPadSizeKeys];
            break;
        case 3:
            [self outputImage:image InfoDict:appleWatchDict keysArr:appleWatchSizeKeys];
            break;
        case 4:
            [self outputImage:image InfoDict:macOSXSizeDict keysArr:macOSXSizeKeys];
            break;
        case 5:
            [self outputImage:image InfoDict:iOSLaunchImageDict keysArr:iOSLaunchSizeKeys];
        default:
            break;
    }
}

- (void)outputImage:(NSImage *)image InfoDict:(NSDictionary *)infoDict keysArr:(NSArray *)keysArr
{
    NSView * view = [NSView new];
    
    CGFloat scale = [view convertSizeToBacking:CGSizeMake(1, 1)].width;
    
    for (NSString * sizeKey in keysArr) {
        
        NSDictionary * iconInfoDict = [infoDict objectForKey:sizeKey];
        
        NSString * iconSizeString = [iconInfoDict objectForKey:@"Dimensions"];
        
        NSSize iconSize = NSSizeFromString(iconSizeString);
        
        NSString * iconName = [iconInfoDict objectForKey:@"Name"];
        
        [self outputImage:image withSize:CGSizeMake(iconSize.width / scale, iconSize.height / scale) andName:iconName];
        
    }
    
    NSLog(@"%@", [NSString stringWithFormat:@"file://%@", self.pathFiled.stringValue]);
    
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://%@", self.pathFiled.stringValue]]];
    
}


- (void)outputImage:(NSImage *)image withSize:(NSSize)size andName:(NSString *)name
{
    NSData * imageData = [[self drawImage:image withSize:size] TIFFRepresentation];
    
    NSData * outputData = [[NSBitmapImageRep imageRepWithData:imageData] representationUsingType:NSPNGFileType properties:@{}];
    
    NSString * filePath = [self.pathFiled.stringValue stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", name]];
    
    [outputData writeToFile:filePath atomically:YES];
    
}

- (NSImage *)drawImage:(NSImage *)image withSize:(NSSize)size
{
    NSBezierPath * path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(0, 0, size.width, size.height) xRadius:size.width*CORNER_RADIUS_PERCENT yRadius:size.height*CORNER_RADIUS_PERCENT];
    
    NSImage * returnImage = [[NSImage alloc] initWithSize:size];
    
    [returnImage lockFocus];
    
    if (self.roundedCheckButton.state) {
        [path addClip];
    }
    
    [image drawInRect:NSMakeRect(0, 0, size.width, size.height) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
    
    [returnImage unlockFocus];
    
    return returnImage;
}



@end
