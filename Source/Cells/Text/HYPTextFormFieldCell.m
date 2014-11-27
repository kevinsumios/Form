//
//  HYPTextFormFieldCell.m

//
//  Created by Elvis Nunez on 07/10/14.
//  Copyright (c) 2014 Hyper. All rights reserved.
//

#import "HYPTextFormFieldCell.h"

@interface HYPTextFormFieldCell () <HYPTextFormFieldDelegate>

@property (nonatomic, strong) HYPTextFormField *textField;

@end

@implementation HYPTextFormFieldCell

#pragma mark - Initializers

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;

    [self.contentView addSubview:self.textField];
    [self.contentView addSubview:self.iconButton];
    [self.iconButton setImage:nil forState:UIControlStateNormal];
    [self.iconButton addTarget:self action:@selector(focusAction) forControlEvents:UIControlEventTouchUpInside];

    return self;
}

#pragma mark - Getters

- (HYPTextFormField *)textField
{
    if (_textField) return _textField;

    _textField = [[HYPTextFormField alloc] initWithFrame:[self frameForTextField]];
    _textField.formFieldDelegate = self;

    return _textField;
}

#pragma mark - Private headers

- (void)updateFieldWithDisabled:(BOOL)disabled
{
    self.textField.enabled = !disabled;
}

- (void)updateWithField:(HYPFormField *)field
{
    self.textField.hidden          = (field.sectionSeparator);
    self.textField.inputValidator  = [self.field inputValidator];
    self.textField.formatter       = [self.field formatter];
    self.textField.typeString      = field.typeString;
    self.textField.enabled         = !field.disabled;
    self.textField.valid           = field.valid;
    self.textField.rawText         = [self rawTextForField:field];
}

- (void)validate
{
    [self.textField setValid:[self.field validate]];
}

- (NSString *)rawTextForField:(HYPFormField *)field
{
    if (field.fieldValue && field.type == HYPFormFieldTypeFloat) {

        NSNumber *value = field.fieldValue;

        if ([field.fieldValue isKindOfClass:[NSString class]]) {
            NSMutableString *fieldValue = [field.fieldValue mutableCopy];
            [fieldValue replaceOccurrencesOfString:@","
                                        withString:@"."
                                           options:NSCaseInsensitiveSearch
                                             range:NSMakeRange(0, [fieldValue length])];
            NSNumberFormatter *formatter = [NSNumberFormatter new];
            formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
            value = [formatter numberFromString:fieldValue];
        }

        return [NSString stringWithFormat:@"%.2f", [value floatValue]];
    }

    return field.fieldValue;
}

#pragma mark - Actions

- (void)focusAction
{
    [self.textField becomeFirstResponder];
}

- (void)clearAction
{
    self.field.fieldValue = nil;
    [self updateWithField:self.field];
    [self.iconButton setImage:nil forState:UIControlStateNormal];
    [self.iconButton addTarget:self action:@selector(focusAction) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Private methods

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.textField.frame = [self frameForTextField];
}

- (CGRect)frameForTextField
{
    CGFloat marginX = HYPTextFormFieldCellMarginX;
    CGFloat marginTop = HYPTextFormFieldCellTextFieldMarginTop;
    CGFloat marginBotton = HYPTextFormFieldCellTextFieldMarginBottom;

    CGFloat width  = CGRectGetWidth(self.frame) - (marginX * 2);
    CGFloat height = CGRectGetHeight(self.frame) - marginTop - marginBotton;
    CGRect  frame  = CGRectMake(marginX, marginTop, width, height);

    return frame;
}

#pragma mark - HYPTextFormFieldDelegate

- (void)textFormFieldDidBeginEditing:(HYPTextFormField *)textField
{
    [self.iconButton setImage:[UIImage imageNamed:@"ic_mini_clear"] forState:UIControlStateNormal];
    [self.iconButton addTarget:self action:@selector(clearAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)textFormFieldDidEndEditing:(HYPTextFormField *)textField
{
    if (self.textField.rawText) {
        [self.textField setValid:[self.field validate]];
    }

    [self.iconButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    [self.iconButton setImage:nil forState:UIControlStateNormal];
    [self.iconButton addTarget:self action:@selector(focusAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)textFormField:(HYPTextFormField *)textField didUpdateWithText:(NSString *)text
{
    self.field.fieldValue = text;

    [self.iconButton setImage:[UIImage imageNamed:@"ic_mini_clear"] forState:UIControlStateNormal];
    [self.iconButton addTarget:self action:@selector(clearAction) forControlEvents:UIControlEventTouchUpInside];

    if (!self.textField.valid) {
        [self.textField setValid:[self.field validate]];
    }

    if ([self.delegate respondsToSelector:@selector(fieldCell:updatedWithField:)]) {
        [self.delegate fieldCell:self updatedWithField:self.field];
    }
}

@end
