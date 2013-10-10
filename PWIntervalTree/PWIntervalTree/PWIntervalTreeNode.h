//
//  PWIntervalTreeNode.h
//  PWFoundation
//
//

@class PWIntervalTreeNode;

@interface PWIntervalTreeNode : NSObject

#pragma mark Managing life cycle

- (id)initWithObject:(id)object
            lowValue:(double)lowValue
           highValue:(double)highValue;

#pragma mark Accessing properties

@property (nonatomic, readwrite, strong)   id      object;
@property (nonatomic, readonly)            double  lowValue;
@property (nonatomic, readonly)            double  highValue;

@end
