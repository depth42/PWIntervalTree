//
//  PWIntervalTree-Private.h
//  PWFoundation
//
//

#import "PWIntervalTree.h"

@interface PWIntervalTree (Private)

#pragma mark Inserting and deleting nodes

- (void)insertNode:(PWIntervalTreeNode*)node;
- (id)deleteNode:(PWIntervalTreeNode*)node;
- (void)balanceNode:(PWIntervalTreeNode*)node;

#pragma mark Accessing preceding and succeeding node 

- (PWIntervalTreeNode*)nodePrecedingNode:(PWIntervalTreeNode*)node;
- (PWIntervalTreeNode*)nodeSucceedingNode:(PWIntervalTreeNode*)node;

#pragma mark Rotating nodes

- (void)rotateNodeToLeft:(PWIntervalTreeNode*)node;
- (void)rotateNodeToRight:(PWIntervalTreeNode*)node;

#pragma mark Updating and checking max highs

- (void)updateMaxHighForNodeAndAncestors:(PWIntervalTreeNode*)node;
- (void)checkMaxHighOfNode:(PWIntervalTreeNode*)node;

#pragma mark Accessing dot representation

- (NSString*)dotRepresentation;
- (void)showInGraphvizWithName:(NSString*)name;

@end
