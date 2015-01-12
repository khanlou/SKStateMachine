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
    
    NSString *thing = [self.mutableComponents componentsJoinedByString:@""];
    NSLog(@"converted string %@", thing);
    
    return thing;
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
        _mutableComponents = [[[[SKComponentSplitter alloc] initWithString:self.initialString] components] mutableCopy];
    }
    return _mutableComponents;
}


@end


@interface SKComponentSplitter ()

@property (nonatomic, readonly) NSMutableArray *mutableComponents;

@end

@implementation SKComponentSplitter

@synthesize mutableComponents = _mutableComponents;

- (instancetype)initWithString:(NSString *)string {
    self = [super init];
    if (!self) return nil;
    
    _string = string;
    
    return self;
}

- (NSArray *)mutableComponents {
    if (!_mutableComponents) {
        _mutableComponents = [NSMutableArray array];
    }
    return _mutableComponents;
}

- (NSCharacterSet *)separatorSet {
    return [NSCharacterSet characterSetWithCharactersInString:@" -_"];
}

- (NSCharacterSet *)lowercaseSet {
    return [NSCharacterSet lowercaseLetterCharacterSet];
}

- (NSCharacterSet *)uppercaseSet {
    return [NSCharacterSet uppercaseLetterCharacterSet];
}

- (NSArray *)components {
    NSInteger byteLength = [self.string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    char bufferCopy[byteLength+1];
    strncpy(bufferCopy, [self.string cStringUsingEncoding:NSUTF8StringEncoding], byteLength);
    
    NSMutableIndexSet *indicesToSplitOn = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *indicesToRemove = [NSMutableIndexSet indexSet];
    
    for (NSInteger i = 0; i < byteLength; i++) {
        unichar currentChar = bufferCopy[i];
        unichar lookahead = i+1 < byteLength ? bufferCopy[i+1] : ' ';
        if ([[self separatorSet] characterIsMember:currentChar]) {
            [indicesToRemove addIndex:i];
            [indicesToSplitOn addIndex:i];
        } else if ([[self lowercaseSet] characterIsMember:currentChar] && [[self uppercaseSet] characterIsMember:lookahead]) {
            [indicesToSplitOn addIndex:i+1];
        } else if ([[self uppercaseSet] characterIsMember:currentChar] && [[self lowercaseSet] characterIsMember:lookahead]) {
            [indicesToSplitOn addIndex:i];
        }
    }
    [indicesToSplitOn addIndex:byteLength];
    
    __block NSInteger startIndex = 0;
    __block NSInteger endIndex = 0;
    [indicesToSplitOn enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        endIndex = idx;
        [self.mutableComponents addObject:[self.string substringWithRange:NSMakeRange(startIndex, endIndex - startIndex)]];
        startIndex = endIndex;
    }];

    
    for (NSInteger i = self.mutableComponents.count-1; i >= 0; i--) {
        NSString *component = self.mutableComponents[i];
        NSString *formattedComponent = [component lowercaseString];
        formattedComponent = [formattedComponent stringByTrimmingCharactersInSet:[self separatorSet]];
        if (formattedComponent.length == 0) {
            [self.mutableComponents removeObjectAtIndex:i];
        } else {
            [self.mutableComponents replaceObjectAtIndex:i withObject:formattedComponent];
        }
    }
    
    return self.mutableComponents;
}

@end
