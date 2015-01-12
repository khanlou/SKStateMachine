//
//  SKSelectorConstructor.m
//  StateMachine
//
//  Created by Soroush Khanlou on 1/12/15.
//  Copyright (c) 2015 Soroush Khanlou. All rights reserved.
//

#import "SKSelectorConstructor.h"
#import "SKLlamaCaseConverter.h"

@interface SKSelectorConstructor ()

@property (nonatomic, readonly) NSMutableArray *selectorComponents;

@end

@implementation SKSelectorConstructor

@synthesize selectorComponents = _selectorComponents;

- (instancetype)initWithComponents:(NSArray *)components {
    self = [super init];
    if (!self) return nil;
    
    _components = components;
    
    return self;
}

- (SEL)selector {
    for (NSInteger i = 0; i < self.selectorComponents.count; i++) {
        [self formatSelectorComponentAtIndex:i];
    }
    NSString *selectorName = [self.selectorComponents componentsJoinedByString:@":"];
    return NSSelectorFromString(selectorName);
}

- (NSMutableArray *)selectorComponents {
    if (!_selectorComponents) {
        _selectorComponents = [[[self joinedComponents] componentsSeparatedByString:@":"] mutableCopy];
    }
    return _selectorComponents;
}

- (void)formatSelectorComponentAtIndex:(NSInteger)index {
    NSString *component = self.selectorComponents[index];
    [self.selectorComponents replaceObjectAtIndex:index withObject:[[[SKLlamaCaseConverter alloc] initWithString:component] convertedString]];
}

- (NSString *)joinedComponents {
    return [self.components componentsJoinedByString:@"-"];
}

@end
