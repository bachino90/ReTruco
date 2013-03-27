//
//  ButtonView.h
//  Gesture
//
//  Created by Emiliano Bivachi on 14/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ButtonView : UIView

@property (nonatomic) BOOL isSelected;

-(id)initWithFrame:(CGRect)frame andImage:(UIImage *)image andSelectedImage:(UIImage *)selectedImage;

@end
