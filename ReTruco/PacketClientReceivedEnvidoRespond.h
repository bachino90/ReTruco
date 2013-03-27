//
//  PacketClientReceivedEnvidoRespond.h
//  ReTruco
//
//  Created by Emiliano Bivachi on 21/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import "Packet.h"

@interface PacketClientReceivedEnvidoRespond : Packet

@property (nonatomic) BOOL respond;

+ (id)packetWithRespond:(BOOL)respond;

@end
