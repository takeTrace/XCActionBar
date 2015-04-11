//
//  XCActionBarPresetStateController.m
//  XCActionBar
//
//  Created by Pedro Gomes on 10/04/2015.
//  Copyright (c) 2015 Pedro Gomes. All rights reserved.
//

#import "NSIndexSet+XCCircularIndexSet.h"

#import "XCActionBarCommandProcessor.h"
#import "XCActionBarPresetDataSource.h"
#import "XCActionBarPresetStateController.h"
#import "XCActionInterface.h"
#import "XCActionPreset.h"
#import "XCActionPresetSource.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
@interface XCActionBarPresetStateController ()

@property (nonatomic, copy) NSString *searchExpression;

@property (nonatomic, weak) id<XCActionBarCommandProcessor> commandProcessor;
@property (nonatomic      ) XCActionBarPresetDataSource *dataSource;

@property (nonatomic, weak) NSTextField *inputField;
@property (nonatomic, weak) NSTableView *tableView;

@property (nonatomic, weak) id<XCActionInterface> action;

@property (nonatomic) NSIndexSet *dataIndexSet;

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
@implementation XCActionBarPresetStateController

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
- (instancetype)initWithCommandProcessor:(id<XCActionBarCommandProcessor>)processor
                               tableView:(NSTableView *)tableView
                              inputField:(NSTextField *)inputField

{
    if((self = [super init])) {
        self.commandProcessor = processor;
        self.tableView        = tableView;
        self.inputField       = inputField;
    }
    return self;
}

#pragma mark - XCActionBarCommandHandler

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
- (void)enter
{
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
- (void)enterWithAction:(id<XCActionInterface, XCActionPresetSource>)action
{
    self.action     = action;
    self.dataSource = [[XCActionBarPresetDataSource alloc] initWithPresetSource:action];
    
    id delegate = self.inputField.delegate;
    self.inputField.delegate = nil;
    
    self.inputField.stringValue       = (self.searchExpression ?: @"");
    self.inputField.placeholderString = NSLocalizedString(@"Choose a preset ...", @"");
    
    self.inputField.delegate = delegate;
    
    self.tableView.delegate   = self.dataSource;
    self.tableView.dataSource = self.dataSource;

    self.dataIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self.dataSource numberOfObjects])];
    [self.tableView reloadData];
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
- (void)exit
{
    self.action     = nil;
    self.dataSource = nil;
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
- (BOOL)handleCursorUpCommand
{
    [self.dataIndexSet selectPreviousIndex];
    [self selectSearchResultAtIndex:[self.dataIndexSet selectedIndex]];
    
    return YES;
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
- (BOOL)handleCursorDownCommand
{
    [self.dataIndexSet selectNextIndex];
    [self selectSearchResultAtIndex:[self.dataIndexSet selectedIndex]];
    
    return YES;
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
- (BOOL)handleDoubleClickCommand
{
    return [self handleEnterCommand];
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
- (BOOL)handleEnterCommand
{
    id<XCActionPreset> selectedPreset = [self retrieveSelectedPreset];
    XCReturnFalseUnless(selectedPreset != nil);
    
    return [self.commandProcessor executeActionPreset:selectedPreset];
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
- (BOOL)handleTabCommand
{
    return NO;
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
- (BOOL)handleCancelCommand
{
    return [self.commandProcessor cancel];
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
- (BOOL)handleTextInputCommand:(NSString *)text
{
    self.searchExpression = text;
    
    // maybe search the presets?
    return NO;
}

#pragma mark - Helpers

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
- (void)selectSearchResultAtIndex:(NSInteger)indexToSelect
{
    [self.dataSource updateSelectedObjectIndex:indexToSelect];
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:indexToSelect]
                byExtendingSelection:NO];
    [self.tableView scrollRowToVisible:indexToSelect];
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
- (id<XCActionPreset>)retrieveSelectedPreset
{
    id<XCActionPreset> preset = [self.dataSource selectedObject];
    return (preset ?: nil);
}

@end
