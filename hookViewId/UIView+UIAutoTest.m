//
//  UIView+UIAutoTest.m
//  AFWealth
//
//  Created by Yinxl on 11/1/16.
//  Copyright © 2016 opensource. All rights reserved.
//

#import "UIView+UIAutoTest.h"
#import "UIResponder+UIAutoTest.h"
#import <objc/runtime.h>
#define IDTAG   @"id_"

@implementation UIView (UIAutoTest)


+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleSelector:@selector(accessibilityIdentifier) withAnotherSelector:@selector(tb_accessibilityIdentifier)];
        [self swizzleSelector:@selector(accessibilityLabel) withAnotherSelector:@selector(tb_accessibilityLabel)];
    });
}

+ (void)swizzleSelector:(SEL)originalSelector withAnotherSelector:(SEL)swizzledSelector
{
    Class aClass = [self class];
    
    Method originalMethod = class_getInstanceMethod(aClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(aClass, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(aClass,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(aClass,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

#pragma mark - Method Swizzling

- (NSString *)tb_accessibilityIdentifier
{
    NSString *accessibilityIdentifier = [self tb_accessibilityIdentifier];
    if (accessibilityIdentifier.length > 0 && [[accessibilityIdentifier substringToIndex:3] isEqualToString:IDTAG]) {
        return accessibilityIdentifier;
    }
    else if ([accessibilityIdentifier isEqualToString:@"null"]) {
        accessibilityIdentifier = @"";
    }
    
    NSString *labelStr = [self.superview findNameWithInstance:self];
    
    if (labelStr && ![labelStr isEqualToString:@""]) {
        labelStr = [NSString stringWithFormat:@"%@%@",IDTAG,labelStr];
    }
    else {
        if ([self isKindOfClass:[UILabel class]]) {//UILabel 使用 text
            labelStr = [NSString stringWithFormat:@"%@%@",IDTAG,((UILabel *)self).text?:@""];
        }
        else if ([self isKindOfClass:[UIImageView class]]) {//UIImageView 使用 image 的 imageName
            labelStr = [NSString stringWithFormat:@"%@%@",IDTAG,((UIImageView *)self).image.accessibilityIdentifier?:[NSString stringWithFormat:@"image%ld",(long)((UIImageView *)self).tag]];
        }
        else if ([self isKindOfClass:[UIButton class]]) {//UIButton 使用 button 的 text 和 image
            labelStr = [NSString stringWithFormat:@"%@%@%@",IDTAG,((UIButton *)self).titleLabel.text?:@"",((UIButton *)self).imageView.image.accessibilityIdentifier?:@""];
        }
        else if (accessibilityIdentifier) {// 已有 label，则在此基础上再次添加更多信息
            labelStr = [NSString stringWithFormat:@"%@%@",IDTAG,accessibilityIdentifier];
        }
        if ([self isKindOfClass:[UIButton class]]) {
            self.accessibilityValue = [NSString stringWithFormat:@"%@%@",IDTAG,((UIButton *)self).currentBackgroundImage.accessibilityIdentifier?:@""];
        }
    }
    if ([labelStr isEqualToString:IDTAG] || [labelStr isEqualToString:[NSString stringWithFormat:@"%@null",IDTAG ]]) {
        labelStr = @"";
    }
    [self setAccessibilityIdentifier:labelStr];
    return labelStr;
}

- (NSString *)tb_accessibilityLabel
{
    if ([self isKindOfClass:[UIImageView class]]) {//UIImageView 特殊处理
        NSString *name = [self.superview findNameWithInstance:self];
        if (name) {
            self.accessibilityIdentifier = [NSString stringWithFormat:@"%@%@",IDTAG,name];
        }
        else {
            self.accessibilityIdentifier = [NSString stringWithFormat:@"%@%@",IDTAG,((UIImageView *)self).image.accessibilityIdentifier?:[NSString stringWithFormat:@"image%ld",(long)((UIImageView *)self).tag]];
        }
    }
    if ([self isKindOfClass:[UITableViewCell class]]) {//UITableViewCell 特殊处理
        self.accessibilityIdentifier = [NSString stringWithFormat:@"%@%@",IDTAG,((UITableViewCell *)self).reuseIdentifier];
    }
    return [self tb_accessibilityLabel];
}

@end
