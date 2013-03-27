//
//  PacketClientReceivedEnvidoRespond.m
//  ReTruco
//
//  Created by Emiliano Bivachi on 21/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import "PacketClientReceivedEnvidoRespond.h"
#import "NSData+SnapAdditions.h"

@implementation PacketClientReceivedEnvidoRespond

+ (id)packetWithRespond:(BOOL)respond;
{
	return [[[self class] alloc] initWithRespond:respond];
}

- (id)initWithRespond:(BOOL)respond;
{
	if ((self = [super initWithType:PacketTypeClientReceivedEnvidoRespond]))
	{
		self.respond = respond;
	}
	return self;
}

+ (id)packetWithData:(NSData *)data
{
	BOOL respond = [data rw_int8AtOffset:PACKET_HEADER_SIZE];
	return [[self class] packetWithRespond:respond];
}

- (void)addPayloadToData:(NSMutableData *)data
{
	[data rw_appendInt8:self.respond];
}


@end
