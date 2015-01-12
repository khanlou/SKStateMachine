//
//  SKStateMachine.m
//  StateMachine
//
//  Created by Soroush Khanlou on 1/10/15.
//  Copyright (c) 2015 Soroush Khanlou. All rights reserved.
//

#import "SKStateMachine.h"
#import "SKSelectorConstructor.h"

@implementation SKInvalidStateTransitionException

@end

@interface SKStateMachine ()

@property (nonatomic) NSString *currentState;
@property (nonatomic) SKSelectorConstructor *selectorConstructor;


@end

@implementation SKStateMachine

- (instancetype)init {
    return [self initWithInitialState:nil delegate:nil];
}

- (instancetype)initWithInitialState:(NSString *)initialState delegate:(id)delegate {
    self = [super init];
    if (!self) return nil;
    
    if (!initialState || initialState.length == 0) {
        [SKInvalidStateTransitionException raise:@"Invalid State Transition" format:@"An empty string is not a valid initial state."];
        self = nil;
        return nil;
    }
    
    _currentState = initialState;
    _delegate = delegate;
    _selectorConstructor = [SKSelectorConstructor new];
    
    return self;
}

- (void)transitionToState:(NSString *)stateName {
    if (stateName && stateName.length != 0) {
        SEL transitionSelector = [self selectorForTransitionToState:stateName];
        if ([self.delegate respondsToSelector:transitionSelector]) {
            self.currentState = stateName;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.delegate performSelector:transitionSelector];
#pragma clang diagnostic pop
            return;
        }
        [SKInvalidStateTransitionException raise:@"Invalid State Transition" format:@"The delegate does not respond to transitions from %@ to %@. Implement the method %@ if this is a valid transition.", self.currentState, stateName, NSStringFromSelector(transitionSelector)];
    } else {
        [SKInvalidStateTransitionException raise:@"Invalid State Transition" format:@"Empty strings are not valid states to transition to."];
    }
}

- (BOOL)canTransitionToState:(NSString *)stateName {
    return [self selectorForTransitionToState:stateName] != NULL;
}

- (SEL)selectorForTransitionToState:(NSString *)stateName {
    return [[[SKSelectorConstructor new] initWithComponents:@[@"transitionFrom", self.currentState, @"to", stateName]] selector];
}

@end





