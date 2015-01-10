//
//  SKStateMachine.h
//  StateMachine
//
//  Created by Soroush Khanlou on 1/10/15.
//  Copyright (c) 2015 Soroush Khanlou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKInvalidStateTransitionException : NSException

@end

@interface SKStateMachine : NSObject

- (instancetype)initWithInitialState:(NSString *)initialState delegate:(id)delegate;

@property (nonatomic, weak, readonly) id delegate;

@property (nonatomic, readonly) NSString *currentState;

- (void)transitionToState:(NSString *)stateName;
- (BOOL)canTransitionToState:(NSString *)stateName;

@end

@interface SKSelectorConstructor : NSObject

- (instancetype)initWithComponents:(NSArray *)components;

@property (nonatomic, readonly) NSArray *components;

@property (readonly) SEL selector;


- (NSString*)llamaCasedString:(NSString*)string;
- (NSArray *)componentsFromString:(NSString*)string;
- (NSArray *)componentsSplitOnUppercase:(NSString *)string;

@end