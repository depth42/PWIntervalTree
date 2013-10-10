//
//  PWIntervalTreeNode-Private.h
//  PWFoundation
//
//

#import "PWIntervalTreeNode.h"

@interface PWIntervalTreeNode ()

#pragma mark Accessing properties

@property (nonatomic, readwrite, strong) PWIntervalTreeNode*    leftNode;
@property (nonatomic, readwrite, strong) PWIntervalTreeNode*    rightNode;
@property (nonatomic, readwrite, weak)   PWIntervalTreeNode*    parentNode;

@property (nonatomic, readwrite)        double                  key;
@property (nonatomic, readwrite)        double                  high;
@property (nonatomic, readwrite)        double                  maxHigh;
@property (nonatomic, readwrite)        BOOL                    isRed; 

#pragma mark Overlapping interval tree nodes

- (BOOL)overlapsWithIntervalWithLowValue:(double)lowValue
                               highValue:(double)highValue;

#pragma mark Accessing dot representation

@property (nonatomic, readonly) NSString* dotRepresentation;

@end
