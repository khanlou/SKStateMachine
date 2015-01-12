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
        _mutableComponents = [[[[SKComponentSplitter alloc] initWithString:self.initialString] components] mutableCopy];
    }
    return _mutableComponents;
}


@end


@interface SKComponentSplitter ()

@property (nonatomic, readonly) NSMutableArray *mutableComponents;
@property (nonatomic, readonly) NSMutableIndexSet *indicesToSplitOn;
@property (nonatomic) NSInteger currentIndex;

@property (nonatomic) char *buffer;
@property (nonatomic) NSInteger byteLength;


@end

@implementation SKComponentSplitter

@synthesize mutableComponents = _mutableComponents, indicesToSplitOn = _indicesToSplitOn;

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

- (NSMutableIndexSet *)indicesToSplitOn {
    if (!_indicesToSplitOn) {
        _indicesToSplitOn = [NSMutableIndexSet indexSet];
    }
    return _indicesToSplitOn;
}

- (void)generateByteLengthAndBuffer {
    self.byteLength = [self.string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    char *bufferCopy = (char*)malloc(self.byteLength * sizeof(char));
    strncpy(bufferCopy, [self.string cStringUsingEncoding:NSUTF8StringEncoding], self.byteLength);
    
    self.buffer = bufferCopy;
}

- (char *)buffer {
    if (!_buffer) {
        [self generateByteLengthAndBuffer];
    }
    return _buffer;
}

- (NSInteger)byteLength {
    if (_byteLength == 0) {
        [self generateByteLengthAndBuffer];
    }
    return _byteLength;
}

- (NSInteger)bufferLength {
    return self.byteLength + 1;
}

- (NSArray *)components {
    if (self.string.length == 0) return @[];
    
    for (NSInteger i = 0; i < self.byteLength; i++) {
        self.currentIndex = i;
        [self addIndexIfSplittable];
    }
    [self.indicesToSplitOn addIndex:self.byteLength];
    
    __block NSInteger startIndex = 0;
    __block NSInteger endIndex = 0;
    [self.indicesToSplitOn enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
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

- (void)addIndexIfSplittable {
    if ([self currentCharIsSeparator]) {
        [self.indicesToSplitOn addIndex:self.currentIndex];
    } else if ([self currentCharIsLowercase] && [self nextCharIsUppercase]) {
        [self.indicesToSplitOn addIndex:self.nextIndex];
    } else if ([self currentCharIsUppercase] && [self nextCharIsLowercase]) {
        [self.indicesToSplitOn addIndex:self.currentIndex];
    }
}

- (BOOL)currentCharIsSeparator {
    return [[self separatorSet] characterIsMember:self.currentChar];
}

- (BOOL)currentCharIsUppercase {
    return [[self uppercaseSet] characterIsMember:self.currentChar];
}

- (BOOL)currentCharIsLowercase {
    return [[self lowercaseSet] characterIsMember:self.currentChar];
}

- (BOOL)nextCharIsUppercase {
    return [[self uppercaseSet] characterIsMember:self.nextChar];
}

- (BOOL)nextCharIsLowercase {
    return [[self lowercaseSet] characterIsMember:self.nextChar];
}

- (unichar)currentChar {
    return self.buffer[self.currentIndex];
}

- (unichar)nextChar {
    return [self nextIndex] < self.byteLength ? self.buffer[[self nextIndex]] : ' ';
}

- (NSInteger)nextIndex {
    return self.currentIndex + 1;
}

- (void)dealloc {
    free(self.buffer);
}

@end
