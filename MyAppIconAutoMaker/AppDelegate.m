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

typedef enum {
    APPLE_PLATFORM_LAUNCH_SCREEN = 0,
    APPLE_PLATFORM_IPHONE = 1,
    APPLE_PLATFORM_IPAD = 1 << 1,
    APPLE_PLATFORM_MAC = 1 << 2,
    APPLE_PLATFORM_WATCH = 1 << 3,
    APPLE_PLATFORM_CARPLAY = 1 << 4,
    APPLE_PLATFORM_SCALE = 1 << 5,
}APPLE_PLATFORM;


@interface AppDelegate ()
{
    APPLE_PLATFORM _platform;
}

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
    [self.window setTitlebarAppearsTransparent:YES];

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
    
    NSOpenPanel * _openPanel = [NSOpenPanel openPanel];
    _openPanel.canChooseFiles = NO;
    _openPanel.canChooseDirectories = YES;
    _openPanel.directoryURL = [NSURL fileURLWithPath:NSHomeDirectory()];
    _openPanel.allowsMultipleSelection = NO;
    NSInteger result = [_openPanel runModal];
    if (result == NSModalResponseOK) {
        self.pathFiled.stringValue = [[[_openPanel URLs] objectAtIndex:0] path];
        [[NSUserDefaults standardUserDefaults] setObject:[[[_openPanel URLs] objectAtIndex:0] path] forKey:@"savePath"];
    }
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
    switch (sender.indexOfSelectedItem) {
        case 0:
        {
            _platform = APPLE_PLATFORM_IPHONE;
        }
            break;
        case 1:
        {
            _platform = APPLE_PLATFORM_IPAD;
        }
            break;
        case 2:
        {
            _platform = APPLE_PLATFORM_IPHONE | APPLE_PLATFORM_IPAD;
        }
            break;
        case 3:
        {
            _platform = APPLE_PLATFORM_WATCH;
        }
            break;
        case 4:
        {
            _platform = APPLE_PLATFORM_MAC;
        }
            break;
        case 5:
        {
            _platform = APPLE_PLATFORM_LAUNCH_SCREEN;
        }
            break;
        case 7:
        {
            _platform = APPLE_PLATFORM_CARPLAY;
        }
            break;
        case 6:
        {
            _platform = APPLE_PLATFORM_SCALE;
        }
            break;
    }
    [self.roundedCheckButton setHidden:!(_platform == APPLE_PLATFORM_MAC)];
    self.roundedCheckButton.state = 0;
    self.BigIcon.layer.cornerRadius = 0;
    BOOL scale = _platform == APPLE_PLATFORM_SCALE;
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
        
        NSAlert * alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"Alert", nil)];
        [alert addButtonWithTitle:@"OK"];
        alert.alertStyle = NSAlertStyleWarning;
        [alert runModal];
        
        return;
    } else {
        _platform == APPLE_PLATFORM_SCALE ? [self generateScaleImage:self.BigIcon.image] : [self generateIconsWithImage:self.BigIcon.image platform:_platform];
    }
    [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:[self encodingPathString]]];
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
    
    [self outputImage:image withSize:scale1x scale:1 name:@"Image" idiom:@"origin"];
    [self outputImage:image withSize:scale2x scale:2 name:@"Image@2x" idiom:@"scale2x"];
    [self outputImage:image withSize:scale3x scale:3 name:@"Image@3x" idiom:@"scale3x"];
}

#define APPLE_PLATFORM_IPHONE_KEY @"iphone"
#define APPLE_PLATFORM_IPAD_KEY @"ipad"
#define APPLE_PLATFORM_WATCH_KEY @"watch"
#define APPLE_PLATFORM_MAC_KEY @"mac"
#define APPLE_PLATFORM_CAR_KEY @"car"
#define APPLE_PLATFORM_SCALE_1 @"1x"
#define APPLE_PLATFORM_SCALE_2 @"2x"
#define APPLE_PLATFORM_SCALE_3 @"3x"

- (NSArray *)sizeArrayWithPlatformName:(APPLE_PLATFORM)platform
{
    NSString * jsonFile = [[NSBundle mainBundle] pathForResource:@"Template" ofType:@"json"];
    NSDictionary * jsonData = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:jsonFile] options:NSJSONReadingMutableContainers error:nil];
    NSArray * imageScaleSizeArray = [jsonData objectForKey:@"images"];
    NSMutableArray * resultArray = [NSMutableArray array];
    NSMutableArray * keyArray = [NSMutableArray array];
    if (platform & APPLE_PLATFORM_IPHONE) {
        [keyArray addObject:APPLE_PLATFORM_IPHONE_KEY];
    }
    if (platform & APPLE_PLATFORM_MAC) {
        [keyArray addObject:APPLE_PLATFORM_MAC_KEY];
    }
    if (platform & APPLE_PLATFORM_IPAD) {
        [keyArray addObject:APPLE_PLATFORM_IPAD_KEY];
    }
    if (platform & APPLE_PLATFORM_WATCH) {
        [keyArray addObject:APPLE_PLATFORM_WATCH_KEY];
    }
    if (platform & APPLE_PLATFORM_CARPLAY) {
        [keyArray addObject:APPLE_PLATFORM_CAR_KEY];
    }
    for (NSDictionary * imageDict in imageScaleSizeArray) {
        if ([keyArray containsObject:[imageDict objectForKey:@"idiom"]]) {
            [resultArray addObject:imageDict];
        }
    }
    return [NSArray arrayWithArray:resultArray];
}

- (void)generateIconsWithImage:(NSImage *)image platform:(APPLE_PLATFORM)platform
{
    
    NSString * plistPath = [[NSBundle mainBundle] pathForResource:@"SizeFile.plist" ofType:nil];
    
    NSArray * sizeArr = [[NSArray alloc] initWithContentsOfFile:plistPath];
    
    NSArray * iconSizeArray = [self sizeArrayWithPlatformName:platform];
    
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
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:@"MyAppIconAutoGenerator" forKey:@"author"];
    [info setObject:@1 forKey:@"version"];
    [self.contents setObject:info forKey:@"info"];
    
    switch (self.platformSelection.indexOfSelectedItem) {
        case 5:
            [self outputImage:image InfoDict:iOSLaunchImageDict keysArr:iOSLaunchSizeKeys idiom:@"iphone"];
        default:
        {
            for (NSDictionary * imgInfo in iconSizeArray) {
                NSString * sizeString = [imgInfo objectForKey:@"size"];
                NSString * scaleString = [imgInfo objectForKey:@"scale"];
                NSInteger multiplyLoc = [sizeString rangeOfString:@"x"].location;
                NSInteger scaleValue = [[scaleString substringToIndex:1] integerValue];
                if (multiplyLoc != NSNotFound) {
                    NSString * imgName = [@"icon_" stringByAppendingFormat:@"%@@%@", sizeString, scaleString];
                    NSSize imgSize = NSMakeSize([[sizeString substringToIndex:multiplyLoc] doubleValue], [[sizeString substringFromIndex:multiplyLoc+1] doubleValue]);
                    [self outputImage:image withSize:imgSize scale:scaleValue name:imgName idiom:[imgInfo objectForKey:@"idiom"]];
                }
            }
        }
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
                              [[self appiconsetPathString] stringByRemovingPercentEncoding]];
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
        
        [self outputImage:image withSize:iconSize scale:scale name:iconName idiom:idiom];
        
    }
    
    LLog(@"%@", [NSString stringWithFormat:@"file://%@", [self encodingPathString]]);
}


- (void)outputImage:(NSImage *)image withSize:(NSSize)originSize scale:(NSInteger)scale name:(NSString *)name idiom:(NSString *)idiom
{
    NSData * imageData = [[self drawImage:image withSize:NSMakeSize(originSize.width * scale, originSize.height * scale)] TIFFRepresentation];
    
    NSData * outputData = [[NSBitmapImageRep imageRepWithData:imageData] representationUsingType:NSPNGFileType properties:@{}];
    
    NSString * filePath = [[[self appiconsetPathString] stringByRemovingPercentEncoding] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", name]];
    
    [outputData writeToFile:filePath atomically:YES];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@.png", name] forKey:@"filename"];
    [dict setObject:idiom forKey:@"idiom"];
    
    [dict setObject:[NSNumber numberWithInteger:scale] forKey:@"scale"];
    
    NSString *sizeString = [NSString stringWithFormat:@"%.0fx%.0f", originSize.width, originSize.height];
    
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
    
    [image drawInRect:NSMakeRect(0, 0, size.width, size.height) fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0 respectFlipped:YES hints:nil];
    
    [returnImage unlockFocus];
    
    return returnImage;
}



@end
