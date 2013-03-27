//
//  PacketClientTurnedCard.m
//  ReTruco
//
//  Created by Emiliano Bivachi on 10/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import "PacketClientTurnedCard.h"
#import "NSData+SnapAdditions.h"

@implementation PacketClientTurnedCard

+ (id)packetWithIndex:(NSUInteger)index;
{
	return [[[self class] alloc] initWithIndex:index];
}

- (id)initWithIndex:(NSUInteger)index
{
	if ((self = [super initWithType:PacketTypeClientTurnedCard]))
	{
		self.index = index;
	}
	return self;
}

+ (id)packetWithData:(NSData *)data
{
	NSUInteger index = [data rw_int8AtOffset:PACKET_HEADER_SIZE];
	return [[self class] packetWithIndex:index];
}

- (void)addPayloadToData:(NSMutableData *)data
{
	[data rw_appendInt8:self.index];
}


@end
