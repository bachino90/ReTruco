//
//  ButtonView.m
//  Gesture
//
//  Created by Emiliano Bivachi on 14/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import "ButtonView.h"

@interface ButtonView()
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *selectedImageView;
@end

@implementation ButtonView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.backgroundImageView.alpha = 1.0;
        self.selectedImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.selectedImageView.alpha = 0.0;
        [self addSubview:self.backgroundImageView];
        [self addSubview:self.selectedImageView];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame andImage:(UIImage *)image andSelectedImage:(UIImage *)selectedImage
{
    self = [self initWithFrame:frame];
    if (self) {
        self.backgroundImage = image;
        self.selectedImage = selectedImage;
        self.isSelected = NO;
    }
    return self;
}

- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    [self changeImageView];
}

- (void)changeImageView
{
    if (self.isSelected)
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.backgroundImageView.alpha = 0.0;
                             self.selectedImageView.alpha = 1.0;
                             self.transform = CGAffineTransformMakeScale(1.1, 1.1);
                         }
                         completion:^(BOOL done){}];
    else
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.backgroundImageView.alpha = 1.0;
                             self.selectedImageView.alpha = 0.0;
                             self.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         }
                         completion:^(BOOL done){}];
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
