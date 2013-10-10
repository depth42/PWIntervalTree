//
//  PWIntervalTreeNode.m
//  PWFoundation
//
//

#import "PWIntervalTreeNode-Private.h"

@implementation PWIntervalTreeNode 

#pragma mark Managing life cycle

- (id)initWithObject:(id)object
            lowValue:(double)lowValue
           highValue:(double)highValue
{
    if(self = [super init])
    {
        _object = object;
        _lowValue = lowValue;
        _highValue = highValue;
        
        _key = lowValue;
        _high = highValue;
        _maxHigh = highValue;
    }
    
    return self;
}

#pragma mark Overlapping interval tree nodes

- (BOOL)overlapsWithIntervalWithLowValue:(double)lowValue
                               highValue:(double)highValue
{
    BOOL overlaps;
    
    if (_key <= lowValue)
        overlaps = (lowValue <= _high);
    else
        overlaps = (_key <= highValue);
    
    return overlaps;
}

#pragma mark Accessing dot representation

- (NSString*)dotRepresentation
{
    NSMutableString* dotRepresentation;

    if(_object)
    {
        dotRepresentation = [[NSMutableString alloc] init];
        
        [dotRepresentation appendFormat:@"%ld [%@ label=\"%ld - %ld\" fontsize=12 %@];\n", (long)_key, @"shape=box", (long)_key,
         (long)_high, _isRed ? @"color=\"0.000 1.000 1.000\"" : @"color=\"0.000 0.000 0.000\""];
        if(_leftNode)
        {
            NSString* leftNodeDotRepresentation = _leftNode.dotRepresentation;
            if(leftNodeDotRepresentation)
            {
                [dotRepresentation appendFormat:@"%@", leftNodeDotRepresentation];
                if(_key != _leftNode.key && _leftNode.key != _parentNode.key)
                    [dotRepresentation appendFormat:@"%ld -> %ld;\n", (long)_key, (long)_leftNode.key];
            }
        }
        if(_rightNode && _rightNode->_object)
        {
            NSString* rightNodeDotRepresentation = _rightNode.dotRepresentation;
            if(rightNodeDotRepresentation)
            {
                [dotRepresentation appendFormat:@"%@", rightNodeDotRepresentation];
                if(_key != _rightNode.key && _rightNode.key != _parentNode.key)
                    [dotRepresentation appendFormat:@"%ld -> %ld;\n", (long)_key, (long)_rightNode.key];
            }
        }
    }
    
    return dotRepresentation;
}

@end