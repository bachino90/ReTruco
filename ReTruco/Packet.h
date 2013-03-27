//
//  Packet.h
//  ReTruco
//
//  Created by Emiliano Bivachi on 05/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
	PacketTypeSignInRequest = 0x64,    // server to client
	PacketTypeSignInResponse,          // client to server
    
	PacketTypeServerReady,             // server to client
	PacketTypeClientReady,             // client to server
    
	PacketTypeDealCards,               // server to client
	PacketTypeClientDealtCards,        // client to server
    
	PacketTypeActivatePlayer,          // server to client
	PacketTypeClientTurnedCard,        // client to server
    
    PacketTypeRoundFinish,
    PacketTypeRecycleCards,
    PacketTypeFinishRecyclingCards,
    
    PacketTypePlayerCalledEnvido,
    PacketTypePlayerCalledTruco,
    
    PacketTypeTrucoRespond,
    PacketTypeEnvidoRespond,
    
    PacketTypeClientReceivedTrucoRespond,
    PacketTypeClientReceivedEnvidoRespond,
        
	PacketTypeServerQuit,              // server to client
	PacketTypeClientQuit,              // client to server
}
PacketType;

const size_t PACKET_HEADER_SIZE;

@interface Packet : NSObject

@property (nonatomic, assign) PacketType packetType;
@property (nonatomic, assign) int packetNumber;

+ (id)packetWithType:(PacketType)packetType;
+ (id)packetWithData:(NSData *)data;

- (id)initWithType:(PacketType)packetType;

- (NSData *)data;

+ (NSDictionary *)cardsFromData:(NSData *)data atOffset:(size_t) offset;
- (void)addCards:(NSDictionary *)cards toPayload:(NSMutableData *)data;

@end
