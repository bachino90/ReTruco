//
//  PacketPlayerCalledTruco.m
//  ReTruco
//
//  Created by Emiliano Bivachi on 20/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import "PacketPlayerCalledTruco.h"
#import "NSData+SnapAdditions.h"

@implementation PacketPlayerCalledTruco

+ (id)packetWithTrucoState:(TrucoState)state
{
    return [[[self class] alloc] initWithTrucoState:state];
}

- (id)initWithTrucoState:(TrucoState)state
{
    if ((self = [super initWithType:PacketTypePlayerCalledTruco]))
	{
		self.trucoState = state;
	}
	return self;
}

+ (id)packetWithData:(NSData *)data
{
	TrucoState state = [data rw_int8AtOffset:PACKET_HEADER_SIZE];
	return [[self class] packetWithTrucoState:state];
}

- (void)addPayloadToData:(NSMutableData *)data
{
	[data rw_appendInt8:self.trucoState];
}


@end
