//
//  PacketDealCards.h
//  ReTruco
//
//  Created by Emiliano Bivachi on 08/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import "Packet.h"

@class Player;

@interface PacketDealCards : Packet

@property (nonatomic, strong) NSDictionary *cards;
@property (nonatomic, copy) NSString *startingPeerID;

+ (id)packetWithCards:(NSDictionary *)cards startingWithPlayerPeerID:(NSString *)startingPeerID;

@end
