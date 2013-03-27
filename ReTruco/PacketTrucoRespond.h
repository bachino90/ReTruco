//
//  PacketTrucoRespond.h
//  ReTruco
//
//  Created by Emiliano Bivachi on 19/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import "Packet.h"

@interface PacketTrucoRespond : Packet

@property (nonatomic) BOOL respond;
@property (nonatomic, copy) NSString *peerID;

+ (id)packetWithRespond:(BOOL)respond andPeerID:(NSString *)peerID;

@end
