//
//  GameViewController.m
//  ReTruco
//
//  Created by Emiliano Bivachi on 04/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import "GameViewController.h"
#import "UIFont+SnapAdditions.h"
#import "Card.h"
#import "CardView.h"
#import "Player.h"
#import "Stack.h"
#import "TrucoGestureRecognizer.h"
#import "RNBlurModalView.h"
#import "EnvidoView.h"
#import "TrucoView.h"

@interface GameViewController () <UIGestureRecognizerDelegate, EnvidoViewDelegate, TrucoViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel *centerLabel;

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet UIView *cardContainerView;
@property (weak, nonatomic) IBOutlet UIView *buttonsContainerView;
@property (nonatomic, weak) IBOutlet UIButton *nextRoundButton;
@property (weak, nonatomic) IBOutlet UIButton *leftCardButton;
@property (weak, nonatomic) IBOutlet UIButton *centerCardButton;
@property (weak, nonatomic) IBOutlet UIButton *rightCardButton;

@property (weak, nonatomic) IBOutlet UILabel *playerScoreBottomLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerScoreTopLabel;

@property (nonatomic, weak) IBOutlet UILabel *playerNameBottomLabel;
@property (nonatomic, weak) IBOutlet UILabel *playerNameTopLabel;

@property (nonatomic, weak) IBOutlet UIImageView *playerActiveBottomImageView;
@property (nonatomic, weak) IBOutlet UIImageView *playerActiveTopImageView;

@property (nonatomic, strong) TrucoGestureRecognizer *trucoGestureRecognizer;

@end

@implementation GameViewController
{
	UIAlertView *_alertView;
    
    AVAudioPlayer *_dealingCardsSound;
    AVAudioPlayer *_turnCardSound;
    
    UIImageView *_tappedView;
    
    RNBlurModalView *_viewHUD;
}

- (void)dealloc
{
#ifdef DEBUG
	NSLog(@"dealloc %@", self);
#endif
    
    [_dealingCardsSound stop];
	[[AVAudioSession sharedInstance] setActive:NO error:NULL];
}

- (void)loadSounds
{
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
	//audioSession.delegate = nil;
	[audioSession setCategory:AVAudioSessionCategoryAmbient error:NULL];
	[audioSession setActive:YES error:NULL];
    
	NSURL *url = [[NSBundle mainBundle] URLForResource:@"Dealing" withExtension:@"caf"];
	_dealingCardsSound = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
	_dealingCardsSound.numberOfLoops = -1;
	[_dealingCardsSound prepareToPlay];
    
    url = [[NSBundle mainBundle] URLForResource:@"TurnCard" withExtension:@"caf"];
	_turnCardSound = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
	[_turnCardSound prepareToPlay];
}

- (void)afterDealing
{
	[_dealingCardsSound stop];
    [self.game beginRound];
    self.trucoGestureRecognizer.disableTouch = NO;
    self.trucoGestureRecognizer.roundState = RoundStateFirstRound;
    self.trucoGestureRecognizer.trucoState = TrucoStateNothing;
}

- (void)afterCardRecycle
{
    [_dealingCardsSound stop];
    [self.game finishRecycle];  //[self.game beginAnotherRound];
}

#pragma mark - Game UI

- (void)enableCardsButtons:(BOOL)enable
{
    self.trucoGestureRecognizer.enabled = enable;
    
    self.leftCardButton.enabled = enable;
    self.centerCardButton.enabled = enable;
    self.rightCardButton.enabled = enable;
}

- (void)hidePlayerLabels
{
	self.playerNameBottomLabel.hidden = YES;
	self.playerNameTopLabel.hidden = YES;
}

- (void)hideActivePlayerIndicator
{
	self.playerActiveBottomImageView.hidden = YES;
	self.playerActiveTopImageView.hidden    = YES;
}


- (void)hidePlayerLabelsForPlayer:(Player *)player
{
	switch (player.position)
	{
		case PlayerPositionBottom:
			self.playerNameBottomLabel.hidden = YES;
			break;
            
		case PlayerPositionTop:
			self.playerNameTopLabel.hidden = YES;
			break;
	}
}

- (void)hideActiveIndicatorForPlayer:(Player *)player
{
	switch (player.position)
	{
		case PlayerPositionBottom: self.playerActiveBottomImageView.hidden = YES; break;
		case PlayerPositionTop:    self.playerActiveTopImageView.hidden    = YES; break;
	}
}

- (void)showPlayerLabels
{
	Player *player = [self.game playerAtPosition:PlayerPositionBottom];
	if (player != nil)
	{
		self.playerNameBottomLabel.hidden = NO;
	}
    
	player = [self.game playerAtPosition:PlayerPositionTop];
	if (player != nil)
	{
		self.playerNameTopLabel.hidden = NO;
	}
    
}

- (void)updateScoreLabels
{
    //NSString *format = NSLocalizedString(@"%d Won", @"Number of games won");
    
    Player *player = [self.game playerAtPosition:PlayerPositionBottom];
	if (player != nil)
		self.playerScoreBottomLabel.text = [NSString stringWithFormat:@"Yo: %d", player.score];
    
	player = [self.game playerAtPosition:PlayerPositionTop];
	if (player != nil)
		self.playerScoreTopLabel.text = [NSString stringWithFormat:@"El: %d", player.score];
}

- (void)resizeLabelToFit:(UILabel *)label
{
	[label sizeToFit];
    
	CGRect rect = label.frame;
	rect.size.width = ceilf(rect.size.width/2.0f) * 2.0f;  // make even
	rect.size.height = ceilf(rect.size.height/2.0f) * 2.0f;  // make even
	label.frame = rect;
}

- (void)calculateLabelFrames
{
	UIFont *font = [UIFont rw_snapFontWithSize:14.0f];
	self.playerNameBottomLabel.font = font;
	self.playerNameTopLabel.font = font;
    
	UIImage *image = [[UIImage imageNamed:@"ActivePlayer"] stretchableImageWithLeftCapWidth:20 topCapHeight:0];
	self.playerActiveBottomImageView.image = image;
	self.playerActiveTopImageView.image = image;
    
	CGFloat viewWidth = self.view.bounds.size.width;
	CGFloat centerX = viewWidth / 2.0f;
    
	Player *player = [self.game playerAtPosition:PlayerPositionBottom];
	if (player != nil)
	{
		self.playerNameBottomLabel.text = player.name;
        
		[self resizeLabelToFit:self.playerNameBottomLabel];
		CGFloat labelWidth = self.playerNameBottomLabel.bounds.size.width;
        
		CGPoint point = CGPointMake(centerX - 19.0f - 3.0f, 306.0f);
		self.playerNameBottomLabel.center = point;
        
		self.playerActiveBottomImageView.frame = CGRectMake(0, 0, 20.0f + labelWidth + 6.0f + 38.0f + 2.0f, 20.0f);
        
		point.x = centerX - 9.0f;
		self.playerActiveBottomImageView.center = point;
	}
    
	player = [self.game playerAtPosition:PlayerPositionTop];
	if (player != nil)
	{
		self.playerNameTopLabel.text = player.name;
        
		[self resizeLabelToFit:self.playerNameTopLabel];
		CGFloat labelWidth = self.playerNameTopLabel.bounds.size.width;
        
		CGPoint point = CGPointMake(centerX - 19.0f - 3.0f, 15.0f);
		self.playerNameTopLabel.center = point;
        
		self.playerActiveTopImageView.frame = CGRectMake(0, 0, 20.0f + labelWidth + 6.0f + 38.0f + 2.0f, 20.0f);
        
		point.x = centerX - 9.0f;
		self.playerActiveTopImageView.center = point;
	}
}

- (void)showIndicatorForActivePlayer
{
	[self hideActivePlayerIndicator];
    
	PlayerPosition position = [self.game activePlayer].position;
    
	switch (position)
	{
		case PlayerPositionBottom: self.playerActiveBottomImageView.hidden = NO; break;
		case PlayerPositionTop:    self.playerActiveTopImageView.hidden    = NO; break;
	}
    
	if (position == PlayerPositionBottom)
		self.centerLabel.text = NSLocalizedString(@"Your turn. Tap the stack.", @"Status text: your turn");
	else
		self.centerLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@'s turn", @"Status text: other player's turn"), [self.game activePlayer].name];
}

- (void)showTappedViewAtIndexCard:(NSInteger)index
{
    Player *player = [self.game playerAtPosition:PlayerPositionBottom];
	Card *card = [player.handCards cardAtIndex:index];
	if (card != nil)
	{
		CardView *cardView = [self cardViewForCard:card];
        
		if (_tappedView == nil)
		{
			_tappedView = [[UIImageView alloc] initWithFrame:cardView.bounds];
			_tappedView.backgroundColor = [UIColor clearColor];
			_tappedView.image = [UIImage imageNamed:@"Darken"];
			_tappedView.alpha = 0.6f;
			[self.view addSubview:_tappedView];
		}
		else
		{
			_tappedView.hidden = NO;
		}
        
		_tappedView.center = cardView.center;
		_tappedView.transform = cardView.transform;
	}
}

- (void)hideTappedView
{
	_tappedView.hidden = YES;
}

- (CardView *)cardViewForCard:(Card *)card
{
	for (CardView *cardView in self.cardContainerView.subviews)
	{
		if (cardView.card == card)
			return cardView;
	}
	return nil;
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
	[super viewDidLoad];
        
    self.centerLabel.font = [UIFont rw_snapFontWithSize:18.0f];
    
	self.nextRoundButton.hidden = YES;
    
	[self hidePlayerLabels];
	[self hideActivePlayerIndicator];
    
    [self loadSounds];
    
    self.trucoGestureRecognizer = [[TrucoGestureRecognizer alloc] initWithTarget:self action:@selector(handleTrucoRecognizer:)];
    self.trucoGestureRecognizer.delegate = self;
    self.trucoGestureRecognizer.roundState = RoundStateFirstRound;
    self.trucoGestureRecognizer.trucoState = TrucoStateNothing;
    self.trucoGestureRecognizer.enabled = NO;
    
    [self.buttonsContainerView addGestureRecognizer:self.trucoGestureRecognizer];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
	[_alertView dismissWithClickedButtonIndex:_alertView.cancelButtonIndex animated:NO];
}

#pragma mark - Handle Gesture

- (void)handleTrucoRecognizer:(TrucoGestureRecognizer *)gesture
{
    switch (gesture.state)
    {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateCancelled:
            break;
        case UIGestureRecognizerStateChanged:
            break;
        case UIGestureRecognizerStateFailed:
            break;
        case UIGestureRecognizerStateRecognized:
            switch (gesture.buttonTouch)
            {
                case ButtonTouchEnvido:
                    NSLog(@"Envido");
                    [self.game playerCalledEnvido:[self.game playerAtPosition:PlayerPositionBottom] envidoType:EnvidoTypeEnvido];
                    gesture.roundState = RoundStateOtherRound;
                    break;
                case ButtonTouchRealEnvido:
                    NSLog(@"Real Envido");
                    [self.game playerCalledEnvido:[self.game playerAtPosition:PlayerPositionBottom] envidoType:EnvidoTypeRealEnvido];
                    gesture.roundState = RoundStateOtherRound;
                    break;
                case ButtonTouchFaltaEnvido:
                    NSLog(@"Falta Envido");
                    [self.game playerCalledEnvido:[self.game playerAtPosition:PlayerPositionBottom] envidoType:EnvidoTypeFaltaEnvido];
                    gesture.roundState = RoundStateOtherRound;
                    break;
                case ButtonTouchTruco:
                    NSLog(@"Truco");
                    [self.game playerCalledTruco:[self.game playerAtPosition:PlayerPositionBottom] trucoState:TrucoStateTruco];
                    gesture.roundState = RoundStateOtherRound;
                    gesture.trucoState = TrucoStateQuieroValeCuatro;
                    gesture.disableTouch = YES;
                    break;
                case ButtonTouchReTruco:
                    NSLog(@"ReTruco");
                    [self.game playerCalledTruco:[self.game playerAtPosition:PlayerPositionBottom] trucoState:TrucoStateReTruco];
                    gesture.trucoState = TrucoStateQuieroValeCuatro;
                    gesture.disableTouch = YES;
                    break;
                case ButtonTouchQuieroValeCuatro:
                    NSLog(@"quiero vale cuatro");
                    [self.game playerCalledTruco:[self.game playerAtPosition:PlayerPositionBottom] trucoState:TrucoStateQuieroValeCuatro];
                    gesture.disableTouch = YES;
                    break;
                case ButtonTouchNothing:
                    NSLog(@"NADA");
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
}

#pragma mark - Buttons Actions

- (IBAction)exitAction:(id)sender
{
	if (self.game.isServer)
	{
		_alertView = [[UIAlertView alloc]
                      initWithTitle:NSLocalizedString(@"End Game?", @"Alert title (user is host)")
                      message:NSLocalizedString(@"This will terminate the game for all other players.", @"Alert message (user is host)")
                      delegate:self
                      cancelButtonTitle:NSLocalizedString(@"No", @"Button: No")
                      otherButtonTitles:NSLocalizedString(@"Yes", @"Button: Yes"),
                      nil];
        
		[_alertView show];
	}
	else
	{
		_alertView = [[UIAlertView alloc]
                      initWithTitle: NSLocalizedString(@"Leave Game?", @"Alert title (user is not host)")
                      message:nil
                      delegate:self
                      cancelButtonTitle:NSLocalizedString(@"No", @"Button: No")
                      otherButtonTitles:NSLocalizedString(@"Yes", @"Button: Yes"),
                      nil];
        
		[_alertView show];
	}
}

- (IBAction)turnOverPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [self showTappedViewAtIndexCard:button.tag];
}

- (IBAction)turnOverEnter:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [self showTappedViewAtIndexCard:button.tag];
}

- (IBAction)turnOverExit:(id)sender
{
    [self hideTappedView];
}

- (IBAction)turnOverAction:(id)sender
{
    [self hideTappedView];
    UIButton *button = (UIButton *)sender;
    [self.game turnCardForPlayerAtBottomAtIndexCard:button.tag];
}

- (IBAction)nextRoundAction:(id)sender
{
}

#pragma mark - GameDelegate

- (void)gameDidBegin:(Game *)game
{
    [self showPlayerLabels];
	[self calculateLabelFrames];
	[self updateScoreLabels];
}

- (void)gameShouldDealCards:(Game *)game startingWithPlayer:(Player *)startingPlayer
{
	self.centerLabel.text = NSLocalizedString(@"Dealing...", @"Status text: dealing");
    
	self.nextRoundButton.hidden = YES;
    
    [self enableCardsButtons:NO];//self.trucoGestureRecognizer.enabled = NO;
    
	NSTimeInterval delay = 1.0f;
    
    _dealingCardsSound.currentTime = 0.0f;
	[_dealingCardsSound prepareToPlay];
	[_dealingCardsSound performSelector:@selector(play) withObject:nil afterDelay:delay];
    
	for (int t = 0; t < 3; ++t)
	{
		for (PlayerPosition p = startingPlayer.position; p < startingPlayer.position + MAX_PLAYER; ++p)
		{
			Player *player = [self.game playerAtPosition:p % MAX_PLAYER];
			if (player != nil && t < [player.handCards cardCount])
			{
				CardView *cardView = [[CardView alloc] initWithFrame:CGRectMake(0, 0, CARD_WIDTH, CARD_HEIGHT)];
				cardView.card = [player.handCards cardAtIndex:t];
				[self.cardContainerView addSubview:cardView];
				//[cardView animateDealingToPlayer:player withDelay:delay];
                [cardView animateDealingToPlayer:player atIndex:t withDelay:delay];
				delay += 0.1f;
			}
		}
	}
    
    [self performSelector:@selector(afterDealing) withObject:nil afterDelay:delay];
}

- (void)game:(Game *)game didActivatePlayer:(Player *)player
{
	[self showIndicatorForActivePlayer];
    if (player.position == PlayerPositionBottom)
        [self enableCardsButtons:YES];//self.trucoGestureRecognizer.enabled = YES;
    else
        [self enableCardsButtons:NO];//self.trucoGestureRecognizer.enabled = NO;
    
    if ([self.game numberOfRound] > 0) self.trucoGestureRecognizer.roundState = RoundStateOtherRound;
}

- (void)game:(Game *)game player:(Player *)player turnedOverCard:(Card *)card
{
	[_turnCardSound play];
    
    //[self enableCardsButtons:NO];//self.trucoGestureRecognizer.enabled = NO;
    
	CardView *cardView = [self cardViewForCard:card];
	[cardView animateSelectingForPlayer:player];
}

- (void)gameDidRecycleCards:(Game *)game;
{
    self.centerLabel.text = NSLocalizedString(@"Dealing...", @"Status text: dealing");
    
	self.nextRoundButton.hidden = YES;
    
    [self updateScoreLabels];
    [self enableCardsButtons:NO];//self.trucoGestureRecognizer.enabled = NO;
    
	NSTimeInterval delay = 1.5f;
    
    _dealingCardsSound.currentTime = 0.0f;
	[_dealingCardsSound prepareToPlay];
	[_dealingCardsSound performSelector:@selector(play) withObject:nil afterDelay:delay];
    
    NSArray *stackCardsViews = [self.cardContainerView subviews];
    
    for (CardView *cardView in stackCardsViews)
    {
        [cardView animateHideCardWithDelay:delay];
        delay += 0.1f;
    }

    [self performSelector:@selector(afterCardRecycle) withObject:nil afterDelay:delay];
}

#pragma mark - Handle Envido And Truco response

- (void)gameWaitUntilRecieveResponse:(Game *)game withTitle:(NSString *)title
{
    [_viewHUD hide];
    _viewHUD = [[RNBlurModalView alloc] initWithViewController:self title:title message:@"Espera a que responda el otro jugador"];
    [_viewHUD show];
    [self enableCardsButtons:NO];
}

- (void)gamePresentViewForEnvido:(Game *)game
{
    [_viewHUD hide];
    EnvidoView *envidoView = [[EnvidoView alloc] initWithType:game.envidoType];
    envidoView.delegate = self;
    _viewHUD = [[RNBlurModalView alloc] initWithViewController:self view:envidoView];
    [_viewHUD show];
    
    self.trucoGestureRecognizer.roundState = RoundStateOtherRound;
    
    [self enableCardsButtons:NO];
}


- (void)gamePresentViewForTruco:(Game *)game
{
    [_viewHUD hide];
    TrucoView *trucoView = [[TrucoView alloc] initWithState:game.trucoState andEnvidoType:self.game.envidoType];
    trucoView.delegate = self;
    _viewHUD = [[RNBlurModalView alloc] initWithViewController:self view:trucoView];
    [_viewHUD show];
    
    switch (game.trucoState) {
        case TrucoStateTruco:
            self.trucoGestureRecognizer.trucoState = TrucoStateTruco;
            self.trucoGestureRecognizer.roundState = RoundStateOtherRound;
            self.trucoGestureRecognizer.disableTouch = NO;
            break;
            
        case TrucoStateReTruco:
            self.trucoGestureRecognizer.trucoState = TrucoStateReTruco;
            self.trucoGestureRecognizer.disableTouch = NO;
            break;
            
        case TrucoStateQuieroValeCuatro:
            self.trucoGestureRecognizer.trucoState = TrucoStateQuieroValeCuatro;
            break;
            
        default:
            break;
    }
    
    [self enableCardsButtons:NO];
}

- (void)gameResumeHideViewHUD:(Game *)game
{
    [_viewHUD hide];
    [self enableCardsButtons:YES];
}

- (void)game:(Game *)game showEnvidoRespond:(BOOL)respond
{
    [self updateScoreLabels];
    [_viewHUD hide];

    NSDictionary *dict = [game envidoMessage];
    _viewHUD = [[RNBlurModalView alloc] initWithViewController:self title:dict[@"title"] message:dict[@"message"]];
    [_viewHUD show];
    
    //[_viewHUD performSelector:@selector(hide) withObject:nil afterDelay:6.0];
    
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 6ull * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        NSLog(@"waited at least 6 seconds.");
        [_viewHUD hide];
        [self enableCardsButtons:YES];
        self.trucoGestureRecognizer.disableTouch = NO;
        self.trucoGestureRecognizer.trucoState = TrucoStateNothing;
    });
}

- (void)game:(Game *)game showTrucoRespond:(BOOL)respond
{
    [self updateScoreLabels];
    [_viewHUD hide];
    
    NSString *message = @"No quiero";
    if (respond) 
        message = @"Si, quiero";
        
    _viewHUD = [[RNBlurModalView alloc] initWithViewController:self title:@"Truco" message:message];
    [_viewHUD show];
    //[_viewHUD performSelector:@selector(hide) withObject:nil afterDelay:6.0];
    
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 6ull * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        NSLog(@"waited at least 6 seconds.");
        [_viewHUD hide];
        [self enableCardsButtons:YES];
    });
}

- (void)game:(Game *)game didQuitWithReason:(QuitReason)reason
{
	[self.delegate gameViewController:self didQuitWithReason:reason];
}

- (void)game:(Game *)game playerDidDisconnect:(Player *)disconnectedPlayer
{
	[self hidePlayerLabelsForPlayer:disconnectedPlayer];
	[self hideActiveIndicatorForPlayer:disconnectedPlayer];
}

- (void)gameWaitingForServerReady:(Game *)game
{
	self.centerLabel.text = NSLocalizedString(@"Waiting for game to start...", @"Status text: waiting for server");
}

- (void)gameWaitingForClientsReady:(Game *)game
{
	self.centerLabel.text = NSLocalizedString(@"Waiting for other players...", @"Status text: waiting for clients");
}

#pragma mark - EnvidoViewDelegate

- (void)envidoViewAcceptEnvido:(EnvidoView *)envidoView
{
    [self.game respondEnvido:YES];
}

- (void)envidoViewDenyEnvido:(EnvidoView *)envidoView
{
    [self.game respondEnvido:NO];
}

- (void)envidoViewCalledEnvidoEnvido:(EnvidoView *)envidoView
{
    [self.game respondEnvidoEnvido];
}

#pragma mark - TrucoViewDelegate

- (void)trucoViewAcceptTruco:(TrucoView *)trucoView
{
    [self.game respondTruco:YES];
}

- (void)trucoViewDenyTruco:(TrucoView *)trucoView
{
    [self.game respondTruco:NO];
}

- (void)trucoViewCalledEnvido:(TrucoView *)trucoView
{
    [self.game respondEnvidoBeforeTruco];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != alertView.cancelButtonIndex)
	{
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        
		[self.game quitGameWithReason:QuitReasonUserQuit];
	}
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    __block BOOL shouldBegin = YES;
    
    [self.buttonsContainerView.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        if (touch.view == view) {
            shouldBegin = NO;
            *stop = YES;
        }
    }];
    
    return shouldBegin;
}


#pragma mark - Otras Cosas

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
