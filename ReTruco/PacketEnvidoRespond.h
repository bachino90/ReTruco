//
//  PacketEnvidoRespond.h
//  ReTruco
//
//  Created by Emiliano Bivachi on 21/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import "Packet.h"

@interface PacketEnvidoRespond : Packet

@property (nonatomic) BOOL respond;
@property (nonatomic, copy) NSString *peerID;

+ (id)packetWithRespond:(BOOL)respond andPeerID:(NSString *)peerID;

@end
