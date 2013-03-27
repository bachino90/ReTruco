//
//  PacketEnvidoRespond.m
//  ReTruco
//
//  Created by Emiliano Bivachi on 21/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import "PacketEnvidoRespond.h"
#import "NSData+SnapAdditions.h"

@implementation PacketEnvidoRespond

+ (id)packetWithRespond:(BOOL)respond andPeerID:(NSString *)peerID;
{
	return [[[self class] alloc] initWithRespond:respond andPeerID:peerID];
}

- (id)initWithRespond:(BOOL)respond andPeerID:(NSString *)peerID;
{
	if ((self = [super initWithType:PacketTypeEnvidoRespond]))
	{
		self.respond = respond;
        self.peerID = peerID;
	}
	return self;
}

+ (id)packetWithData:(NSData *)data
{
	BOOL respond = [data rw_int8AtOffset:PACKET_HEADER_SIZE];
    size_t count;
	NSString *peerID = [data rw_stringAtOffset:(PACKET_HEADER_SIZE +1)bytesRead:&count];
	return [[self class] packetWithRespond:respond andPeerID:peerID];
}

- (void)addPayloadToData:(NSMutableData *)data
{
	[data rw_appendInt8:self.respond];
    [data rw_appendString:self.peerID];
}


@end
