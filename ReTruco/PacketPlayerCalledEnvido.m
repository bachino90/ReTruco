//
//  PacketPlayerCalledEnvido.m
//  ReTruco
//
//  Created by Emiliano Bivachi on 20/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import "PacketPlayerCalledEnvido.h"
#import "NSData+SnapAdditions.h"

@implementation PacketPlayerCalledEnvido

+ (id)packetWithEnvidoType:(EnvidoType)type
{
    return [[[self class] alloc] initWithEnvidoType:type];
}

- (id)initWithEnvidoType:(EnvidoType)type
{
    if ((self = [super initWithType:PacketTypePlayerCalledEnvido]))
	{
		self.envidoType = type;
	}
	return self;
}

+ (id)packetWithData:(NSData *)data
{
	EnvidoType type = [data rw_int8AtOffset:PACKET_HEADER_SIZE];
	return [[self class] packetWithEnvidoType:type];
}

- (void)addPayloadToData:(NSMutableData *)data
{
	[data rw_appendInt8:self.envidoType];
}


@end
