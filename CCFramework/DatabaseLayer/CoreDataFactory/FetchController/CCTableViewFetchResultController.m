//
//  CCTableViewFetchResultController.m
//  CCFramework
//
// Copyright (c) 2015 CC ( http://www.ccskill.com )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "CCTableViewFetchResultController.h"
#import "CoreDataManager.h"

@interface CCTableViewFetchResultController ()<UITableViewDataSource,NSFetchedResultsControllerDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, copy) NSString *cellReuseIdentifier;
@property (nonatomic, strong) NSFetchedResultsController *fetchResultController;

@end

@implementation CCTableViewFetchResultController

-(instancetype)initWithFetchRequest:(NSFetchRequest *)fetchRequest
                          tableView:(UITableView *)tableView
                cellReuseIdentifier:(NSString *)cellReuseIdentifier
                           delegate:(id<CCTableViewFetchResultControllerDelegate>)delegate
{
    self = [super init];
    if (self) {
        NSManagedObjectContext *manageContex = [[CoreDataManager sharedlnstance] mainContext];
        self.fetchResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:manageContex sectionNameKeyPath:nil cacheName:nil];
        self.fetchResultController.delegate = self;
        self.tableView = tableView;
        self.tableView.dataSource = self;
        self.cellReuseIdentifier = cellReuseIdentifier;
        self.delegate = delegate;
        self.reloadWhenDataChanged = NO;
        NSError *error;
        if (![self.fetchResultController performFetch:&error]) {
            NSLog(@"%s error is %@",__PRETTY_FUNCTION__,error);
        }
    }
    return self;
}

#pragma mark - private methods

-(NSArray *)sections
{
    return self.fetchResultController.sections;
}

-(id)objectAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchResultController objectAtIndexPath:indexPath];
    return object;
}

-(void)setPause:(BOOL)pause
{
    if (pause != _pause) {
        _pause = pause;
        if (_pause) {
            self.tableView.dataSource = nil;
        }else{
            self.tableView.dataSource = self;
            NSError *error;
            if (![self.fetchResultController performFetch:&error]) {
                NSLog(@"%s error is %@",__PRETTY_FUNCTION__,error);
            }
            [self.tableView reloadData];
        }
    }
}

#pragma mark - NSFetchedResultsControllerDelegate methods

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (!self.reloadWhenDataChanged) {
        [self.tableView beginUpdates];
    }
    if ([self.delegate respondsToSelector:@selector(tableFetchResultControllerWillChangedContent:)]) {
        [self.delegate tableFetchResultControllerWillChangedContent:self];
    }
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (self.reloadWhenDataChanged) {
        [self.tableView reloadData];
    }else{
        [self.tableView endUpdates];
    }
    if ([self.delegate respondsToSelector:@selector(tableFetchResultControllerDidChangedContent:)]) {
        [self.delegate tableFetchResultControllerDidChangedContent:self];
    }
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    if (!self.reloadWhenDataChanged) {
        switch (type) {
            case NSFetchedResultsChangeInsert:
                [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
            case NSFetchedResultsChangeMove:
                [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
                break;
            case NSFetchedResultsChangeUpdate:
                if ([self.tableView.indexPathsForVisibleRows containsObject:indexPath]) {
                    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                    if ([self.delegate respondsToSelector:@selector(tableFetchResultController:updateCell:withObject:atIndexPath:)]) {
                        [self.delegate tableFetchResultController:self updateCell:cell withObject:anObject atIndexPath:indexPath];
                    }else{
                        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    }
                }
                break;
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
                
            default:
                break;
        }
    }
}

-(void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if (!self.reloadWhenDataChanged) {
        switch (type) {
            case NSFetchedResultsChangeInsert:
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
            case NSFetchedResultsChangeMove:
                //not impliment
                break;
            case NSFetchedResultsChangeUpdate:
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
                
            default:
                break;
        }
    }
}

#pragma mark - UITableViewDataSource methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.fetchResultController.sections.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchResultController sections][section];
    return [sectionInfo numberOfObjects];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellReuseIdentifier forIndexPath:indexPath];
    id object = [self.fetchResultController objectAtIndexPath:indexPath];
    if([self.delegate respondsToSelector:@selector(tableFetchResultController:configureCell:withObject:atIndexPath:)]) {
        [self.delegate tableFetchResultController:self configureCell:cell withObject:object atIndexPath:indexPath];
    }
    return cell;
}

@end
