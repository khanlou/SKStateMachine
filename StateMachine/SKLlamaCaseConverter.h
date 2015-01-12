//
//  SKLlamaCaseConverter.h
//  StateMachine
//
//  Created by Soroush Khanlou on 1/12/15.
//  Copyright (c) 2015 Soroush Khanlou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKLlamaCaseConverter : NSObject

- (instancetype)initWithString:(NSString *)string;

@property (nonatomic, readonly) NSString *initialString;
@property (nonatomic, readonly) NSString *convertedString;

@end

