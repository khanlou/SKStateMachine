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

- (instancetype)initWithInitialState:(NSString *)initialState delegate:(id)delegate {
    self = [super init];
    if (!self) return nil;
    
    _currentState = initialState;
    _delegate = delegate;
    _selectorConstructor = [SKSelectorConstructor new];
    
    return self;
}

- (void)transitionToState:(NSString *)stateName {
    if (stateName) {
        SEL transitionSelector = [self selectorForTransitionToState:stateName];
        if ([self.delegate respondsToSelector:transitionSelector]) {
            self.currentState = stateName;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.delegate performSelector:transitionSelector];
#pragma clang diagnostic pop
            return;
        }
    }
    [SKInvalidStateTransitionException raise:@"Invalid State Transition!" format:@"The delegate does not respond to transitions of the type thingy."];
}

- (BOOL)canTransitionToState:(NSString *)stateName {
    return [self selectorForTransitionToState:stateName] != NULL;
}

- (SEL)selectorForTransitionToState:(NSString *)stateName {
    return [[[SKSelectorConstructor new] initWithComponents:@[@"transitionFrom", self.currentState, @"to", stateName]] selector];
}

@end





