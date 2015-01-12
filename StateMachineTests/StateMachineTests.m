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
    XCTAssertEqualObjects(NSStringFromSelector([[[SKSelectorConstructor new] initWithComponents:@[@"hi"]] selector]), @"hi");
    XCTAssertEqualObjects(NSStringFromSelector([[[SKSelectorConstructor new] initWithComponents:@[@"hi:", @"you:"]] selector]), @"hi:you:");
    XCTAssertEqualObjects(NSStringFromSelector([[[SKSelectorConstructor new] initWithComponents:@[@"transitionFrom", @"stateName", @"to", @"secondState"]] selector]), @"transitionFromStateNameToSecondState");
    XCTAssertEqualObjects(NSStringFromSelector([[[SKSelectorConstructor new] initWithComponents:@[@"set", @"somePropertyName", @":"]] selector]), @"setSomePropertyName:");
    XCTAssertEqualObjects(NSStringFromSelector([[[SKSelectorConstructor new] initWithComponents:@[@"set", @"longURLName", @":"]] selector]), @"setLongUrlName:");
    XCTAssertEqualObjects(NSStringFromSelector([[[SKSelectorConstructor new] initWithComponents:@[@"set", @"longURLName", @":",@"otherProperty", @"also:"]] selector]), @"setLongUrlName:otherPropertyAlso:");
    
    XCTAssertEqualObjects([[[SKLlamaCaseConverter alloc] initWithString:@"heres-a-thing"] convertedString], @"heresAThing");
}

- (void)testLlamaCasing {
    XCTAssertEqualObjects([[[SKLlamaCaseConverter alloc] initWithString:@"heres-a-thing"] convertedString], @"heresAThing");
    XCTAssertEqualObjects([[[SKLlamaCaseConverter alloc] initWithString:@"heres_a_thing"] convertedString], @"heresAThing");
    XCTAssertEqualObjects([[[SKLlamaCaseConverter alloc] initWithString:@"heres a thing"] convertedString], @"heresAThing");
    XCTAssertEqualObjects([[[SKLlamaCaseConverter alloc] initWithString:@"aURLProperty"] convertedString], @"aUrlProperty");
    XCTAssertEqualObjects([[[SKLlamaCaseConverter alloc] initWithString:@"longURLProperty"] convertedString], @"longUrlProperty");
    XCTAssertEqualObjects([[[SKLlamaCaseConverter alloc] initWithString:@"URLPropertyName"] convertedString], @"urlPropertyName");
}

@end
