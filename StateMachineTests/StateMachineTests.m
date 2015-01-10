//
//  StateMachineTests.m
//  StateMachineTests
//
//  Created by Soroush Khanlou on 1/10/15.
//  Copyright (c) 2015 Soroush Khanlou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "SKStateMachine.h"

@interface SKStateMachineDelegate : NSObject

@end

@implementation SKStateMachineDelegate

- (void)transitionFromLockedToUnlocked {
    NSLog(@"method called 1");
}

- (void)transitionFromUnlockedToLocked {
    NSLog(@"method called 2");
}

@end

@interface StateMachineTests : XCTestCase

@property (nonatomic, strong) SKStateMachine *stateMachine;
@property (nonatomic, strong) SKStateMachineDelegate *stateMachineDelegate;

@end

@implementation StateMachineTests

- (void)setUp {
    [super setUp];
    self.stateMachineDelegate = [SKStateMachineDelegate new];
    self.stateMachine = [[SKStateMachine alloc] initWithInitialState:@"locked" delegate:self.stateMachineDelegate];
}

- (void)testBasicStateMachine {
    
    XCTAssertNoThrow([self.stateMachine transitionToState:@"unlocked"]);
    XCTAssertNoThrow([self.stateMachine transitionToState:@"locked"]);
    XCTAssertThrows([self.stateMachine transitionToState:@"an invalid state"]);

}

- (void)testSelectorConstructor {
    SKSelectorConstructor *constructor = [SKSelectorConstructor new];
    
    XCTAssertEqualObjects(NSStringFromSelector([constructor selectorWithComponents:@[@"hi"]]), @"hi");
    XCTAssertEqualObjects(NSStringFromSelector([constructor selectorWithComponents:@[@"hi:", @"you:"]]), @"hi:you:");
    XCTAssertEqualObjects(NSStringFromSelector([constructor selectorWithComponents:@[@"transitionFrom", @"stateName", @"to", @"secondState"]]), @"transitionFromStateNameToSecondState");
    XCTAssertEqualObjects(NSStringFromSelector([constructor selectorWithComponents:@[@"set", @"somePropertyName", @":"]]), @"setSomePropertyName:");
    XCTAssertEqualObjects(NSStringFromSelector([constructor selectorWithComponents:@[@"set", @"longURLName", @":"]]), @"setLongUrlName:");
    XCTAssertEqualObjects(NSStringFromSelector([constructor selectorWithComponents:@[@"set", @"longURLName", @":",@"otherProperty", @"also:"]]), @"setLongUrlName:otherPropertyAlso:");
    
    XCTAssertEqualObjects([constructor llamaCasedString:@"heres-a-thing"], @"heresAThing");
}

@end
