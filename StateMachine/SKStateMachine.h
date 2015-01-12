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

@end

@interface SKLlamaCaseConverter : NSObject

- (instancetype)initWithString:(NSString *)string;

@property (nonatomic, readonly) NSString *initialString;
@property (nonatomic, readonly) NSString *convertedString;

@end

@interface SKComponentSplitter : NSObject

- (instancetype)initWithString:(NSString *)string;

@property (nonatomic, readonly) NSString *string;

@property (nonatomic, retain) NSArray *components;

@end

