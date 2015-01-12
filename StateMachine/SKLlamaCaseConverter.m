//
//  SKLlamaCaseConverter.m
//  StateMachine
//
//  Created by Soroush Khanlou on 1/12/15.
//  Copyright (c) 2015 Soroush Khanlou. All rights reserved.
//

#import "SKLlamaCaseConverter.h"
#import "SKComponentSplitter.h"

@interface SKLlamaCaseConverter ()

@property (nonatomic, readonly) NSMutableArray *mutableComponents;

@end

@implementation SKLlamaCaseConverter

@synthesize mutableComponents = _mutableComponents;

- (instancetype)initWithString:(NSString *)string {
    self = [super init];
    if (!self) return nil;
    
    _initialString = string;
    
    return self;
}

- (NSString *)convertedString {
    if (self.initialString.length == 0) return @"";
    for (NSInteger i = 0; i < self.mutableComponents.count; i++) {
        [self formatComponentAtIndex:i];
    }
    return [self.mutableComponents componentsJoinedByString:@""];
}

- (void)formatComponentAtIndex:(NSInteger)index {
    if (index != 0) {
        [self capitalizeComponentAtIndex:index];
    }
}

- (void)capitalizeComponentAtIndex:(NSInteger)index {
    NSString *component = self.mutableComponents[index];
    [self.mutableComponents replaceObjectAtIndex:index withObject:[component capitalizedString]];
}

- (NSMutableArray *)mutableComponents {
    if (!_mutableComponents) {
        _mutableComponents = [[[[SKComponentSplitter alloc] initWithString:self.initialString] components] mutableCopy];
    }
    return _mutableComponents;
}


@end


