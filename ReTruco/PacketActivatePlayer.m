//
//  PacketActivatePlayer.m
//  ReTruco
//
//  Created by Emiliano Bivachi on 08/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import "PacketActivatePlayer.h"
#import "NSData+SnapAdditions.h"

@implementation PacketActivatePlayer

+ (id)packetWithPeerID:(NSString *)peerID
{
	return [[[self class] alloc] initWithPeerID:peerID andIndex:INVALID_INDEX];
}

+ (id)packetWithPeerID:(NSString *)peerID andIndex:(NSUInteger)index
{
	return [[[self class] alloc] initWithPeerID:peerID andIndex:index];
}

- (id)initWithPeerID:(NSString *)peerID andIndex:(NSUInteger)index
{
	if ((self = [super initWithType:PacketTypeActivatePlayer]))
	{
		self.peerID = peerID;
        self.index = index;
	}
	return self;
}

+ (id)packetWithData:(NSData *)data
{
	size_t count;
	NSString *peerID = [data rw_stringAtOffset:PACKET_HEADER_SIZE bytesRead:&count];
    NSUInteger index = [data rw_int8AtOffset:(PACKET_HEADER_SIZE + count)];
	return [[self class] packetWithPeerID:peerID andIndex:index];
}

- (void)addPayloadToData:(NSMutableData *)data
{
	[data rw_appendString:self.peerID];
    [data rw_appendInt8:self.index];
}

@end
