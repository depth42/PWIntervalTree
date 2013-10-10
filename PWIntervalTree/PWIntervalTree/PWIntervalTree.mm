//
//  PWIntervalTree.m
//  PWFoundation
//
//

#import "PWIntervalTree-Private.h"

#import "PWInlineVector.hpp"
#import "PWIntervalTreeNode-Private.h"
#import <float.h>
#import <algorithm>
#import <vector>

struct PWIntervalTreeRecursionNode
{
    __unsafe_unretained PWIntervalTreeNode* startNode;
    NSUInteger          parentIndex;
    BOOL                tryRightBranch;
};

typedef PWFoundation::inline_vector<PWIntervalTreeRecursionNode, 32> PWIntervalTreeRecursionNodes;

#pragma mark -

@implementation PWIntervalTree
{
    PWIntervalTreeNode* _rootNode;
    PWIntervalTreeNode* _nilNode;
    NSUInteger          _enumerationCount;
}

#pragma mark Managing life cycle

- (id)init
{
    if(self = [super init])
    {
        _nilNode = [[PWIntervalTreeNode alloc] init];
        _nilNode.leftNode = _nilNode;
        _nilNode.rightNode = _nilNode;
        _nilNode.parentNode = _nilNode;
        _nilNode.isRed = NO;
        _nilNode.key = -DBL_MAX;
        _nilNode.high = -DBL_MAX;
        _nilNode.maxHigh = -DBL_MAX;
        _nilNode.object = nil;
        
        _rootNode = [[PWIntervalTreeNode alloc] init];
        _rootNode.leftNode = _nilNode;
        _rootNode.rightNode = _nilNode;
        _rootNode.parentNode = _nilNode;
        _rootNode.isRed = NO;
        _rootNode.key = DBL_MAX;
        _rootNode.high = DBL_MAX;
        _rootNode.maxHigh = DBL_MAX;
        _rootNode.object = nil;
    }
    return self;
}

#pragma mark Adding and removing objects

- (PWIntervalTreeNode*)addObject:(id)object forIntervalWithLowValue:(double)lowValue highValue:(double)highValue
{
    PWIntervalTreeNode* newNode = nil;
    
    if(_enumerationCount == 0)
    {
        newNode = [[PWIntervalTreeNode alloc] initWithObject:object lowValue:lowValue highValue:highValue];
        [self insertNode:newNode];
        
        [self updateMaxHighForNodeAndAncestors:newNode.parentNode];
        
        newNode.isRed = YES;
        while(newNode.parentNode.isRed)  // use sentinel instead of checking for rootNode
        {
            PWIntervalTreeNode* grandParentNode = newNode.parentNode.parentNode;
            if(newNode.parentNode == grandParentNode.leftNode)
            {
                PWIntervalTreeNode* rightOfGrandParentNode = grandParentNode.rightNode;
                if(rightOfGrandParentNode.isRed)
                {
                    newNode.parentNode.isRed = NO;
                    rightOfGrandParentNode.isRed = NO;
                    grandParentNode.isRed = YES;
                    newNode = grandParentNode;
                }
                else
                {
                    if(newNode == newNode.parentNode.rightNode)
                    {
                        newNode = newNode.parentNode;
                        [self rotateNodeToLeft:newNode];
                    }
                    newNode.parentNode.isRed = NO;
                    grandParentNode.isRed = YES;
                    [self rotateNodeToRight:newNode.parentNode.parentNode];
                } 
            }
            else
            { 
                NSAssert(newNode.parentNode == grandParentNode.rightNode, nil);
                PWIntervalTreeNode* leftOfGrandParentNode = grandParentNode.leftNode;
                if(leftOfGrandParentNode.isRed)
                {
                    newNode.parentNode.isRed = NO;
                    leftOfGrandParentNode.isRed = NO;
                    grandParentNode.isRed = YES;
                    newNode = grandParentNode;
                }
                else
                {
                    if(newNode == newNode.parentNode.leftNode)
                    {
                        newNode = newNode.parentNode;
                        [self rotateNodeToRight:newNode];
                    }
                    newNode.parentNode.isRed = NO;
                    grandParentNode.isRed = YES;
                    [self rotateNodeToLeft:newNode.parentNode.parentNode];
                } 
            }
        }
        _rootNode.leftNode.isRed = NO;
        
#ifndef NDEBUG
        [self checkAssertions];
#endif  
        NSAssert(!_nilNode.isRed, @"nilNode not red in addObject:forIntervalWithLowValue:highValue:");
        NSAssert(!_rootNode.isRed, @"rootNode not red in addObject:forIntervalWithLowValue:highValue:");
        NSAssert((_nilNode.maxHigh == -DBL_MAX), @"nilNode.maxHigh != -DBL_MAX in addObject:forIntervalWithLowValue:highValue:");
    }
    else        
        [NSException raise:NSInternalInconsistencyException
                    format:@"Trying to mutate interval tree by adding object during enumeration."];
    
    return(newNode);
}

- (id)removeObjectForIntervalWithLowValue:(double)aLowValue highValue:(double)aHighValue
{
    id removedObject = nil;
    
    if(_enumerationCount == 0)
    {
        PWIntervalTreeNode* node = [self nodeForIntervalWithLowValue:aLowValue highValue:aHighValue];
        if(node)
            removedObject = [self deleteNode:node];
    }
    else
        [NSException raise:NSInternalInconsistencyException
                    format:@"Trying to mutate interval tree by removing object during enumeration."];

    return removedObject;
}

- (void)insertNode:(PWIntervalTreeNode*)node
{
    node.rightNode = _nilNode;
    node.leftNode = node.rightNode;
    
    PWIntervalTreeNode* newParentNode = _rootNode;
    PWIntervalTreeNode* iterationNode = _rootNode.leftNode;
    while(iterationNode != _nilNode)
    {
        newParentNode = iterationNode;
        if(iterationNode.key > node.key)
            iterationNode = iterationNode.leftNode;
        else
        {
            NSAssert(iterationNode.key <= node.key, nil);
            iterationNode = iterationNode.rightNode;
        }
    }
    
    node.parentNode = newParentNode;
    if((newParentNode == _rootNode) || (newParentNode.key > node.key))
        newParentNode.leftNode = node;
    else
        newParentNode.rightNode = node;
    
    NSAssert(!_nilNode.isRed, @"nilNode not red in insertNode:");
    NSAssert((_nilNode.maxHigh == -DBL_MAX), @"nilNode.maxHigh != -DBL_MAX in insertNode:");
}

- (void)balanceNode:(PWIntervalTreeNode*)node
{
    PWIntervalTreeNode* rootLeftNode = _rootNode.leftNode;
    while((!node.isRed) && (rootLeftNode != node))
    {
        PWIntervalTreeNode* parentNode = node.parentNode;
        if(node == parentNode.leftNode)
        {
            PWIntervalTreeNode* parentRightNode = parentNode.rightNode;
            if(parentRightNode.isRed)
            {
                parentRightNode.isRed = NO;
                parentNode.isRed = YES;
                [self rotateNodeToLeft:parentNode];
                parentRightNode = parentNode.rightNode;
            }
            if((!parentRightNode.rightNode.isRed) && (!parentRightNode.leftNode.isRed))
            { 
                parentRightNode.isRed = YES;
                node = parentNode;
            } 
            else
            {
                if(!parentRightNode.rightNode.isRed)
                {
                    parentRightNode.leftNode.isRed = NO;
                    parentRightNode.isRed = YES;
                    [self rotateNodeToRight:parentRightNode];
                    parentRightNode = parentNode.rightNode;
                }
                parentRightNode.isRed = parentNode.isRed;
                parentNode.isRed = NO;
                parentRightNode.rightNode.isRed = NO;
                [self rotateNodeToLeft:parentNode];
                node = rootLeftNode;
            }
        }
        else
        {
            PWIntervalTreeNode* parentLeftNode = parentNode.leftNode;
            if (parentLeftNode.isRed)
            {
                parentLeftNode.isRed = NO;
                parentNode.isRed = YES;
                [self rotateNodeToRight:parentNode];
                parentLeftNode = parentNode.leftNode;
            }
            if((!parentLeftNode.rightNode.isRed) && (!parentLeftNode.leftNode.isRed))
            { 
                parentLeftNode.isRed = YES;
                node = parentNode;
            }
            else
            {
                if(!parentLeftNode.leftNode.isRed)
                {
                    parentLeftNode.rightNode.isRed = NO;
                    parentLeftNode.isRed = YES;
                    [self rotateNodeToLeft:parentLeftNode];
                    parentLeftNode = parentNode.leftNode;
                }
                parentLeftNode.isRed = parentNode.isRed;
                parentNode.isRed = NO;
                parentLeftNode.leftNode.isRed = NO;
                [self rotateNodeToRight:parentNode];
                node = rootLeftNode;
            }
        }
    }
    node.isRed = NO;
    
#ifndef NDEBUG
    [self checkAssertions];
#endif
    NSAssert(!_nilNode.isRed, @"nilNode not black in balanceNode:");
    NSAssert((_nilNode.maxHigh == -DBL_MAX),  @"nilNode.maxHigh != -DBL_MAX in balanceNode:");
}

- (id)deleteNode:(PWIntervalTreeNode*)node
{
    NSAssert(_enumerationCount == 0, nil);
    
    id object = node.object;
    
    PWIntervalTreeNode* spliceOutNode = ((node.leftNode == _nilNode) || (node.rightNode == _nilNode)) ? node : [self nodeSucceedingNode:node];
    PWIntervalTreeNode* spliceOutChildNode = (spliceOutNode.leftNode == _nilNode) ? spliceOutNode.rightNode : spliceOutNode.leftNode;
    spliceOutChildNode.parentNode = spliceOutNode.parentNode;
    if(_rootNode == spliceOutNode.parentNode)
        _rootNode.leftNode = spliceOutChildNode;
    else
    {
        PWIntervalTreeNode* spliceOutParentNode = spliceOutNode.parentNode;
        if(spliceOutNode == spliceOutParentNode.leftNode)
            spliceOutParentNode.leftNode = spliceOutChildNode;
        else
            spliceOutParentNode.rightNode = spliceOutChildNode;
    }
    if(spliceOutNode != node)
    {
        NSAssert(spliceOutNode != _nilNode, nil);

        spliceOutNode.maxHigh = -DBL_MAX;
        spliceOutNode.leftNode = node.leftNode;
        spliceOutNode.rightNode = node.rightNode;
        spliceOutNode.parentNode = node.parentNode;

        node.rightNode.parentNode = spliceOutNode;
        node.leftNode.parentNode = node.rightNode.parentNode;
        PWIntervalTreeNode* parentNode = node.parentNode;
        if(node == parentNode.leftNode)
            parentNode.leftNode = spliceOutNode; 
        else
            parentNode.rightNode = spliceOutNode;
    
        [self updateMaxHighForNodeAndAncestors:spliceOutChildNode.parentNode]; 
        if(!(spliceOutNode.isRed)) 
        {
            spliceOutNode.isRed = node.isRed;
            [self balanceNode:spliceOutChildNode];
        } 
        else
            spliceOutNode.isRed = node.isRed; 

#ifndef NDEBUG
        [self checkAssertions];
#endif
        NSAssert(!_nilNode.isRed,@"nilNode not black in deleteNode:");
        NSAssert(_nilNode.maxHigh == -DBL_MAX, @"nilNode.maxHigh != -DBL_MAX in deleteNode:");
    }
    else
    {
        [self updateMaxHighForNodeAndAncestors:spliceOutChildNode.parentNode];
        if(!(spliceOutNode.isRed))
            [self balanceNode:spliceOutChildNode];

#ifndef NDEBUG
        [self checkAssertions];
#endif
        NSAssert(!_nilNode.isRed, @"nilNode not black in deleteNode:");
        NSAssert(_nilNode.maxHigh == -DBL_MAX, @"nilNode.maxHigh != -DBL_MAX in deleteNode:");
    }
    
    return object;
}

#pragma mark Accessing objects and nodes

- (void)enumerateNodesInIntervalWithLowValue:(double)aLowValue 
                                   highValue:(double)aHighValue
                                  usingBlock:(void (^)(PWIntervalTreeNode* node, BOOL* stop))block
{
    NSParameterAssert(block);
    
    ++_enumerationCount;
    
    // To improve performance it would be nice if the recursion node stack could live on the stack with a maximum size.
    // If the size becomes too small it could be copied to the heap.
    
    PWIntervalTreeRecursionNodes recursionNodeStack;
    
    NSUInteger recursionNodeStackTop = 1;
    NSUInteger currentParentIndex    = 0;

    recursionNodeStack[0].startNode = NULL; 

    PWIntervalTreeNode* node = _rootNode.leftNode;
    
    __block BOOL stop = NO;
    
    while(node != _nilNode)
    {
        if([node overlapsWithIntervalWithLowValue:aLowValue highValue:aHighValue]) 
        {
            block(node, &stop);
            if(stop)
                break;
            
            recursionNodeStack[currentParentIndex].tryRightBranch = YES;
        }
        if(node.leftNode.maxHigh >= aLowValue)  // implies x != nil 
        {             
            recursionNodeStack[recursionNodeStackTop].startNode = node;
            recursionNodeStack[recursionNodeStackTop].tryRightBranch = NO;
            recursionNodeStack[recursionNodeStackTop].parentIndex = currentParentIndex;
            currentParentIndex = recursionNodeStackTop++;
            node = node.leftNode;
        } else
            node = node.rightNode;
        
        while((node == _nilNode) && (recursionNodeStackTop > 1))
            if(recursionNodeStack[--recursionNodeStackTop].tryRightBranch)
            {
                node = recursionNodeStack[recursionNodeStackTop].startNode.rightNode;
                currentParentIndex = recursionNodeStack[recursionNodeStackTop].parentIndex;
                recursionNodeStack[currentParentIndex].tryRightBranch = YES;
            }
    }
    
    --_enumerationCount;
}

- (NSSet*)nodesInIntervalWithLowValue:(double)aLowValue highValue:(double)aHighValue
{
    NSMutableSet* nodesInInterval = [[NSMutableSet alloc] init];
    
    [self enumerateNodesInIntervalWithLowValue:aLowValue 
                                     highValue:aHighValue
                                    usingBlock:^(PWIntervalTreeNode* node, BOOL* stop) {
                                        [nodesInInterval addObject:node];
                                    }];
    
    return nodesInInterval;
}

- (NSSet*)objectsInIntervalWithLowValue:(double)aLowValue highValue:(double)aHighValue
{
    NSMutableSet* objectsInInterval = [[NSMutableSet alloc] init];
    
    [self enumerateNodesInIntervalWithLowValue:aLowValue 
                                     highValue:aHighValue
                                    usingBlock:^(PWIntervalTreeNode* node, BOOL* stop) {
                                        [objectsInInterval addObject:node.object];
                                    }];
    
    return objectsInInterval;
}

- (PWIntervalTreeNode*)nodeForIntervalWithLowValue:(double)aLowValue highValue:(double)aHighValue
{
    PWIntervalTreeNode* node = nil;
    
    PWIntervalTreeNode* currentNode = _rootNode.leftNode;
    while(currentNode != _nilNode) 
    {
        if ((currentNode.lowValue == aLowValue) && (currentNode.highValue == aHighValue)) 
        {
            node = currentNode;
            break;
        } 
        else
        {
            if (aLowValue < currentNode.lowValue)
                currentNode = currentNode.leftNode;
            else
                currentNode = currentNode.rightNode;
        }
    }
    
    return node;    
}

#pragma mark Accessing preceding and succeeding node 

- (PWIntervalTreeNode*)nodePrecedingNode:(PWIntervalTreeNode*)node
{
    PWIntervalTreeNode* predecessorNode;

    if((predecessorNode = node.leftNode) != _nilNode)    // assignment to predecessorNode is intentional
        while(predecessorNode.rightNode != _nilNode)     // returns the maximum of the left subtree of node
            predecessorNode = predecessorNode.rightNode;
    else
    {
        predecessorNode = node.parentNode;
        while(node == predecessorNode.leftNode)
        { 
            if(predecessorNode == _rootNode)
            {
                predecessorNode = _nilNode; 
                break;
            }
            node = predecessorNode;
            predecessorNode = predecessorNode.parentNode;
        }
    }
    
    return predecessorNode;
}

- (PWIntervalTreeNode*)nodeSucceedingNode:(PWIntervalTreeNode*)node
{
    PWIntervalTreeNode* successorNode;
    
    if((successorNode = node.rightNode) != _nilNode) // assignment to successorNode is intentional
        while(successorNode.leftNode != _nilNode)        // returns the minium of the right subtree of node
            successorNode = successorNode.leftNode;
    else 
    {
        successorNode = node.parentNode;
        while(node == successorNode.rightNode)          // sentinel used instead of checking for nil
        { 
            node = successorNode;
            successorNode = successorNode.parentNode;
        }
        if(successorNode == _rootNode)
            successorNode = _nilNode;
    }
    
    return successorNode;
}

#pragma mark Rotating nodes

- (void)rotateNodeToLeft:(PWIntervalTreeNode*)node
{
    PWIntervalTreeNode* parentNode = node.parentNode;
    PWIntervalTreeNode* rightNode = node.rightNode;
    node.rightNode = rightNode.leftNode;
    
    if(rightNode.leftNode != _nilNode)
        rightNode.leftNode.parentNode = node; // used to use sentinel here
    rightNode.parentNode = parentNode;   
    
    if(node == parentNode.leftNode)
        parentNode.leftNode = rightNode;
    else
        parentNode.rightNode = rightNode;

    rightNode.leftNode = node;
    node.parentNode = rightNode;
    
    node.maxHigh = fmax(node.leftNode.maxHigh, fmax(node.rightNode.maxHigh, node.high));
    rightNode.maxHigh = fmax(node.maxHigh, fmax(rightNode.rightNode.maxHigh, rightNode.high));
    
#ifndef NDEBUG
    [self checkAssertions];
#endif
    NSAssert(!_nilNode.isRed, @"nilNode not red in rotateNodeToLeft:");
    NSAssert(_nilNode.maxHigh == -DBL_MAX, @"nilNode.maxHigh != -DBL_MAX in rotateNodeToLeft:");
}

- (void)rotateNodeToRight:(PWIntervalTreeNode*)node
{
    PWIntervalTreeNode* parentNode = node.parentNode;
    PWIntervalTreeNode* leftNode = node.leftNode;
    node.leftNode = leftNode.rightNode;
    
    if(_nilNode != leftNode.rightNode)
        leftNode.rightNode.parentNode = node;   // used to use sentinel here
    leftNode.parentNode = parentNode;
    
    if(node == parentNode.leftNode)
        parentNode.leftNode = leftNode;
    else
        parentNode.rightNode = leftNode;
    
    leftNode.rightNode = node;
    node.parentNode = leftNode;
    
    node.maxHigh = fmax(node.leftNode.maxHigh, fmax(node.rightNode.maxHigh, node.high));
    leftNode.maxHigh = fmax(leftNode.leftNode.maxHigh, fmax(node.maxHigh, leftNode.high));
    
#ifndef NDEBUG
    [self checkAssertions];
#endif
    NSAssert(!_nilNode.isRed, @"nilNode not red in rotateNodeToRight:");
    NSAssert(_nilNode.maxHigh == -DBL_MAX, @"nilNode.maxHigh != -DBL_MAX in rotateNodeToRight:");
}

#pragma mark Updating and checking max highs

- (void)updateMaxHighForNodeAndAncestors:(PWIntervalTreeNode*)node
{
    while(node != _rootNode)
    {
        node.maxHigh = fmax(node.high, fmax(node.leftNode.maxHigh, node.rightNode.maxHigh));
        node = node.parentNode;
    }
    
#ifndef NDEBUG
    [self checkAssertions];
#endif
}

- (BOOL)checkMaxHighOfNode:(PWIntervalTreeNode*)node currentHigh:(double)currentHigh match:(BOOL)match
{
    if(node != _nilNode) {
        match = [self checkMaxHighOfNode:node.leftNode currentHigh:currentHigh match:match] ? YES : match;
        NSAssert(node.high <= currentHigh, nil);
        if (node.high == currentHigh)
            match = YES;
        match = [self checkMaxHighOfNode:node.rightNode currentHigh:currentHigh match:match] ? YES : match;
    }
    
    return match;
}

- (void)checkMaxHighOfNode:(PWIntervalTreeNode*)node
{
    if(node != _nilNode)
    {
        [self checkMaxHighOfNode:node.leftNode];
        NSAssert([self checkMaxHighOfNode:node currentHigh:node.maxHigh match:NO] > 0, nil);
        [self checkMaxHighOfNode:node.rightNode];
    }
}

- (void)checkAssertions
{
    NSAssert(_nilNode.key == -DBL_MAX, @"nilNode.key != -DBL_MAX");
    NSAssert(_nilNode.high == -DBL_MAX, @"nilNode.high != -DBL_MAX");
    NSAssert(_nilNode.maxHigh == -DBL_MAX, @"nilNode.maxHigh != -DBL_MAX");
    
    NSAssert(_rootNode.key == DBL_MAX, @"rootNode.key != DBL_MAX");
    NSAssert(_rootNode.high == DBL_MAX, @"rootNode.high != DBL_MAX");
    NSAssert(_rootNode.maxHigh == DBL_MAX, @"rootNode.maxHigh != DBL_MAX");
    
    NSAssert(_nilNode.object == nil, @"nilNode.object != nil");
    NSAssert(_rootNode.object == nil, @"rootNode.object != nil");
    
    NSAssert(_nilNode.isRed == NO, @"nilNode.isRed != NO");
    NSAssert(_rootNode.isRed == NO, @"rootNode.isRed != NO");
    
    //[self checkMaxHighOfNode:rootNode.leftNode];
}

#pragma mark Accessing dot representation

- (NSString*)dotRepresentation
{
    return _rootNode.leftNode.dotRepresentation;
}

- (void)showInGraphvizWithName:(NSString*)name
{
    NSString* dotRepresentation = self.dotRepresentation;
    dotRepresentation = [NSString stringWithFormat:@"digraph RBTree {\n%@\n}\n", dotRepresentation];
    
    NSMutableString* path = [NSMutableString stringWithCapacity:50];
    [path setString:[NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.dot", name]]];
    [path replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange(0, path.length)];
    
    if([dotRepresentation writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil])
        system([[NSString stringWithFormat:@"open -b com.att.graphviz '%@'", path] UTF8String]);
}

@end
