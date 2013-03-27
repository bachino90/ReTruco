//
//  PacketActivatePlayer.h
//  ReTruco
//
//  Created by Emiliano Bivachi on 08/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import "Packet.h"

@interface PacketActivatePlayer : Packet

@property (nonatomic, copy) NSString *peerID;
@property (nonatomic) NSUInteger index;

+ (id)packetWithPeerID:(NSString *)peerID;
+ (id)packetWithPeerID:(NSString *)peerID andIndex:(NSUInteger)index;
@end
