//
//  AppDelegate.m
//  MyAppIconAutoMaker
//
//  Created by AnarL on 12/9/15.
//  Copyright © 2015 AnarL. All rights reserved.
//

#import "AppDelegate.h"

#ifndef CORNER_RADIUS_PERCENT
#define CORNER_RADIUS_PERCENT 0.2237
#endif

#ifdef DEBUG

#define LLog(format, ...) do { \
NSLog(@"<%s : %d> %s\n", \
    [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], \
    __LINE__, __func__); \
NSLog(format, ##__VA_ARGS__); \
NSLog(@"-------\n"); \
} while (0)

#else
#define LLog(format, ...) do{ \
} while(0)
#endif


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
    return [self.pathFiled stringValue];
}

-(NSString *)appiconsetPathString {
    if ([self.platformSelection indexOfSelectedItem] == 6) {
        return [self encodingPathString];
    }
    return [[self encodingPathString] stringByAppendingString:@"/AppIcon.appiconset"];
}

-(NSURL *)appiconsetPath {
    return [NSURL fileURLWithPath:[self appiconsetPathString]];
}

- (IBAction)selectSavePath:(NSButton *)sender {
    
    _openPanel = [NSOpenPanel openPanel];
    _openPanel.canChooseFiles = NO;
    _openPanel.canChooseDirectories = YES;
    _openPanel.directoryURL = [NSURL fileURLWithPath:NSHomeDirectory()];
    _openPanel.allowsMultipleSelection = NO;
    [_openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSOKButton) {
            self.pathFiled.stringValue = [[[_openPanel URLs] objectAtIndex:0] path];
        }
        [[NSUserDefaults standardUserDefaults] setObject:[[[_openPanel URLs] objectAtIndex:0] path] forKey:@"savePath"];
        
        
    }];
}

- (IBAction)zoomCheck:(id)sender {
    if (sender == self.zoomInCheckButton) {
        self.zoomOutCheckButton.state = NSOffState;
    } else {
        self.zoomInCheckButton.state = NSOffState;
    }
    [sender setState:NSOnState];
}

- (IBAction)platformSelected:(NSComboBox *)sender {
    LLog(@"platform selected index:%ld", (long)sender.indexOfSelectedItem);
    [self.roundedCheckButton setHidden:!(sender.indexOfSelectedItem == 4)];
    self.roundedCheckButton.state = 0;
    self.BigIcon.layer.cornerRadius = 0;
    BOOL scale = sender.indexOfSelectedItem == 6;
    self.zoomInCheckButton.hidden = !scale;
    self.zoomOutCheckButton.hidden = !scale;
}

- (IBAction)roundedChecked:(NSButton *)sender {
    [self.BigIcon setRoundCorner:[sender state]];
    if (sender.state) {
        self.BigIcon.layer.cornerRadius = CORNER_RADIUS_PERCENT * self.BigIcon.frame.size.width;
    }else {
        self.BigIcon.layer.cornerRadius = 0;
    }
}

- (IBAction)Generate:(NSButton *)sender {
    
    if (!self.BigIcon.image || self.platformSelection.indexOfSelectedItem == -1) {
        
        NSAlert * alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Alert", nil) defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
        alert.alertStyle = NSWarningAlertStyle;
        
        [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
            
        }];
        
        return;
    } else {
        [self.platformSelection indexOfSelectedItem] == 6 ? [self generateScaleImage:self.BigIcon.image] : [self generateIconsWithImage:self.BigIcon.image];
    }
    
}

- (void)generateScaleImage:(NSImage *)image
{
    BOOL zoomIn = self.zoomInCheckButton.state;
    NSSize originSize = zoomIn ? image.size : NSMakeSize(image.size.width / 3, image.size.height / 3);
    NSSize scale1x = originSize;
    NSSize scale2x = NSMakeSize(originSize.width * 2, originSize.height * 2);
    NSSize scale3x = NSMakeSize(originSize.width * 3, originSize.height * 3);
    
    NSError *error;
    
    [[NSFileManager defaultManager] createDirectoryAtURL:[self appiconsetPath] withIntermediateDirectories:YES attributes:nil error:&error];
    
    if (error) {
        LLog(@"创建文件夹错误：%@", error.description);
    }
    
    [self outputImage:image withSize:scale1x andName:@"Image" idiom:@"origin"];
    [self outputImage:image withSize:scale2x andName:@"Image@2x" idiom:@"scale2x"];
    [self outputImage:image withSize:scale3x andName:@"Image@3x" idiom:@"scale3x"];
    
    [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:[self encodingPathString]]];
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
    
    LLog(@"%ld", self.platformSelection.indexOfSelectedItem);
    
    LLog(@"pathFiled: %@", [self encodingPathString]);
    
    NSURL * url = [NSURL fileURLWithPath:[self encodingPathString]];
    
    LLog(@"url %@", url);
    
    NSError *error;
    
    [[NSFileManager defaultManager] createDirectoryAtURL:[self appiconsetPath] withIntermediateDirectories:YES attributes:nil error:&error];
    
    if (error) {
        LLog(@"创建文件夹错误：%@", error.description);
    }
    
    self.contents = [NSMutableDictionary dictionary];
    self.images = [NSMutableArray array];
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:@"xcode" forKey:@"author"];
    [info setObject:@1 forKey:@"version"];
    [self.contents setObject:info forKey:@"info"];
    
    switch (self.platformSelection.indexOfSelectedItem) {
        case 0:
            [self outputImage:image InfoDict:iPhoneSizeDict keysArr:iPhoneSizeKeys idiom:@"iphone"];
            break;
        case 1:
            [self outputImage:image InfoDict:iPadSizeDict keysArr:iPadSizeKeys idiom:@"ipad"];
            break;
        case 2:
            [self outputImage:image InfoDict:iPhoneSizeDict keysArr:iPhoneSizeKeys idiom:@"iphone"];
            [self outputImage:image InfoDict:iPadSizeDict keysArr:iPadSizeKeys idiom:@"ipad"];
            break;
        case 3:
            [self outputImage:image InfoDict:appleWatchDict keysArr:appleWatchSizeKeys idiom:@"watch"];
            break;
        case 4:
            [self outputImage:image InfoDict:macOSXSizeDict keysArr:macOSXSizeKeys idiom:@"mac"];
            break;
        case 5:
            [self outputImage:image InfoDict:iOSLaunchImageDict keysArr:iOSLaunchSizeKeys idiom:@"iphone"];
        default:
            break;
    }
    
    [self.contents setObject:self.images forKey:@"images"];
    
    
    
    LLog(@"contents: %@", self.contents);
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.contents
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    if (! jsonData) {
        LLog(@"Got an error: %@", error);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *fileName = [NSString stringWithFormat:@"%@/Contents.json",
                              [[self appiconsetPathString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [jsonString writeToFile:fileName atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
    }
    
}

- (void)outputImage:(NSImage *)image InfoDict:(NSDictionary *)infoDict keysArr:(NSArray *)keysArr idiom:(NSString *)idiom
{
    NSView * view = [NSView new];
    
    CGFloat scale = [view convertSizeToBacking:CGSizeMake(1, 1)].width;
    
    for (NSString * sizeKey in keysArr) {
        
        NSDictionary * iconInfoDict = [infoDict objectForKey:sizeKey];
        
        NSString * iconSizeString = [iconInfoDict objectForKey:@"Dimensions"];
        
        NSSize iconSize = NSSizeFromString(iconSizeString);
        
        NSString * iconName = [iconInfoDict objectForKey:@"Name"];
        
        [self outputImage:image withSize:CGSizeMake(iconSize.width / scale, iconSize.height / scale) andName:iconName idiom:idiom];
        
    }
    
    LLog(@"%@", [NSString stringWithFormat:@"file://%@", [self encodingPathString]]);
    
    [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:[self encodingPathString]]];
    
}


- (void)outputImage:(NSImage *)image withSize:(NSSize)size andName:(NSString *)name idiom:(NSString *)idiom
{
    NSData * imageData = [[self drawImage:image withSize:size] TIFFRepresentation];
    
    NSData * outputData = [[NSBitmapImageRep imageRepWithData:imageData] representationUsingType:NSPNGFileType properties:@{}];
    
    NSString * filePath = [[[self appiconsetPathString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", name]];
    
    [outputData writeToFile:filePath atomically:YES];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@.png", name] forKey:@"filename"];
    [dict setObject:idiom forKey:@"idiom"];
    
    NSRange range = [name rangeOfString:@"@"];
    LLog(@"range %lu", (unsigned long)range.location);
    if (range.location == NSNotFound) {
        
         [dict setObject:@"1x" forKey:@"scale"];
    }else {
        
        NSString *scale = [name substringFromIndex:range.location+1];
        [dict setObject:scale forKey:@"scale"];
 
    }
    
    NSString *sizeString = name.length > 5 ? [name substringFromIndex:5] : @"";
    
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
