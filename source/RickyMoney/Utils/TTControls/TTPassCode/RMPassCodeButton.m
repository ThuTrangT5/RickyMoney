//
//  RMPassCodeButton.m
//  RickyMoney
//
//  Created by Thu Trang on 2/24/16.
//  Copyright © 2016 adelphatech. All rights reserved.
//

#import "RMPassCodeButton.h"
#import "RMConstant.h"

@implementation RMPassCodeButton

- (void) initForPassCode {
    if (self.tinColor == nil) {
        self.tinColor = RM_COLOR;// => E6C220
    }
    
    self.layer.borderColor = self.tinColor.CGColor;
    self.layer.borderWidth = 1.0;
    [self setTintColor:self.tinColor];
    
    [self setContentMode:UIViewContentModeCenter];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initForPassCode];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initForPassCode];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initForPassCode];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    if (highlighted) {
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.backgroundColor = self.tinColor;
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        self.layer.borderColor = self.tinColor.CGColor;
        self.backgroundColor = [UIColor clearColor];
        [self setTitleColor:self.tinColor forState:UIControlStateNormal];
    }
}

@end
