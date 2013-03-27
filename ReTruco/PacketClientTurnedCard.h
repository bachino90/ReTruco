//
//  PacketClientTurnedCard.h
//  ReTruco
//
//  Created by Emiliano Bivachi on 10/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import "Packet.h"

@interface PacketClientTurnedCard : Packet

@property (nonatomic) NSUInteger index;

+ (id)packetWithIndex:(NSUInteger)index;

@end
