//
//  SKSelectorConstructor.h
//  StateMachine
//
//  Created by Soroush Khanlou on 1/12/15.
//  Copyright (c) 2015 Soroush Khanlou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKSelectorConstructor : NSObject

- (instancetype)initWithComponents:(NSArray *)components;

@property (nonatomic, readonly) NSArray *components;

@property (readonly) SEL selector;

@end
