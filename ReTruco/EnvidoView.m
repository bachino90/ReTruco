//
//  EnvidoView.m
//  ReTruco
//
//  Created by Emiliano Bivachi on 19/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import "EnvidoView.h"

@interface EnvidoView ()
@property (nonatomic, readwrite) EnvidoType envidoType;
@end

@implementation EnvidoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)autoHeight:(UILabel *)label
{
    CGRect frame = label.frame;
    CGSize maxSize = CGSizeMake(frame.size.width, 9999);
    CGSize expectedSize = [label.text sizeWithFont:label.font constrainedToSize:maxSize lineBreakMode:label.lineBreakMode];
    frame.size.height = expectedSize.height;
    [label setFrame:frame];
}


- (id)initWithType:(EnvidoType)type
{
    self = [self initWithFrame:CGRectMake(0.0, 0.0, 280.0, 320.0)];
    if (self) {
        
        self.envidoType = type;
        
        UIColor *whiteColor = [UIColor colorWithRed:0.816 green:0.788 blue:0.788 alpha:1.000];
        
        self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8f];
        self.layer.borderColor = whiteColor.CGColor;
        self.layer.borderWidth = 2.f;
        self.layer.cornerRadius = 10.f;
        
        CGFloat paddingX = 10.f;
        CGFloat paddingY = 20.0f;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(paddingX, paddingY, self.frame.size.width - paddingX * 2.f, 0)];
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.f];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.shadowColor = [UIColor blackColor];
        titleLabel.shadowOffset = CGSizeMake(0, -1);
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        
        switch (type) {
            case EnvidoTypeEnvido:
                titleLabel.text = @"Envido";
                break;
                
            case EnvidoTypeRealEnvido:
                titleLabel.text = @"Real Envido";
                break;
                
            case EnvidoTypeFaltaEnvido:
                titleLabel.text = @"Falta Envido";
                break;
                
            case EnvidoTypeEnvidoEnvido:
                titleLabel.text = @"Envido Envido";
                break;
                
            case EnvidoTypeEnvidoRealEnvido:
                titleLabel.text = @"Envido Real Envido";
                break;
                
            default:
                break;
        }
        
        [self autoHeight:titleLabel];
        [self addSubview:titleLabel];
        
        UIButton *siquieroButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [siquieroButton setTitle:@"Si, quiero" forState:UIControlStateNormal];
        siquieroButton.frame = CGRectMake(0.0, 0.0, 170.0, 45.0);
        siquieroButton.center = CGPointMake(self.frame.size.width / 2, 100.0);
        [siquieroButton addTarget:self action:@selector(siQuieroAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *noquieroButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [noquieroButton setTitle:@"No quiero" forState:UIControlStateNormal];
        noquieroButton.frame = CGRectMake(0.0, 0.0, 170.0, 45.0);
        noquieroButton.center = CGPointMake(self.frame.size.width / 2, 180.0);
        [noquieroButton addTarget:self action:@selector(noQuieroAction:) forControlEvents:UIControlEventTouchUpInside];
        
        if (self.envidoType != EnvidoTypeEnvidoEnvido && self.envidoType != EnvidoTypeEnvidoRealEnvido )
        {
            UIButton *envidoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [envidoButton setTitle:@"Envido" forState:UIControlStateNormal];
            envidoButton.frame = CGRectMake(0.0, 0.0, 170.0, 45.0);
            envidoButton.center = CGPointMake(self.frame.size.width / 2, 260.0);
            [envidoButton addTarget:self action:@selector(envidoEnvidoAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:envidoButton];
        }
        
        [self addSubview:siquieroButton];
        [self addSubview:noquieroButton];
        
    }
    return self;
}

- (void)siQuieroAction:(UIButton *)sender
{
    [self.delegate envidoViewAcceptEnvido:self];
}

- (void)noQuieroAction:(UIButton *)sender
{
    [self.delegate envidoViewDenyEnvido:self];
}

- (void)envidoEnvidoAction:(UIButton *)sender
{
    [self.delegate envidoViewCalledEnvidoEnvido:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
