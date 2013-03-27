//
//  Game.m
//  ReTruco
//
//  Created by Emiliano Bivachi on 04/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import "Game.h"
#import "Player.h"
#import "Card.h"
#import "Deck.h"
#import "Stack.h"
#import "Packet.h"
#import "PacketSignInResponse.h"
#import "PacketServerReady.h"
#import "PacketDealCards.h"
#import "PacketActivatePlayer.h"
#import "PacketClientTurnedCard.h"
#import "PacketPlayerCalledEnvido.h"
#import "PacketPlayerCalledTruco.h"
#import "PacketTrucoRespond.h"
#import "PacketEnvidoRespond.h"
#import "PacketClientReceivedTrucoRespond.h"
#import "PacketClientReceivedEnvidoRespond.h"

typedef enum
{
	GameStateWaitingForSignIn,
	GameStateWaitingForReady,
	GameStateDealing,
	GameStatePlaying,
	GameStateGameOver,
	GameStateQuitting,
}
GameState;

@interface Game ()
@property (nonatomic, readwrite) TrucoState trucoState;
@property (nonatomic, readwrite) EnvidoType envidoType;
@end

@implementation Game
{
	GameState _state;
    
	GKSession *_session;
	NSString *_serverPeerID;
	NSString *_localPlayerName;
    
    NSMutableDictionary *_players;
    
    PlayerPosition _startingGamePlayerPosition;
    PlayerPosition _startingPlayerPosition;
	PlayerPosition _activePlayerPosition;
    
    BOOL _firstTime;
    BOOL _busyDealing;
	BOOL _hasTurnedCard;
    
    NSMutableArray *_winnersRound;
}

- (void)dealloc
{
#ifdef DEBUG
	NSLog(@"dealloc %@", self);
#endif
}

- (id)init
{
	if ((self = [super init]))
	{
		_players = [NSMutableDictionary dictionaryWithCapacity:MAX_PLAYER];
        _winnersRound = [NSMutableArray arrayWithCapacity:3];
	}
	return self;
}

- (Player *)playerWithPeerID:(NSString *)peerID
{
	return [_players objectForKey:peerID];
}

- (Player *)playerAtPosition:(PlayerPosition)position
{
	NSAssert(position >= PlayerPositionBottom && position <= PlayerPositionTop, @"Invalid player position");
    
	__block Player *player;
	[_players enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         player = obj;
         if (player.position == position)
             *stop = YES;
         else
             player = nil;
     }];
    
	return player;
}

- (BOOL)receivedResponsesFromAllPlayers
{
	for (NSString *peerID in _players)
	{
		Player *player = [self playerWithPeerID:peerID];
		if (!player.receivedResponse)
			return NO;
	}
	return YES;
}

- (void)changeRelativePositionsOfPlayers
{
	NSAssert(!self.isServer, @"Must be client");
    
	Player *myPlayer = [self playerWithPeerID:_session.peerID];
	int diff = myPlayer.position;
	myPlayer.position = PlayerPositionBottom;
    
	[_players enumerateKeysAndObjectsUsingBlock:^(id key, Player *obj, BOOL *stop)
     {
         if (obj != myPlayer)
         {
             obj.position = (obj.position - diff) % MAX_PLAYER;
         }
     }];
}

- (void)pickRandomStartingPlayer
{
	do
	{
		_startingPlayerPosition = PlayerPositionBottom;//arc4random() % MAX_PLAYER;
	}
	while ([self playerAtPosition:_startingPlayerPosition] == nil);
    
	_activePlayerPosition = _startingPlayerPosition;
    _startingGamePlayerPosition = _startingPlayerPosition;
}

- (Player *)activePlayer
{
	return [self playerAtPosition:_activePlayerPosition];
}

- (void)dealCards
{
    NSAssert(self.isServer, @"Must be server");
	NSAssert(_state == GameStateDealing, @"Wrong state");
    
	Deck *deck = [[Deck alloc] init];
	[deck shuffle];
    
    int totalCards = [deck cardsRemaining];
    
	while ([deck cardsRemaining] > (totalCards - [_players count] * 3))
	{
		for (PlayerPosition p = _startingPlayerPosition; p < _startingPlayerPosition + MAX_PLAYER; ++p)
		{
			Player *player = [self playerAtPosition:(p % MAX_PLAYER)];
			if (player != nil && [deck cardsRemaining] > 0)
			{
				Card *card = [deck draw];
				[player.handCards addCardToTop:card];
			}
		}
	}
    
    Player *startingPlayer = [self activePlayer];
    
    NSMutableDictionary *playerCards = [NSMutableDictionary dictionaryWithCapacity:MAX_PLAYER];
	[_players enumerateKeysAndObjectsUsingBlock:^(id key, Player *obj, BOOL *stop)
     {
         NSArray *array = [obj.handCards array];
         [playerCards setObject:array forKey:obj.peerID];
     }];
    
	PacketDealCards *packet = [PacketDealCards packetWithCards:playerCards startingWithPlayerPeerID:startingPlayer.peerID];
	[self sendPacketToAllClients:packet];
    
	[self.delegate gameShouldDealCards:self startingWithPlayer:startingPlayer];
}

- (void)handleDealCardsPacket:(PacketDealCards *)packet
{
	[packet.cards enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         Player *player = [self playerWithPeerID:key];
         [player.handCards addCardsFromArray:obj];
     }];
    
	Player *startingPlayer = [self playerWithPeerID:packet.startingPeerID];
	_activePlayerPosition = startingPlayer.position;
    _startingPlayerPosition = _activePlayerPosition;
    
	Packet *responsePacket = [Packet packetWithType:PacketTypeClientDealtCards];
	[self sendPacketToServer:responsePacket];
    
	_state = GameStatePlaying;
    _trucoState = TrucoStateNothing;
    
	[self.delegate gameShouldDealCards:self startingWithPlayer:startingPlayer];
}

- (void)activatePlayerAtPosition:(PlayerPosition)playerPosition
{
    _hasTurnedCard = NO;
    
	if (self.isServer)
	{
		NSString *peerID = [self activePlayer].peerID;
		Packet* packet = [PacketActivatePlayer packetWithPeerID:peerID];
		[self sendPacketToAllClients:packet];
	}
    
	[self.delegate game:self didActivatePlayer:[self activePlayer]];
}

- (void)activatePlayerAtPosition:(PlayerPosition)playerPosition andCardIndex:(NSUInteger)index
{
    _hasTurnedCard = NO;
    
    Player *activePlayer = [self activePlayer];
    
	if (self.isServer)
	{
		NSString *peerID = activePlayer.peerID;
		Packet* packet = [PacketActivatePlayer packetWithPeerID:peerID andIndex:index];
		[self sendPacketToAllClients:packet];
	}
           
	[self.delegate game:self didActivatePlayer:activePlayer];
}

- (void)handleActivatePlayerPacket:(PacketActivatePlayer *)packet
{
    /*
    if (_firstTime && self.isServer)
	{
		_firstTime = NO;
		return;
	}
    */
	NSString *peerID = packet.peerID;
    
	Player* newPlayer = [self playerWithPeerID:peerID];
	if (newPlayer == nil)
		return;
    
    NSUInteger index = ((PacketActivatePlayer *)packet).index;
    if (index == 0 || index == 1 || index == 2)
    {
        [self turnCardForActivePlayerAtIndex:index];
    }
    
    if (![self checkRoundOver])
        [self performSelector:@selector(activatePlayerWithPeerID:) withObject:peerID afterDelay:0.5f];
    else
    {
        Packet *packet = [Packet packetWithType:PacketTypeRoundFinish];
        [self sendPacketToServer:packet];
    }
}

- (void)activatePlayerWithPeerID:(NSString *)peerID
{
	NSAssert(!self.isServer, @"Must be client");
    
	Player *player = [self playerWithPeerID:peerID];
	_activePlayerPosition = player.position;
	[self activatePlayerAtPosition:_activePlayerPosition];
}

#pragma mark - Game Logic

- (void)startClientGameWithSession:(GKSession *)session playerName:(NSString *)name server:(NSString *)peerID
{
    self.isServer = NO;
    
	_session = session;
	_session.available = NO;
	_session.delegate = self;
	[_session setDataReceiveHandler:self withContext:nil];
    
	_serverPeerID = peerID;
	_localPlayerName = name;
    
	_state = GameStateWaitingForSignIn;
    
	[self.delegate gameWaitingForServerReady:self];
}

- (void)startServerGameWithSession:(GKSession *)session playerName:(NSString *)name clients:(NSArray *)clients
{
	self.isServer = YES;
    
	_session = session;
	_session.available = NO;
	_session.delegate = self;
	[_session setDataReceiveHandler:self withContext:nil];
    
	_state = GameStateWaitingForSignIn;
    
	[self.delegate gameWaitingForClientsReady:self];
    
    // Create the Player object for the server.
	Player *player = [[Player alloc] init];
	player.name = name;
	player.peerID = _session.peerID;
	player.position = PlayerPositionBottom;
	[_players setObject:player forKey:player.peerID];
    
	// Add a Player object for each client.
	int index = 0;
	for (NSString *peerID in clients)
	{
		Player *player = [[Player alloc] init];
		player.peerID = peerID;
		[_players setObject:player forKey:player.peerID];
        
		if (index == 0)
			player.position =  PlayerPositionTop;
		else if (index == 1)
			player.position = PlayerPositionTop;
        
		index++;
	}
    
    Packet *packet = [Packet packetWithType:PacketTypeSignInRequest];
	[self sendPacketToAllClients:packet];
}

- (void)beginGame
{
    _busyDealing = YES;
	_state = GameStateDealing;
	[self.delegate gameDidBegin:self];

    
    if (self.isServer)
	{
		[self pickRandomStartingPlayer];
		[self dealCards];
	}
}

- (void)beginAnotherRound
{
    _busyDealing = YES;
	_state = GameStateDealing;
	[self.delegate gameDidBegin:self];
    
    if (self.isServer)
	{
		//[self pickRandomStartingPlayer];
        _startingGamePlayerPosition++;
        if (_startingGamePlayerPosition > PlayerPositionTop)
            _startingGamePlayerPosition = PlayerPositionBottom;
        
        _activePlayerPosition = _startingGamePlayerPosition;
        _startingPlayerPosition = _startingGamePlayerPosition;
		[self dealCards];
	}
}

- (void)beginRound
{
    _firstTime = YES;
    _busyDealing = NO;
	_hasTurnedCard = NO;
    _envidoType = EnvidoTypeNothing;
    
	[self activatePlayerAtPosition:_activePlayerPosition];
}

- (void)finishRecycle
{
    _busyDealing = YES;
    _state = GameStateDealing;
    [self.delegate gameDidBegin:self];
    
    if (!self.isServer)
    {
        Packet *packet = [Packet packetWithType:PacketTypeFinishRecyclingCards];
        [self sendPacketToServer:packet];
    }
}

- (BOOL)checkSemiRoundFinish
{
    Player *playerBottom = [self playerAtPosition:PlayerPositionBottom];
    Player *playerTop = [self playerAtPosition:PlayerPositionTop];
    
    return ([playerTop.openCards cardCount] == [playerBottom.openCards cardCount])? YES : NO;        
}

- (BOOL)checkRoundOver
{
    BOOL roundOver = NO;
    
    if ([_winnersRound count] == 2)
    {
        if ([_winnersRound[0] isEqual:_winnersRound[1]]) 
            roundOver = YES;
    }
    else if ([_winnersRound count] == 3)
    {
        roundOver = YES;
    }
    return roundOver;
}

- (Player *)winnerRoundPlayerPosition
{    
    Player *startPlayer = [self playerAtPosition:_startingPlayerPosition];
    Player *otherPlayer = [self playerAtPosition:(_startingPlayerPosition==PlayerPositionTop)?PlayerPositionBottom:PlayerPositionTop];
    
    Card *cardStart = [startPlayer.openCards topmostCard];
    Card *cardOther = [otherPlayer.openCards topmostCard];
    
    return ([cardStart hasHigherPointsThan:cardOther]) ? startPlayer : otherPlayer;
}

- (void)recycleCardsAndDealAgain
{
    for (PlayerPosition position = PlayerPositionBottom; position <= PlayerPositionTop; position++)
    {
        Player *player = [self playerAtPosition:position];
        [player recycleAllCards];
    }
    
    Player *winnerPlayer = [self playerWithPeerID:[_winnersRound lastObject]];//[self winnerRoundPlayerPosition];
    winnerPlayer.score += [self trucoScore];
    
    if ([_winnersRound count] > 0) 
        [_winnersRound removeAllObjects];
    
    _busyDealing = YES;
    
    [self.delegate gameDidRecycleCards:self];
    
    if (self.isServer)
    {
        Packet *packet = [Packet packetWithType:PacketTypeRecycleCards];
        [self sendPacketToAllClients:packet];
    }
}

- (NSUInteger)trucoScore
{
    NSUInteger score = 0;
    switch (self.trucoState) {
            
        case TrucoStateNo:
            score = 0;
            break;
            
        case TrucoStateNothing:
            score = 1;
            break;
            
        case TrucoStateTruco:
            score = 2;
            break;
            
        case TrucoStateReTruco:
            score = 3;
            break;
            
        case TrucoStateQuieroValeCuatro:
            score = 4;
            break;
            
        default:
            break;
    }
    
    return score;
}

- (NSInteger)numberOfRound
{
    return [_winnersRound count];
}

#pragma mark - Handle Calling Truco or Envido

- (void)sendPacketServerClient:(Packet *)packet
{
    if (self.isServer)
		[self sendPacketToAllClients:packet];
    else
		[self sendPacketToServer:packet];
}

- (void)playerCalledEnvido:(Player *)player envidoType:(EnvidoType)type
{
    [self sendPacketServerClient:[PacketPlayerCalledEnvido packetWithEnvidoType:type]];
    _envidoType = type;
    _trucoState = TrucoStateNothing;
    
    NSString *title;
    switch (type) {
        case EnvidoTypeEnvido:
            title = @"Envido";
            break;
            
        case EnvidoTypeRealEnvido:
            title = @"Real Envido";
            break;
            
        case EnvidoTypeFaltaEnvido:
            title = @"Falta Envido";
            break;
            
        case EnvidoTypeEnvidoEnvido:
            title = @"Envido Envido";
            break;
            
        case EnvidoTypeEnvidoRealEnvido:
            title = @"Envido Real Envido";
            break;
            
        default:
            break;
    }
    
    [self.delegate gameWaitUntilRecieveResponse:self withTitle:title];
}

- (void)playerCalledTruco:(Player *)player trucoState:(TrucoState)state
{
    [self sendPacketServerClient:[PacketPlayerCalledTruco packetWithTrucoState:state]];
    _trucoState = state;
    
    NSString *title;
    switch (state) {
        case TrucoStateTruco:
            title = @"Truco";
            break;
            
        case TrucoStateReTruco:
            title = @"Re Truco";
            break;
            
        case TrucoStateQuieroValeCuatro:
            title = @"Quiero Vale Cuatro";
            break;
            
        default:
            break;
    }
    
    [self.delegate gameWaitUntilRecieveResponse:self withTitle:title];
}

- (void)handleEnvido:(PacketPlayerCalledEnvido *)packet
{
    if ([_winnersRound count] == 0)
    {
        self.envidoType = packet.envidoType;
        self.trucoState = TrucoStateNothing;
        
        [self.delegate gamePresentViewForEnvido:self];
    }
}

- (void)handleTruco:(PacketPlayerCalledTruco *)packet
{
    self.trucoState = packet.trucoState;
    
    [self.delegate gamePresentViewForTruco:self];
}

- (void)respondEnvido:(BOOL)respond
{
    if (_state == GameStatePlaying
		&& !_busyDealing
		&& !_hasTurnedCard
		&& [[self activePlayer].handCards cardCount] > 0)
    {
        [self sendPacketServerClient:[PacketEnvidoRespond packetWithRespond:respond andPeerID:[self playerAtPosition:PlayerPositionBottom].peerID]];
        [self showEnvidoRespond:@(respond) forPlayer:[self playerAtPosition:PlayerPositionBottom]];//[self performSelector:@selector(showEnvidoRespond:) withObject:@(respond) afterDelay:0.0];
    }
}

- (void)respondEnvidoEnvido
{
    [self playerCalledEnvido:[self playerAtPosition:PlayerPositionBottom] envidoType:EnvidoTypeEnvidoEnvido];
}

- (void)respondEnvidoBeforeTruco
{
    [self playerCalledEnvido:[self playerAtPosition:PlayerPositionBottom] envidoType:EnvidoTypeEnvido];
}

- (void)handleEnvidoRespond:(PacketEnvidoRespond *)packet;
{
    BOOL respond = packet.respond;
    [self showEnvidoRespond:@(respond) forPlayer:[self playerWithPeerID:packet.peerID]];
}

- (void)showEnvidoRespond:(NSNumber *)respond forPlayer:(Player *)player
{
    if ([respond boolValue] == YES)
    {
        Player *startPlayer = [self playerAtPosition:_startingPlayerPosition];
        Player *otherPlayer = [self playerAtPosition:(_startingPlayerPosition==PlayerPositionTop)?PlayerPositionBottom:PlayerPositionTop];
        
        NSInteger startEnvido = [startPlayer.envido integerValue];
        NSInteger otherEnvido = [otherPlayer.envido integerValue];
        
        if (startEnvido >= otherEnvido)
        {
            startPlayer.score += [self envidoScoreToPlayer:startPlayer andRespond:[respond boolValue]];
        }
        else if (startEnvido < otherEnvido)
        {
            otherPlayer.score += [self envidoScoreToPlayer:otherPlayer andRespond:[respond boolValue]];
        }
    }
    else
    {
        Player *otherPlayer = [self playerAtPosition:(player.position==PlayerPositionTop)?PlayerPositionBottom:PlayerPositionTop];
        otherPlayer.score += [self envidoScoreToPlayer:otherPlayer andRespond:[respond boolValue]];;
    }
    
    [self.delegate game:self showEnvidoRespond:[respond boolValue]];
}

- (NSUInteger)envidoScoreToPlayer:(Player *)player andRespond:(BOOL)respond
{
    NSUInteger score = 0;
    if (respond == YES)
    {
        switch (self.envidoType) {
                
            case EnvidoTypeEnvido:
                score = 2;
                break;
                
            case EnvidoTypeRealEnvido:
                score = 3;
                break;
                
            case EnvidoTypeFaltaEnvido:
            {
                Player *otherPlayer = [self playerAtPosition:(player.position==PlayerPositionTop)?PlayerPositionBottom:PlayerPositionTop];
                score = 15 - otherPlayer.score; //cambiar
                break;
            }
                
            case EnvidoTypeEnvidoEnvido:
                score = 4;
                break;
                
            case EnvidoTypeEnvidoRealEnvido:
                score = 5;
                break;
                
            default:
                break;
        }
    }
    else
    {
        switch (self.envidoType) {
                
            case EnvidoTypeEnvido:
            case EnvidoTypeRealEnvido:
            case EnvidoTypeFaltaEnvido:
                score = 1;
                break;
            case EnvidoTypeEnvidoEnvido:
            case EnvidoTypeEnvidoRealEnvido:
                score = 2;
                break;
            default:
                break;
        }
    }
    return score;
}

- (void)respondTruco:(BOOL)respond
{
    if (_state == GameStatePlaying
		&& !_busyDealing
		&& !_hasTurnedCard
		&& [[self activePlayer].handCards cardCount] > 0)
    {
        [self sendPacketServerClient:[PacketTrucoRespond packetWithRespond:respond andPeerID:[self playerAtPosition:PlayerPositionBottom].peerID]];
        [self showTrucoRespond:@(respond) forPlayer:[self playerAtPosition:PlayerPositionBottom]];//[self performSelector:@selector(showTrucoRespond:) withObject:@(respond) afterDelay:0.0];
    }
}

- (void)handleTrucoRespond:(PacketTrucoRespond *)packet
{
    BOOL respond = packet.respond;
    [self showTrucoRespond:@(respond) forPlayer:[self playerWithPeerID:packet.peerID]];
    
    if (self.isServer)
    {
        [self serverManageTrucoRespond:respond];
    }
    else
    {
        [self clientManageTrucoRespond:respond];
    }
}

- (void)showTrucoRespond:(NSNumber *)respond forPlayer:(Player *)player
{
    if ([respond boolValue] == NO)
    {
        Player *otherPlayer = [self playerAtPosition:(player.position==PlayerPositionTop)?PlayerPositionBottom:PlayerPositionTop];
        otherPlayer.score += [self trucoScoreForResponseNO];//otherPlayer.score =+ [self envidoScoreToPlayer:otherPlayer andRespond:[respond boolValue]];;
        self.trucoState = TrucoStateNo;
    }
    
    [self.delegate game:self showTrucoRespond:[respond boolValue]];
}

- (NSUInteger)trucoScoreForResponseNO
{
    NSUInteger score = 0;
    switch (self.trucoState) {
        case TrucoStateTruco:
            score = 1;
            break;
        case TrucoStateReTruco:
            score = 2;
            break;
        case TrucoStateQuieroValeCuatro:
            score = 3;
            break;
        default:
            break;
    }
    return score;
}

- (void)serverManageTrucoRespond:(BOOL)respond
{
    if (respond)
    {
    }
    else
    {
        self.trucoState = TrucoStateNo;
        [self performSelector:@selector(recycleCardsAndDealAgain) withObject:nil afterDelay:7.0f];
    }
}

- (void)clientManageTrucoRespond:(BOOL)respond
{
    /*
    if (respond)
    {
    }
    else
    {
        self.trucoState = TrucoStateNo;
    }*/
    
    [self sendPacketServerClient:[PacketClientReceivedTrucoRespond packetWithRespond:respond]];
}


- (NSDictionary *)envidoMessage
{
    NSDictionary *dict;
    NSString *title;
    NSString *message = nil;
    Player *startPlayer = [self playerAtPosition:_startingPlayerPosition];
    Player *otherPlayer = [self playerAtPosition:(_startingPlayerPosition==PlayerPositionTop)?PlayerPositionBottom:PlayerPositionTop];
    
    NSInteger startEnvido = [startPlayer.envido integerValue];
    NSInteger otherEnvido = [otherPlayer.envido integerValue];
    
    if (startPlayer.position == PlayerPositionBottom)
    {
        if (startEnvido >= otherEnvido)
        {
            title = @"Son Buenas";
            message = [NSString stringWithFormat:@"Tu: %i /nEl: ns/nc", startEnvido];
        }
        else
        {
            title = @"Son Malas";
            message = [NSString stringWithFormat:@"Tu: %i /nEl: %i", startEnvido, otherEnvido];
        }
    }
    else
    {
        if (startEnvido >= otherEnvido)
        {
            title = @"Son Malas";
            message = [NSString stringWithFormat:@"Tu: %i /nEl: %i", otherEnvido, startEnvido];
        }
        else
        {
            title = @"Son Buenas";
            message = [NSString stringWithFormat:@"Tu: %i /nEl: %i", otherEnvido, startEnvido];
        }
    }
    
    dict = @{@"title": title, @"message":message};
    
    return dict;
}

#pragma mark - Select Card

- (void)turnCardForPlayerAtBottomAtIndexCard:(NSUInteger)index
{
    if (_state == GameStatePlaying
		&& _activePlayerPosition == PlayerPositionBottom
		&& !_busyDealing
		&& !_hasTurnedCard
		&& [[self activePlayer].handCards cardCount] > 0)
	{
		BOOL isOK = [self turnCardForActivePlayerAtIndex:index];
        
        if (!self.isServer && isOK == YES)
		{
			Packet *packet = [PacketClientTurnedCard packetWithIndex:index];
            
			[self sendPacketToServer:packet];
		}
	}
}

- (BOOL)turnCardForActivePlayerAtIndex:(NSUInteger)index
{
	BOOL isOK = [self turnCardForPlayer:[self activePlayer] atIndex:index];
    
	if ([self checkSemiRoundFinish] && isOK == YES)
    {
        Player *winnerPlayer = [self winnerRoundPlayerPosition];
        [_winnersRound addObject:winnerPlayer.peerID];
    }
    
    if (self.isServer && isOK == YES)
    {
        if ([self checkRoundOver] && [self activePlayer].position != PlayerPositionBottom)
            [self performSelector:@selector(recycleCardsAndDealAgain) withObject:nil afterDelay:0.5f];
        else
        {
            if ([self activePlayer].position != PlayerPositionBottom)
                index = INVALID_INDEX;
            
            [self performSelector:@selector(activateNextPlayerWithCardAtIndex:) withObject:[NSNumber numberWithInt:index] afterDelay:0.1f];
        }
    }

    return isOK;
}

- (BOOL)turnCardForPlayer:(Player *)player atIndex:(NSUInteger)index
{
	NSAssert([player.handCards cardCount] > 0, @"Player has no more cards");
    
	Card *card = [player turnOverCardAtIndex:index];
    if (card)
    {
        _hasTurnedCard = YES;
        [self.delegate game:self player:player turnedOverCard:card];
        return YES;
    }
    else
        return NO;
}

- (void)activateNextPlayerWithCardAtIndex:(NSNumber *)index;
{
	NSAssert(self.isServer, @"Must be server");
    
	while (true)
	{
        if ([self checkSemiRoundFinish])
        {
            Player *winnerPlayer = [self winnerRoundPlayerPosition];
            _activePlayerPosition = winnerPlayer.position;
            _startingPlayerPosition = _activePlayerPosition;
        }
        else
        {
            _activePlayerPosition++;
            if (_activePlayerPosition > PlayerPositionTop)
                _activePlayerPosition = PlayerPositionBottom;
        }
        
		Player *nextPlayer = [self activePlayer];
		if (nextPlayer != nil)
		{
			[self activatePlayerAtPosition:_activePlayerPosition andCardIndex:[index intValue]];
			return;
		}
	}
}

#pragma mark - Networking Sending

- (void)sendPacketToAllClients:(Packet *)packet
{
    [_players enumerateKeysAndObjectsUsingBlock:^(id key, Player *obj, BOOL *stop)
     {
         obj.receivedResponse = [_session.peerID isEqualToString:obj.peerID];
     }];
    
	GKSendDataMode dataMode = GKSendDataReliable;
	NSData *data = [packet data];
	NSError *error;
	if (![_session sendDataToAllPeers:data withDataMode:dataMode error:&error])
	{
		NSLog(@"Error sending data to clients: %@", error);
	}
}

- (void)sendPacketToServer:(Packet *)packet
{
	GKSendDataMode dataMode = GKSendDataReliable;
	NSData *data = [packet data];
	NSError *error;
	if (![_session sendData:data toPeers:[NSArray arrayWithObject:_serverPeerID] withDataMode:dataMode error:&error])
	{
		NSLog(@"Error sending data to server: %@", error);
	}
}

#pragma mark - Networking Recieving

- (void)clientReceivedPacket:(Packet *)packet
{
	switch (packet.packetType)
	{
		case PacketTypeSignInRequest:
			if (_state == GameStateWaitingForSignIn)
			{
				_state = GameStateWaitingForReady;
                
				Packet *packet = [PacketSignInResponse packetWithPlayerName:_localPlayerName];
				[self sendPacketToServer:packet];
			}
			break;
            
        case PacketTypeServerReady:
			if (_state == GameStateWaitingForReady)
			{
				_players = ((PacketServerReady *)packet).players;
				[self changeRelativePositionsOfPlayers];
                
				Packet *packet = [Packet packetWithType:PacketTypeClientReady];
				[self sendPacketToServer:packet];
                
				[self beginGame];
			}
			break;
            
        case PacketTypeServerQuit:
			[self quitGameWithReason:QuitReasonServerQuit];
			break;
            
        case PacketTypeDealCards:
			if (_state == GameStateDealing)
			{
				[self handleDealCardsPacket:(PacketDealCards *)packet];
			}
			break;
            
        case PacketTypeActivatePlayer:
			if (_state == GameStatePlaying)
			{
				[self handleActivatePlayerPacket:(PacketActivatePlayer *)packet];
			}
			break;
        
        case PacketTypeRecycleCards:
            if (_state == GameStatePlaying)
            {
                [self recycleCardsAndDealAgain];
            }
            break;
            
        case PacketTypePlayerCalledEnvido:
            if (_state == GameStatePlaying && [_winnersRound count] == 0)
            {
                [self handleEnvido:((PacketPlayerCalledEnvido *)packet)];
            }
            break;
            
        case PacketTypePlayerCalledTruco:
            if (_state == GameStatePlaying)
            {
                [self handleTruco:((PacketPlayerCalledTruco *)packet)];
            }
            break;
            
        case PacketTypeTrucoRespond:
            if (_state == GameStatePlaying && _trucoState != TrucoStateNothing)
            {
                [self handleTrucoRespond:(PacketTrucoRespond *)packet];
            }
            break;
            
        case PacketTypeEnvidoRespond:
            if (_state == GameStatePlaying && _envidoType != EnvidoTypeNothing)
            {
                [self handleEnvidoRespond:(PacketEnvidoRespond *)packet];
            }
            break;
            
		default:
			NSLog(@"Client received unexpected packet: %@", packet);
			break;
	}
}

- (void)serverReceivedPacket:(Packet *)packet fromPlayer:(Player *)player
{
	switch (packet.packetType)
	{
		case PacketTypeSignInResponse:
			if (_state == GameStateWaitingForSignIn)
			{
				player.name = ((PacketSignInResponse *)packet).playerName;
                
				if ([self receivedResponsesFromAllPlayers])
				{
					_state = GameStateWaitingForReady;
                    
					Packet *packet = [PacketServerReady packetWithPlayers:_players];
					[self sendPacketToAllClients:packet];
				}
			}
			break;
            
        case PacketTypeClientReady:
			if (_state == GameStateWaitingForReady && [self receivedResponsesFromAllPlayers])
			{
				[self beginGame];
			}
			break;
            
        case PacketTypeClientQuit:
			[self clientDidDisconnect:player.peerID];
			break;
            
        case PacketTypeClientDealtCards:
			if (_state == GameStateDealing && [self receivedResponsesFromAllPlayers])
			{
				_state = GameStatePlaying;
			}
			break;
            
        case PacketTypeClientTurnedCard:
			if (_state == GameStatePlaying && player == [self activePlayer])
			{
                NSUInteger index = ((PacketClientTurnedCard *)packet).index;
				[self turnCardForActivePlayerAtIndex:index];
			}
			break;
            
        case PacketTypeRoundFinish:
            if (_state == GameStatePlaying && [self receivedResponsesFromAllPlayers] && player == [self activePlayer])
            {
                [self recycleCardsAndDealAgain];
            }
            break;
            
        case PacketTypeFinishRecyclingCards:
            if (_state == GameStateDealing && [self receivedResponsesFromAllPlayers])
            {
                [self beginAnotherRound];
            }
            break;
            
        case PacketTypePlayerCalledEnvido:
            if (_state == GameStatePlaying && [_winnersRound count] == 0)
            {
                [self handleEnvido:((PacketPlayerCalledEnvido *)packet)];
            }
            break;
            
        case PacketTypePlayerCalledTruco:
            if (_state == GameStatePlaying)
            {
                [self handleTruco:((PacketPlayerCalledTruco *)packet)];
            }
            break;
            
        case PacketTypeTrucoRespond:
            if (_state == GameStatePlaying && _trucoState != TrucoStateNothing)
            {
                [self handleTrucoRespond:(PacketTrucoRespond *)packet];
            }
            break;
            
        case PacketTypeEnvidoRespond:
            if (_state == GameStatePlaying && _envidoType != EnvidoTypeNothing)
            {
                [self handleEnvidoRespond:(PacketEnvidoRespond *)packet];
            }
            break;
            
        case PacketTypeClientReceivedTrucoRespond:
            if (_state == GameStatePlaying)
            {
                [self serverManageTrucoRespond:((PacketClientReceivedTrucoRespond *)packet).respond];
            }
            break;
            
		default:
			NSLog(@"Server received unexpected packet: %@", packet);
			break;
	}
}

#pragma mark - Network Disconnect

- (void)clientDidDisconnect:(NSString *)peerID
{
	if (_state != GameStateQuitting)
	{
		Player *player = [self playerWithPeerID:peerID];
		if (player != nil)
		{
			[_players removeObjectForKey:peerID];
            
			if (_state != GameStateWaitingForSignIn)
			{
				// Tell the other clients that this one is now disconnected.
				if (self.isServer)
				{
					//PacketOtherClientQuit *packet = [PacketOtherClientQuit packetWithPeerID:peerID];
					//[self sendPacketToAllClients:packet];
				}
                
				[self.delegate game:self playerDidDisconnect:player];
			}
		}
	}
}

#pragma mark - Quit Game

- (void)quitGameWithReason:(QuitReason)reason
{
	_state = GameStateQuitting;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
	if (reason == QuitReasonUserQuit)
	{
		if (self.isServer)
		{
			Packet *packet = [Packet packetWithType:PacketTypeServerQuit];
			[self sendPacketToAllClients:packet];
		}
		else
		{
			Packet *packet = [Packet packetWithType:PacketTypeClientQuit];
			[self sendPacketToServer:packet];
		}
	}
    
	[_session disconnectFromAllPeers];
	_session.delegate = nil;
	_session = nil;
    
	[self.delegate game:self didQuitWithReason:reason];
}

#pragma mark - GKSessionDelegate

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
#ifdef DEBUG
	NSLog(@"Game: peer %@ changed state %d", peerID, state);
#endif
    
    if (state == GKPeerStateDisconnected)
	{
		if (self.isServer)
		{
			[self clientDidDisconnect:peerID];
		}
        [self quitGameWithReason:QuitReasonConnectionDropped];
	}
    else if ([peerID isEqualToString:_serverPeerID])
    {
        [self quitGameWithReason:QuitReasonConnectionDropped];
    }
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
#ifdef DEBUG
	NSLog(@"Game: connection request from peer %@", peerID);
#endif
    
	[session denyConnectionFromPeer:peerID];
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
#ifdef DEBUG
	NSLog(@"Game: connection with peer %@ failed %@", peerID, error);
#endif
    
	// Not used.
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
#ifdef DEBUG
	NSLog(@"Game: session failed %@", error);
#endif
    
    if ([[error domain] isEqualToString:GKSessionErrorDomain])
	{
		if (_state != GameStateQuitting)
		{
			[self quitGameWithReason:QuitReasonConnectionDropped];
		}
	}
}

#pragma mark - GKSession Data Receive Handler

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peerID inSession:(GKSession *)session context:(void *)context
{
#ifdef DEBUG
	NSLog(@"Game: receive data from peer: %@, data: %@, length: %d", peerID, data, [data length]);
#endif
    
    Packet *packet = [Packet packetWithData:data];
	if (packet == nil)
	{
		NSLog(@"Invalid packet: %@", data);
		return;
	}
    
    
	Player *player = [self playerWithPeerID:peerID];
    if (player != nil)
	{
		player.receivedResponse = YES;  // this is the new bit
	}
    
	if (self.isServer)
		[self serverReceivedPacket:packet fromPlayer:player];
	else
		[self clientReceivedPacket:packet];
}

@end
