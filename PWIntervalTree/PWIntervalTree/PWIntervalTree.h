//
//  PWIntervalTree.h
//  PWFoundation
//
// Simple Obj-C Implementation of an interval tree.
// Inspired by Emin Martinian's C-implementation ( http://web.mit.edu/~emin/www.old/source_code/cpp_trees )

@class PWIntervalTreeNode;

@interface PWIntervalTree : NSObject 

#pragma mark Adding and removing objects

- (PWIntervalTreeNode*)addObject:(id)object
         forIntervalWithLowValue:(double)lowValue
                       highValue:(double)highValue;

- (id)removeObjectForIntervalWithLowValue:(double)lowValue
                                highValue:(double)highValue;

- (id)deleteNode:(PWIntervalTreeNode*)node;

#pragma mark Accessing objects and nodes

- (void)enumerateNodesInIntervalWithLowValue:(double)lowValue
                                   highValue:(double)highValue
                                  usingBlock:(void (^)(PWIntervalTreeNode* node, BOOL* stop))block;

- (NSSet*)objectsInIntervalWithLowValue:(double)lowValue
                              highValue:(double)highValue;

- (NSSet*)nodesInIntervalWithLowValue:(double)lowValue
                            highValue:(double)highValue;

- (PWIntervalTreeNode*)nodeForIntervalWithLowValue:(double)lowValue
                                         highValue:(double)highValue;

@end
