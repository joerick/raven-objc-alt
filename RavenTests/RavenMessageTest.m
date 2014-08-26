//
//  RavenClientTests.m
//  RavenClientTests
//
//  Created by David Cramer on 12/28/12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import "RavenMessageTest.h"

NSString *const testDSN = @"http://public:secret@example.com/foo";

@implementation RavenMessageTest

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testGenerateUUID
{
    RavenMessage *message = [RavenMessage messageWithString:@"An example message"];
    NSDictionary *dictionary = [message dictionaryRepresentation];
    NSString *uuid = dictionary[@"event_id"];
    
    XCTAssertEqual([uuid length], (NSUInteger)32, @"Invalid value for UUID returned: %@", uuid);
}

- (void)testCaptureMessageWithOnlyMessage
{
    RavenMessage *message = [RavenMessage messageWithString:@"An example message"];
    
    NSDictionary *dictionary = [message dictionaryRepresentation];
    NSArray *keys = [[message dictionaryRepresentation] allKeys];
    
    XCTAssertTrue([keys containsObject:@"event_id"], @"Missing event_id");
    XCTAssertTrue([keys containsObject:@"message"], @"Missing message");
    XCTAssertTrue([keys containsObject:@"level"], @"Missing level");
    XCTAssertTrue([keys containsObject:@"timestamp"], @"Missing timestamp");
    XCTAssertEqual([dictionary valueForKey:@"message"], @"An example message",
                 @"Invalid value for message: %@", [dictionary valueForKey:@"message"]);
    XCTAssertTrue([[dictionary valueForKey:@"level"] isEqualToString:@"info"],
                   @"Invalid value for level: %@", [dictionary valueForKey:@"level"]);
}

- (void)testCaptureMessageWithMessageAndLevel
{
    RavenMessage *message = [RavenMessage messageWithString:@"An example message" level:kRavenLogLevelWarning];

    NSDictionary *dictionary = [message dictionaryRepresentation];
    NSArray *keys = [dictionary allKeys];

    XCTAssertTrue([keys containsObject:@"event_id"], @"Missing event_id");
    XCTAssertTrue([keys containsObject:@"message"], @"Missing message");
    XCTAssertTrue([keys containsObject:@"level"], @"Missing level");
    XCTAssertTrue([keys containsObject:@"timestamp"], @"Missing timestamp");
    XCTAssertTrue([keys containsObject:@"platform"], @"Missing platform");
    XCTAssertEqual([dictionary valueForKey:@"message"], @"An example message",
                   @"Invalid value for message: %@", [dictionary valueForKey:@"message"]);
    XCTAssertTrue([[dictionary valueForKey:@"level"] isEqualToString:@"warning"],
                 @"Invalid value for level: %@", [dictionary valueForKey:@"level"]);
    XCTAssertEqual([dictionary valueForKey:@"platform"], @"objc",
                   @"Invalid value for platform: %@", [dictionary valueForKey:@"platform"]);
}

- (void)testCaptureMessageWithMessageAndLevelAndExtraAndTags
{
    RavenMessage *message = [RavenMessage messageWithString:@"An example message" level:kRavenLogLevelWarning];
 
    NSDictionary *dictionary = [message dictionaryRepresentationWithExtra:@{ @"key": @"extra value" }
                                                                     tags:@{ @"key": @"tag value" }];
    NSArray *keys = [dictionary allKeys];

    XCTAssertTrue([keys containsObject:@"event_id"], @"Missing event_id");
    XCTAssertTrue([keys containsObject:@"message"], @"Missing message");
    XCTAssertTrue([keys containsObject:@"level"], @"Missing level");
    XCTAssertTrue([keys containsObject:@"timestamp"], @"Missing timestamp");
    XCTAssertTrue([keys containsObject:@"platform"], @"Missing platform");
    XCTAssertTrue([keys containsObject:@"extra"], @"Missing extra");
    XCTAssertTrue([keys containsObject:@"tags"], @"Missing tags");

    XCTAssertEqual([[dictionary objectForKey:@"extra"] objectForKey:@"key"], @"extra value", @"Missing extra data");
    XCTAssertEqual([[dictionary objectForKey:@"tags"] objectForKey:@"key"], @"tag value", @"Missing tags data");

    XCTAssertEqual([dictionary valueForKey:@"message"], @"An example message",
                   @"Invalid value for message: %@", [dictionary valueForKey:@"message"]);
    XCTAssertTrue([[dictionary valueForKey:@"level"] isEqualToString:@"warning"],
                 @"Invalid value for level: %@", [dictionary valueForKey:@"level"]);
    XCTAssertEqual([dictionary valueForKey:@"platform"], @"objc",
                   @"Invalid value for platform: %@", [dictionary valueForKey:@"platform"]);
}

- (void)testClientWithExtraAndTags
{
    RavenMessage *message = [RavenMessage messageWithString:@"An example message" level:kRavenLogLevelWarning];
    
    message.tags = @{ @"key": @"value" };
    message.extra = @{ @"key": @"value" };
    
    NSDictionary *dictionary = [message dictionaryRepresentationWithExtra:@{ @"key2": @"extra value" }
                                                                     tags:@{ @"key2": @"tag value" }];


    NSArray *keys = [dictionary allKeys];

    XCTAssertTrue([keys containsObject:@"extra"], @"Missing extra");
    XCTAssertTrue([keys containsObject:@"tags"], @"Missing tags");
    XCTAssertEqual([[dictionary objectForKey:@"extra"] objectForKey:@"key"], @"value", @"Missing extra data");
    XCTAssertEqual([[dictionary objectForKey:@"tags"] objectForKey:@"key"], @"value", @"Missing tags data");

    XCTAssertEqual([[dictionary objectForKey:@"extra"] objectForKey:@"key2"], @"extra value", @"Missing extra data");
    XCTAssertEqual([[dictionary objectForKey:@"tags"] objectForKey:@"key2"], @"tag value", @"Missing tags data");

}

- (void)testClientWithRewritingExtraAndTags
{
    RavenMessage *message = [RavenMessage messageWithString:@"An example message" level:kRavenLogLevelWarning];
    
    message.tags = @{ @"key": @"value" };
    message.extra = @{ @"key": @"value" };
    
    NSDictionary *dictionary = [message dictionaryRepresentationWithExtra:@{ @"key": @"extra value" }
                                                                     tags:@{ @"key": @"tag value" }];
    
    NSArray *keys = [dictionary allKeys];

    XCTAssertTrue([keys containsObject:@"extra"], @"Missing extra");
    XCTAssertTrue([keys containsObject:@"tags"], @"Missing tags");

    XCTAssertEqual([[dictionary objectForKey:@"extra"] objectForKey:@"key"], @"value", @"Incorrect extra data");
    XCTAssertEqual([[dictionary objectForKey:@"tags"] objectForKey:@"key"], @"value", @"Incorrect tags data");
}

@end
