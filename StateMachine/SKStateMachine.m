//
//  SKStateMachine.m
//  StateMachine
//
//  Created by Soroush Khanlou on 1/10/15.
//  Copyright (c) 2015 Soroush Khanlou. All rights reserved.
//

#import "SKStateMachine.h"

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
    if (index == 0) {
        return;
    }
    NSString *component = self.mutableComponents[index];
    [self.mutableComponents replaceObjectAtIndex:index withObject:[component capitalizedString]];
}

- (NSMutableArray *)mutableComponents {
    if (!_mutableComponents) {
        NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -_"];
        NSArray *components = [self.initialString componentsSeparatedByCharactersInSet:separatorSet];
        
        NSMutableArray *allComponents = [NSMutableArray array];
        for (NSString *component in components) {
            [allComponents addObjectsFromArray:[self componentsSplitOnUppercase:component]];
        }
        
        for (NSString *component in allComponents.reverseObjectEnumerator) {
            if (component.length == 0) {
                [allComponents removeObject:component];
            }
        }
        _mutableComponents = allComponents;
    }
    return _mutableComponents;
}

- (NSArray *)componentsSplitOnUppercase:(NSString *)string {
    NSMutableString *mutableString = [string mutableCopy];
    
    NSArray *lowercaseComponents = [string componentsSeparatedByCharactersInSet:[NSCharacterSet uppercaseLetterCharacterSet]];
    
    NSMutableArray *allComponents = [NSMutableArray array];
    for (NSString *incompleteComponent in lowercaseComponents) {
        if (incompleteComponent.length == 0) continue;
        
        NSRange rangeOfIncompleteComponent = [mutableString rangeOfString:incompleteComponent];
        
        if (rangeOfIncompleteComponent.location > 1) {
            NSRange rangeOfUppercaseComponent = NSMakeRange(0, rangeOfIncompleteComponent.location-1);
            NSString *uppercaseComponent = [mutableString substringWithRange:rangeOfUppercaseComponent];
            
            [mutableString deleteCharactersInRange:rangeOfUppercaseComponent];
            
            [allComponents addObject:[uppercaseComponent lowercaseString]];
            rangeOfIncompleteComponent = [mutableString rangeOfString:incompleteComponent];
        }
        NSRange rangeOfFullComponent = NSMakeRange(0, rangeOfIncompleteComponent.length + rangeOfIncompleteComponent.location);
        NSString *fullComponent = [mutableString substringWithRange:rangeOfFullComponent];
        
        [mutableString deleteCharactersInRange:rangeOfFullComponent];
        
        [allComponents addObject:[fullComponent lowercaseString]];
    }
    
    if (mutableString.length != 0) {
        [allComponents addObject:[mutableString lowercaseString]];
    }
    
    return allComponents;
}



@end
