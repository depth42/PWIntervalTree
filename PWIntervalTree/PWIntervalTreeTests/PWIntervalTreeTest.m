//
//  PWIntervalTreeTest.m
//  PWFoundation
//
//

#import <XCTest/XCTest.h>

#import "PWIntervalTree.h"
#import "PWIntervalTreeNode.h"

@interface PWIntervalTreeTest : XCTestCase
@end

@implementation PWIntervalTreeTest

- (void)testIntervalTree
{
    PWIntervalTree* intervalTree = [[PWIntervalTree alloc] init];
    
    NSString* testObjectA = @"TestObject A";
    NSSet* setWithObjectA = [NSSet setWithObject:testObjectA];
    
    [intervalTree addObject:testObjectA forIntervalWithLowValue:2 highValue:4];
    XCTAssertEqualObjects([intervalTree objectsInIntervalWithLowValue:0 highValue:1], [NSSet set]);
    XCTAssertEqualObjects([intervalTree objectsInIntervalWithLowValue:1 highValue:2], setWithObjectA);
    XCTAssertEqualObjects([intervalTree objectsInIntervalWithLowValue:2.5 highValue:3.5], setWithObjectA);
    XCTAssertEqualObjects([intervalTree objectsInIntervalWithLowValue:4 highValue:5], setWithObjectA);
    XCTAssertEqualObjects([intervalTree objectsInIntervalWithLowValue:5 highValue:9], [NSSet set]);
}

- (void)testIntervalTreeAdditionBeforeRemoval
{
    PWIntervalTree* intervalTree = [[PWIntervalTree alloc] init];
    
    NSString* testObjectA = @"TestObject A";
    [intervalTree addObject:testObjectA forIntervalWithLowValue:2 highValue:5];
    NSString* testObjectB = @"TestObject B";
    [intervalTree addObject:testObjectB forIntervalWithLowValue:3 highValue:7];
    NSString* testObjectC = @"TestObject C";
    
    NSSet* setWithObjectA = [NSSet setWithObject:testObjectA];
    NSSet* setWithObjectB = [NSSet setWithObject:testObjectB];
    NSSet* setWithObjectC = [NSSet setWithObject:testObjectC];
    NSSet* setWithObjectsAB = [setWithObjectA setByAddingObjectsFromSet:setWithObjectB];
    NSSet* setWithObjectsBC = [setWithObjectB setByAddingObjectsFromSet:setWithObjectC];
    NSSet* setWithObjectsABC = [setWithObjectsAB setByAddingObjectsFromSet:setWithObjectC];
    
    XCTAssertEqualObjects([intervalTree objectsInIntervalWithLowValue:2.2 highValue:2.8], setWithObjectA);
    XCTAssertEqualObjects([intervalTree objectsInIntervalWithLowValue:3.2 highValue:4.8], setWithObjectsAB);
    XCTAssertEqualObjects([intervalTree objectsInIntervalWithLowValue:5.2 highValue:6.8], setWithObjectB);
    
    [intervalTree addObject:testObjectC forIntervalWithLowValue:4 highValue:6];

    XCTAssertEqualObjects([intervalTree objectsInIntervalWithLowValue:2.2 highValue:2.8], setWithObjectA);
    XCTAssertEqualObjects([intervalTree objectsInIntervalWithLowValue:3.2 highValue:3.8], setWithObjectsAB);
    XCTAssertEqualObjects([intervalTree objectsInIntervalWithLowValue:4.2 highValue:4.8], setWithObjectsABC);
    XCTAssertEqualObjects([intervalTree objectsInIntervalWithLowValue:5.2 highValue:5.8], setWithObjectsBC);
    XCTAssertEqualObjects([intervalTree objectsInIntervalWithLowValue:6.2 highValue:6.8], setWithObjectB);
    
    [intervalTree removeObjectForIntervalWithLowValue:4 highValue:6];
    
    XCTAssertEqualObjects([intervalTree objectsInIntervalWithLowValue:2.2 highValue:2.8], setWithObjectA);
    XCTAssertEqualObjects([intervalTree objectsInIntervalWithLowValue:3.2 highValue:4.8], setWithObjectsAB);
    XCTAssertEqualObjects([intervalTree objectsInIntervalWithLowValue:5.2 highValue:6.8], setWithObjectB);
}

- (void)testIntervalTreeAdditionAfterRemoval
{
    PWIntervalTree* intervalTree = [[PWIntervalTree alloc] init];
    
    NSString* testObjectA = @"TestObject A";
    [intervalTree addObject:testObjectA forIntervalWithLowValue:2 highValue:5];
    NSString* testObjectB = @"TestObject B";
    [intervalTree addObject:testObjectB forIntervalWithLowValue:3 highValue:7];
    NSString* testObjectC = @"TestObject C";
    [intervalTree addObject:testObjectC forIntervalWithLowValue:4 highValue:6];
    
    NSSet* setWithObjectA = [NSSet setWithObject:testObjectA];
    NSSet* setWithObjectB = [NSSet setWithObject:testObjectB];
    NSSet* setWithObjectC = [NSSet setWithObject:testObjectC];
    NSSet* setWithObjectsAB = [setWithObjectA setByAddingObjectsFromSet:setWithObjectB];
    NSSet* setWithObjectsBC = [setWithObjectB setByAddingObjectsFromSet:setWithObjectC];
    NSSet* setWithObjectsABC = [setWithObjectsAB setByAddingObjectsFromSet:setWithObjectC];
    
    XCTAssertEqualObjects([intervalTree objectsInIntervalWithLowValue:2.2 highValue:2.8], setWithObjectA);
    XCTAssertEqualObjects([intervalTree objectsInIntervalWithLowValue:3.2 highValue:3.8], setWithObjectsAB);
    XCTAssertEqualObjects([intervalTree objectsInIntervalWithLowValue:4.2 highValue:4.8], setWithObjectsABC);
    XCTAssertEqualObjects([intervalTree objectsInIntervalWithLowValue:5.2 highValue:5.8], setWithObjectsBC);
    XCTAssertEqualObjects([intervalTree objectsInIntervalWithLowValue:6.2 highValue:6.8], setWithObjectB);

    [intervalTree removeObjectForIntervalWithLowValue:4 highValue:6];

    XCTAssertEqualObjects([intervalTree objectsInIntervalWithLowValue:2.2 highValue:2.8], setWithObjectA);
    XCTAssertEqualObjects([intervalTree objectsInIntervalWithLowValue:3.2 highValue:4.8], setWithObjectsAB);
    XCTAssertEqualObjects([intervalTree objectsInIntervalWithLowValue:5.2 highValue:6.8], setWithObjectB);
    
    [intervalTree addObject:testObjectC forIntervalWithLowValue:4 highValue:6];

    XCTAssertEqualObjects([intervalTree objectsInIntervalWithLowValue:2.2 highValue:2.8], setWithObjectA);
    XCTAssertEqualObjects([intervalTree objectsInIntervalWithLowValue:3.2 highValue:3.8], setWithObjectsAB);
    XCTAssertEqualObjects([intervalTree objectsInIntervalWithLowValue:4.2 highValue:4.8], setWithObjectsABC);
    XCTAssertEqualObjects([intervalTree objectsInIntervalWithLowValue:5.2 highValue:5.8], setWithObjectsBC);
    XCTAssertEqualObjects([intervalTree objectsInIntervalWithLowValue:6.2 highValue:6.8], setWithObjectB);
}

- (void)testIntervalTreeSameInterval
{
    PWIntervalTree* intervalTree = [[PWIntervalTree alloc] init];
    
    NSString* testObjectA = @"TestObject A";
    NSString* testObjectB = @"TestObject B";
    NSSet* setWithObjectsAB = [NSSet setWithObjects:testObjectA, testObjectB, nil];

    [intervalTree addObject:testObjectA forIntervalWithLowValue:2 highValue:5];
    [intervalTree addObject:testObjectB forIntervalWithLowValue:2 highValue:5];
    XCTAssertEqualObjects([intervalTree objectsInIntervalWithLowValue:2 highValue:5], setWithObjectsAB);
}

- (void)testIntervalTreeWithIntervalStartingAtZero
{
    PWIntervalTree* intervalTree = [[PWIntervalTree alloc] init];
    
    NSString* testObjectA = @"TestObject A";
    NSString* testObjectB = @"TestObject B";
    NSSet* setWithObjectsAB = [NSSet setWithObjects:testObjectA, testObjectB, nil];

    [intervalTree addObject:testObjectA forIntervalWithLowValue:4 highValue:18];
    [intervalTree addObject:testObjectB forIntervalWithLowValue:26 highValue:40];
    XCTAssertEqualObjects([intervalTree objectsInIntervalWithLowValue:0 highValue:476], setWithObjectsAB);
    
    NSSet* nodes = [intervalTree nodesInIntervalWithLowValue:0 highValue:476];
    for(PWIntervalTreeNode* node in nodes)
        [intervalTree deleteNode:node];
    XCTAssertEqualObjects([intervalTree objectsInIntervalWithLowValue:0 highValue:476], [NSSet set]);
}

- (void)testRecursiveEnumeration
{
    PWIntervalTree* intervalTree = [[PWIntervalTree alloc] init];
    
    NSString* testObjectA = @"A";
    NSString* testObjectB = @"B";
    NSString* testObjectC = @"C";
    NSString* testObjectD = @"D";
    NSString* testObjectE = @"E";
    
    [intervalTree addObject:testObjectA forIntervalWithLowValue: 3 highValue: 4];
    [intervalTree addObject:testObjectB forIntervalWithLowValue: 4 highValue: 6];
    [intervalTree addObject:testObjectC forIntervalWithLowValue: 5 highValue: 7];
    [intervalTree addObject:testObjectD forIntervalWithLowValue: 8 highValue:10];
    [intervalTree addObject:testObjectE forIntervalWithLowValue:10 highValue:11];
    
    NSSet* setWithObjectsABC = [NSSet setWithObjects:testObjectA, testObjectB, testObjectC, nil];
    NSSet* setWithObjectsABCD = [NSSet setWithObjects:testObjectA, testObjectB, testObjectC, testObjectD, nil];
    NSSet* setWithObjectsCDE = [NSSet setWithObjects:testObjectC, testObjectD, testObjectE, nil];

    NSMutableSet* enumeratedObjectsForB = [NSMutableSet set];
    NSMutableSet* enumeratedObjectsForC = [NSMutableSet set];
    NSMutableSet* enumeratedObjectsForD = [NSMutableSet set];
    
    // Outer enumeration should include B, C, and D.
    [intervalTree enumerateNodesInIntervalWithLowValue:5 highValue:9 usingBlock:^(PWIntervalTreeNode* outerNode, BOOL* stop) {
        double lowValue  = outerNode.lowValue - 1;
        double highValue = outerNode.highValue + 1;
        id outerObject = outerNode.object;
        
        NSMutableSet* enumeratedObjects;

        if([outerObject isEqual:testObjectB])
            enumeratedObjects = enumeratedObjectsForB;
        else if([outerObject isEqual:testObjectC])
            enumeratedObjects = enumeratedObjectsForC;
        else
        {
            NSAssert([outerObject isEqual:testObjectD], nil);
            enumeratedObjects = enumeratedObjectsForD;
        }
        
        // Inner enumeration includes A, B, C for B; A, B, C, D for C; and C, D, E for D.
        [intervalTree enumerateNodesInIntervalWithLowValue:lowValue highValue:highValue usingBlock:^(PWIntervalTreeNode* innerNode, BOOL* stop2) {
            id innerObject = innerNode.object;
            [enumeratedObjects addObject:innerObject];
        }];
    }];
        
    XCTAssertEqualObjects(enumeratedObjectsForB, setWithObjectsABC);
    XCTAssertEqualObjects(enumeratedObjectsForC, setWithObjectsABCD);
    XCTAssertEqualObjects(enumeratedObjectsForD, setWithObjectsCDE);
}

- (void)testMutationDuringEnumeration
{
    PWIntervalTree* intervalTree = [[PWIntervalTree alloc] init];
    
    NSString* testObjectA = @"A";
    NSString* testObjectB = @"B";
    NSString* testObjectC = @"C";
    
    [intervalTree addObject:testObjectA forIntervalWithLowValue:3 highValue:4];
    [intervalTree addObject:testObjectB forIntervalWithLowValue:4 highValue:6];

    XCTAssertThrows([intervalTree enumerateNodesInIntervalWithLowValue:5 highValue:5 usingBlock:^(PWIntervalTreeNode* outerNode, BOOL* stop) {
        [intervalTree addObject:testObjectC forIntervalWithLowValue:5 highValue:7];
    }]);
}

@end
