//
//  Packet.m
//  ReTruco
//
//  Created by Emiliano Bivachi on 05/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import "Packet.h"
#import "Card.h"
#import "NSData+SnapAdditions.h"
#import "PacketSignInResponse.h"
#import "PacketServerReady.h"
#import "PacketDealCards.h"
#import "PacketActivatePlayer.h"
#import "PacketClientTurnedCard.h"
#import "PacketTrucoRespond.h"
#import "PacketEnvidoRespond.h"
#import "PacketPlayerCalledEnvido.h"
#import "PacketPlayerCalledTruco.h"
#import "PacketClientReceivedTrucoRespond.h"
#import "PacketClientReceivedEnvidoRespond.h"

const size_t PACKET_HEADER_SIZE = 10;

@implementation Packet

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ number=%d, type=%d", [super description], self.packetNumber, self.packetType];
}

+ (id)packetWithType:(PacketType)packetType
{
	return [[[self class] alloc] initWithType:packetType];
}

+ (id)packetWithData:(NSData *)data
{
	if ([data length] < PACKET_HEADER_SIZE)
	{
		NSLog(@"Error: Packet too small");
		return nil;
	}
    
	if ([data rw_int32AtOffset:0] != 'SNAP')
	{
		NSLog(@"Error: Packet has invalid header");
		return nil;
	}
    
	int packetNumber = [data rw_int32AtOffset:4];
	PacketType packetType = [data rw_int16AtOffset:8];
    
	Packet *packet;
    
	switch (packetType)
	{
		case PacketTypeSignInRequest:
		case PacketTypeClientReady:
		case PacketTypeClientDealtCards:
		case PacketTypeServerQuit:
		case PacketTypeClientQuit:
        case PacketTypeRecycleCards:
        case PacketTypeRoundFinish:
        case PacketTypeFinishRecyclingCards:
			packet = [Packet packetWithType:packetType];
			break;
            
		case PacketTypeSignInResponse:
			packet = [PacketSignInResponse packetWithData:data];
			break;
            
        case PacketTypeServerReady:
			packet = [PacketServerReady packetWithData:data];
			break;
            
        case PacketTypeDealCards:
			packet = [PacketDealCards packetWithData:data];
			break;
            
        case PacketTypeActivatePlayer:
			packet = [PacketActivatePlayer packetWithData:data];
			break;
            
        case PacketTypeClientTurnedCard:
            packet = [PacketClientTurnedCard packetWithData:data];
            break;
            
        case PacketTypePlayerCalledEnvido:
            packet = [PacketPlayerCalledEnvido packetWithData:data];
            break;
            
        case PacketTypePlayerCalledTruco:
            packet = [PacketPlayerCalledTruco packetWithData:data];
            break;
            
        case PacketTypeTrucoRespond:
            packet = [PacketTrucoRespond packetWithData:data];
            break;
            
        case PacketTypeEnvidoRespond:
            packet = [PacketEnvidoRespond packetWithData:data];
            break;
        
        case PacketTypeClientReceivedTrucoRespond:
            packet = [PacketClientReceivedTrucoRespond packetWithData:data];
            break;
            
        case PacketTypeClientReceivedEnvidoRespond:
            packet = [PacketClientReceivedEnvidoRespond packetWithData:data];
                        
		default:
			NSLog(@"Error: Packet has invalid type");
			return nil;
	}
    
    packet.packetNumber = packetNumber;
	return packet;
    
	return packet;
}

- (id)initWithType:(PacketType)packetType
{
	if ((self = [super init]))
	{
        self.packetNumber = -1;
		self.packetType = packetType;
	}
	return self;
}

- (void)addPayloadToData:(NSMutableData *)data
{
	// base class does nothing
}

- (NSData *)data
{
	NSMutableData *data = [[NSMutableData alloc] initWithCapacity:100];
    
	[data rw_appendInt32:'SNAP'];   // 0x534E4150
	[data rw_appendInt32:self.packetNumber];
	[data rw_appendInt16:self.packetType];
    
    [self addPayloadToData:data];
    
	return data;
}

- (void)addCards:(NSMutableDictionary *)cards toPayload:(NSMutableData *)data
{
	[cards enumerateKeysAndObjectsUsingBlock:^(id key, NSArray *array, BOOL *stop)
     {
         [data rw_appendString:key];
         [data rw_appendInt8:[array count]];
         
         for (int t = 0; t < [array count]; ++t)
         {
             Card *card = [array objectAtIndex:t];
             [data rw_appendInt8:card.suit];
             [data rw_appendInt8:card.value];
         }
     }];
}

+ (NSMutableDictionary *)cardsFromData:(NSData *)data atOffset:(size_t) offset
{
	size_t count;
    
	NSMutableDictionary *cards = [NSMutableDictionary dictionaryWithCapacity:MAX_PLAYER];
    
	while (offset < [data length])
	{
		NSString *peerID = [data rw_stringAtOffset:offset bytesRead:&count];
		offset += count;
        
		int numberOfCards = [data rw_int8AtOffset:offset];
		offset += 1;
        
		NSMutableArray *array = [NSMutableArray arrayWithCapacity:numberOfCards];
        
		for (int t = 0; t < numberOfCards; ++t)
		{
			int suit = [data rw_int8AtOffset:offset];
			offset += 1;
            
			int value = [data rw_int8AtOffset:offset];
			offset += 1;
            
			Card *card = [[Card alloc] initWithSuit:suit value:value];
			[array addObject:card];
		}
        
		[cards setObject:array forKey:peerID];
	}
    
	return cards;
}

@end
