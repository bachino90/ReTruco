//
//  PacketClientReceivedTrucoRespond.h
//  ReTruco
//
//  Created by Emiliano Bivachi on 20/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import "Packet.h"

@interface PacketClientReceivedTrucoRespond : Packet

@property (nonatomic) BOOL respond;

+ (id)packetWithRespond:(BOOL)respond;

@end
