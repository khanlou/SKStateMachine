//
//  SKComponentSplitter.m
//  StateMachine
//
//  Created by Soroush Khanlou on 1/12/15.
//  Copyright (c) 2015 Soroush Khanlou. All rights reserved.
//

#import "SKComponentSplitter.h"

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
        for (NSInteger i = 0; i < self.byteLength; i++) {
            self.currentIndex = i;
            [self addIndexIfSplittable];
        }
        [self.indicesToSplitOn addIndex:self.byteLength];
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

- (void)splitStringIntoComponents {
    __block NSInteger startIndex = 0;
    __block NSInteger endIndex = 0;
    [self.indicesToSplitOn enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        endIndex = idx;
        [self.mutableComponents addObject:[self.string substringWithRange:NSMakeRange(startIndex, endIndex - startIndex)]];
        startIndex = endIndex;
    }];
}

- (void)formatComponentsAndRemoveEmptyComponents {
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
}

- (NSArray *)components {
    if (self.string.length == 0) return @[];
    
    [self splitStringIntoComponents];
    [self formatComponentsAndRemoveEmptyComponents];
    
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
