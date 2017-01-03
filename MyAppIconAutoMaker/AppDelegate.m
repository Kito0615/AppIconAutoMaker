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

@property (strong, nonatomic) NSMutableDictionary *contents;
@property (strong, nonatomic) NSMutableArray *images;
@property (strong, nonatomic) NSArray *idioms;

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

-(NSString *)encodingPathString {
    return [self.pathFiled.stringValue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

-(NSString *)appiconsetPathString {
    return [[self encodingPathString] stringByAppendingString:@"/AppIcon.appiconset"];
}

-(NSURL *)appiconsetPath {
    return [NSURL URLWithString:[NSString stringWithFormat:@"file://%@", [self appiconsetPathString]]];
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
    
    NSLog(@"pathFiled: %@", [self encodingPathString]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@", [self encodingPathString]]];
    
    NSLog(@"url %@", url);
    
    NSError *error;
    
    [[NSFileManager defaultManager] createDirectoryAtURL:[self appiconsetPath] withIntermediateDirectories:YES attributes:nil error:&error];
    
    if (error) {
        NSLog(@"创建文件夹错误：%@", error.description);
    }
    
    self.contents = [NSMutableDictionary dictionary];
    self.images = [NSMutableArray array];
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:@"xcode" forKey:@"author"];
    [info setObject:@1 forKey:@"version"];
    [self.contents setObject:info forKey:@"info"];
    
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
    
    [self.contents setObject:self.images forKey:@"images"];
    
    
    
    NSLog(@"contents: %@", self.contents);
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.contents
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *fileName = [NSString stringWithFormat:@"%@/Contents.json",
                              [[self appiconsetPathString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [jsonString writeToFile:fileName atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
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
    
    NSLog(@"%@", [NSString stringWithFormat:@"file://%@", [self encodingPathString]]);
    
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://%@", [self encodingPathString]]]];
    
}


- (void)outputImage:(NSImage *)image withSize:(NSSize)size andName:(NSString *)name
{
    NSData * imageData = [[self drawImage:image withSize:size] TIFFRepresentation];
    
    NSData * outputData = [[NSBitmapImageRep imageRepWithData:imageData] representationUsingType:NSPNGFileType properties:@{}];
    
    NSString * filePath = [[[self appiconsetPathString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", name]];
    
    [outputData writeToFile:filePath atomically:YES];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@.png", name] forKey:@"filename"];
    [dict setObject:@"mac" forKey:@"idiom"];
    
    NSRange range = [name rangeOfString:@"@"];
    NSLog(@"range %lu", (unsigned long)range.location);
    if (range.location == NSNotFound) {
        
         [dict setObject:@"1x" forKey:@"scale"];
        
        
        
    }else {
        
        NSString *scale = [name substringFromIndex:range.location+1];
        [dict setObject:scale forKey:@"scale"];
 
    }
    
    NSString *sizeString = [name substringFromIndex:5];
    
    range = [sizeString rangeOfString:@"@"];
    if (range.location != NSNotFound) {
        sizeString = [sizeString substringToIndex:range.location];
    }
    
    [dict setObject:sizeString forKey:@"size"];
    [self.images addObject:dict];
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
