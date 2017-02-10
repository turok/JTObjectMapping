//
//  JTObjectMappingTests.m
//  JTObjectMappingTests
//
//  Created by james on 9/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "JTObjectMappingTests.h"
#import "NSObject+JTObjectMapping.h"
#import "JTUserTest.h"
#import "JTSocialNetworkTest.h"
#import "JPNestedArrayTest.h"

#define EIGHTEEN_YEARS_IN_SECONDS 567993600

// when the unicode string is mapped with lossy ASCII the elipses character (0x2026) will convert to three periods
#define DATA_STRING_UNICODE @"elipses are unicode characters…periods are not"
#define DATA_STRING_ASCII   @"elipses are unicode characters...periods are not"
#define AVATAR_URL @"http://en.gravatar.com/userimage/11332249/d73901242ae1c7e33bcc7c83257ac165.jpg"

@implementation JTObjectMappingTests
@synthesize json, mapping, object;

- (void)setUp
{
    [super setUp];

    // Set-up code here.

    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"JTObjectMappingTests" ofType:@"json"];
    self.json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:jsonPath]
                                                options:0
                                                  error:NULL];

    NSDictionary *socialNetworkMapping = @{
            @"twitter": @"twitterID",
            @"facebook": @"facebookID"};
    
    NSString *dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    
    // Define the mapping between JSON dictionary-keys to the object properties.
    // Note how basic foundation types (NSString, NSDictionary, NSArray, NSSet, NSNumber)
    // are automatically mapped if the json key is the same as the property name.
    // You need to specify a mapping (as below) if the json key and objC property name are different,
    // or if you want to map to a custom object (see the JTUserTest mapping below)
    self.mapping = @{@"p_name": @"name",
            @"p_title": @"title",
            @"p_age": @"age",
            @"p_childs": @"childs",
            @"p_users": [JTUserTest mappingWithKey:@"users"
                                           mapping:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   @"name", @"p_name",
                                                           nil]],
            // NSSet mapping
            @"favorite_colors": [NSSet mappingWithKey:@"favoriteColors"],

            // NSSet keypath
            @"hashed.string": @"hashedString",
            @"hashed.user": [JTUserTest mappingWithKey:@"hashedUser"
                                               mapping:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       @"name", @"p_name",
                                                               nil]],

            // NSDate mapping -- by format or since the epoch
            @"create_date": [NSDate mappingWithKey:@"createDate"
                                  dateFormatString:dateFormat],
            // NSDate mapping with seconds since the epoch (1==seconds, 1000==milliseconds)
            @"eighteenth_birthday": [NSDate mappingWithKey:@"eighteenthBirthday"
                                         divisorForSeconds:1],

            // NSData mapping
            @"data": [NSData mappingWithKey:@"data" usingEncoding:NSUTF8StringEncoding],
            // NSData mapping (lossy ascii)
            @"dataLossy": [NSData mappingWithKey:@"dataLossy" usingEncoding:NSASCIIStringEncoding allowLossy:YES],

            @"avatarURL": [NSURL mappingWithKey:@"avatarURL"],

            // This specifies a mapping a child object (JTSocialNetwork) and a child dictionary in the json dictionary
            // (it too uses a map of json keys to its properties, the `socialNetworkMapping` dictionary)
            @"social_networks": [JTSocialNetworkTest mappingWithKey:@"socialNetwork"
                                                            mapping:socialNetworkMapping],

            @"nestedArray": [JPNestedArrayTest mappingWithKey:@"nestedArray"
                                                      mapping:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              @"array", @"array", nil]],

            @"p_null": @"null",
            @"null_date": [NSDate mappingWithKey:@"nullDate"
                                dateFormatString:dateFormat],
            @"null_child": [JTSocialNetworkTest mappingWithKey:@"nullChild"
                                                       mapping:socialNetworkMapping],
            @"null_array": @"nullArray",
            @"null_set": @"nullSet",
            @"null_number": @"nullNumber",
            // missing auto-mapping -- this key doesn't exist in the json, which is fine
            @"missingString": @"missingString",
            // missing class-mapping -- this key doesn't exist in the json, which is fine
            @"missingDate": [NSDate mappingWithKey:@"missingDate" divisorForSeconds:1],

            @"description": @"desc"};

    self.object = [JTUserTest objectFromJSONObject:json mapping:mapping];
}

- (void)tearDown
{
    // Tear-down code here.
    self.json = nil;
    self.mapping = nil;
    self.object = nil;

    [super tearDown];
}

//- (void)testPrintJSON {
//    NSLog(@"%@", self.json);
//}


- (void)testTitle {
    XCTAssertTrue([self.object.title isEqual:@"Manager"], @"title = %@ fails to equal %@", self.object.title, @"Manager");
}

- (void)testName {
    XCTAssertTrue([self.object.name isEqual:@"Bob"], @"name = %@ fails to equal %@", self.object.name, @"Bob");
}

- (void)testAge {
    XCTAssertTrue([self.object.age isEqualToNumber:[NSNumber numberWithInt:30]], @"age = %@ fails to equal %@", self.object.age, [NSNumber numberWithInt:30]);
}

- (void)testSocialTwitter {
    XCTAssertTrue([self.object.socialNetwork.twitterID isEqual:@"@bob"], @"twitterID = %@ fails to equal %@", self.object.socialNetwork.twitterID, @"@bob");
}

- (void)testSocialFacebook {
    XCTAssertTrue([self.object.socialNetwork.facebookID isEqual:@"bob"], @"facebookID = %@ fails to equal %@", self.object.socialNetwork.facebookID, @"bob");
}

- (void)testNull {
    XCTAssertNil(self.object.null, @"null should be mapped to nil", nil);
    XCTAssertNil(self.object.nullDate, @"nullDate should be mapped to nil", nil);
    XCTAssertNil(self.object.nullArray, @"nullArray should be mapped to nil", nil);
    XCTAssertNil(self.object.nullSet, @"nullSet should be mapped to nil", nil);
    XCTAssertNil(self.object.nullChild, @"nullChild should be mapped to nil", nil);
    XCTAssertNil(self.object.nullNumber, @"nullNumber should be mapped to nil", nil);
}

- (void)testCreateDate {
    XCTAssertTrue([self.object.createDate isEqual:[NSDate dateWithTimeIntervalSince1970:46800]], @"date %@ != %@", self.object.createDate, [NSDate dateWithTimeIntervalSince1970:46800]);
}

// Test date with seconds since Epoch
- (void)testEpochDate {
    NSDate *date18 = [NSDate dateWithTimeIntervalSince1970:EIGHTEEN_YEARS_IN_SECONDS];
    XCTAssertTrue([self.object.eighteenthBirthday isEqual:date18], @"date %@ != %@", self.object.eighteenthBirthday, date18);
}

- (void)testData {
    // test lossless data -- will still contain the elipses (0x2026) character
    NSString *notLossy = [[NSString alloc] initWithData:self.object.data encoding:NSUTF8StringEncoding];
    XCTAssertTrue([DATA_STRING_UNICODE isEqualToString:notLossy], @"data string didn't convert");
    // test lossy conversion to ascii -- the elipses will convert to three periods
    NSString *lossy = [[NSString alloc] initWithData:self.object.dataLossy encoding:NSASCIIStringEncoding];
    XCTAssertTrue([DATA_STRING_ASCII isEqualToString:lossy], @"data string didn't convert");
}

- (void)testChilds {
    XCTAssertTrue([self.object.childs count] == 2, @"Should have two childs", nil);
    XCTAssertTrue([[self.object.childs objectAtIndex:0] isEqual:@"Mary"], @"%@ != Mary", [self.object.childs objectAtIndex:0]);
    XCTAssertTrue([[self.object.childs objectAtIndex:1] isEqual:@"James"], @"%@ != James", [self.object.childs objectAtIndex:1]);
}

- (void)testUsers {
    XCTAssertTrue([self.object.users count] == 2, @"Should have two users", nil);

    JTUserTest *userJohn = [self.object.users objectAtIndex:0];
    XCTAssertTrue([userJohn isKindOfClass:[JTUserTest class]], @"%@ != [JTUserTest class]", [userJohn class]);
    XCTAssertEqualObjects(userJohn.name, @"John");

    JTUserTest *userDoe = [self.object.users objectAtIndex:1];
    XCTAssertTrue([userDoe isKindOfClass:[JTUserTest class]], @"%@ != [JTUserTest class]", [userDoe class]);
    XCTAssertEqualObjects(userDoe.name, @"Doe");
}

- (void)testSet {
    NSSet *colors = self.object.favoriteColors;
    XCTAssertTrue([colors isKindOfClass:[NSSet class]], @"%@ != [NSSet class]", [colors class]);
    XCTAssertTrue([colors containsObject:@"green"], @"%@ should contain 'green'", colors);
    XCTAssertTrue([colors containsObject:@"blue"], @"%@ should contain 'blue'", colors);
}

- (void)testURL {
    NSURL *url = self.object.avatarURL;
    XCTAssertTrue([url isKindOfClass:[NSURL class]], @"%@ != [NSURL class]", [url class]);
    XCTAssertTrue([url.absoluteString isEqualToString:AVATAR_URL], @"%@ != %@", url.absoluteString, AVATAR_URL);
}

- (void)testKeyPath {
    XCTAssertEqualObjects(self.object.hashedString, @"string");
    
    JTUserTest *user = [[JTUserTest alloc] init];
    user.name        = @"John";

    XCTAssertEqualObjects(self.object.hashedUser.name, user.name);
}

- (void)testMissingJSON {
    XCTAssertNil(self.object.missingString, @"missingString should be nil");
    XCTAssertNil(self.object.missingDate, @"missingDate should be nil");
}

- (void)testAutoMapping {
    XCTAssertEqualObjects(self.object.autoString, @"yes");
}

- (void)testAutoArray {
    NSArray *array = [NSArray arrayWithObjects:
                      @"Object1",
                      @"Object2",
                      nil];
    XCTAssertEqualObjects(self.object.autoArray, array);
}

- (void)testAutoUnderscoreToCamelCase {
    XCTAssertEqualObjects(self.object.autoUnderscoreToCamelCase, @1);
}

//- (void)testAutoMapObject {
//    JTSocialNetworkTest *network = [[JTSocialNetworkTest alloc] init];
//    network.twitterID = @"@bob";
//    network.facebookID = @"bob";
//    XCTAssertEqualObjects(self.object.autoSocialNetwork, network, nil, nil);
//    [network release];
//}

- (void)testNestedArray {
    XCTAssertTrue([self.object.nestedArray count] == 2, @"Should have two apis", nil);
    
    JPNestedArrayTest *api = [self.object.nestedArray objectAtIndex:0];
    XCTAssertTrue([api isKindOfClass:[JPNestedArrayTest class]], @"%@ != [JPAPITests class]", [api class]);
    
    NSArray *expectedArray = [NSArray arrayWithObjects:@"one", @"two", nil];
    XCTAssertEqualObjects(api.array, expectedArray);

    JPNestedArrayTest *api2 = [self.object.nestedArray objectAtIndex:1];
    XCTAssertTrue([api2 isKindOfClass:[JPNestedArrayTest class]], @"%@ != [JPAPITests class]", [api2 class]);
    
    NSArray *expectedArray2 = [NSArray arrayWithObjects:@"three", @"four", nil];
    XCTAssertEqualObjects(api2.array, expectedArray2);
}

- (void)testPreserved {
    XCTAssertEqualObjects(self.object.desc, @"Description");
}

- (void)testReadonly {
    XCTAssertNil(self.object.readonly);
    XCTAssertNil(self.object.readonlyCopy);
    XCTAssertEqualObjects(self.object.privateCopy, @"PrivateCopy");
}

@end
