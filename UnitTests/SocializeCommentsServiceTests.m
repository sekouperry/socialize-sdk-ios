/*
 * SocializeCommentsServiceTests.m
 * SocializeSDK
 *
 * Created on 6/17/11.
 * 
 * Copyright (c) 2011 Socialize, Inc.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * See Also: http://gabriel.github.com/gh-unit/
 */

#import <OCMock/OCMock.h>
#import "SocializeCommentsServiceTests.h"
#import "SocializeComment.h"
#import "SocializeCommentJSONFormatter.h"
#import "SocializeObjectFactory.h"

#import <Foundation/Foundation.h>
#import <JSONKit/JSONKit.h>
#import "SocializeTestCase.h"
#import <OAuthConsumer/OAuthConsumer.h>


#define ENTITY @"entity_key"
static const int singleCommentId = 1;

@interface SocializeCommentsServiceTests() {
    BOOL _didCreateCalled;
}
    -(NSString *)helperGetJSONStringFromFile:(NSString *)fileName;
@end

@implementation SocializeCommentsServiceTests

-(void) setUpClass
{  
    NSLog(@"Setting up %@", [self class]);

    SocializeObjectFactory* factory = [[SocializeObjectFactory new] autorelease] ;
    _service = [[SocializeCommentsService alloc] initWithObjectFactory:factory delegate:self];
    _mockService = [[_service nonRetainingMock] retain];
    _testError = [NSError errorWithDomain:@"" code: 402 userInfo:nil];
}

-(void) tearDownClass
{
    NSLog(@"Tearing down %@", [self class]);
    [_mockService release]; _mockService = nil;
    [_service release]; _service = nil;
}

- (void)setUp {
    _didCreateCalled = NO;
    
    [super setUp];
}

- (void)tearDown {
    [_mockService verify];
    
    [super tearDown];
}

#pragma mark - Requests test

-(void) testSendGetCommentById
{    
    [[_mockService expect] executeRequest:
     [SocializeRequest requestWithHttpMethod:@"GET"
                                resourcePath:@"comment/"
                          expectedJSONFormat:SocializeDictionaryWithListAndErrors
                                      params:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObject: [NSNumber numberWithInt:singleCommentId]], @"id", nil]
      ]];
    
    [_mockService getCommentById: singleCommentId];
    
    [_mockService verify];
}

-(void) testGetListOfCommentsById
{    
    NSArray* ids = [NSArray arrayWithObjects: [NSNumber numberWithInt:1], [NSNumber numberWithInt:2], nil];
    NSArray* keys = [NSArray arrayWithObjects: @"url_for_test", @"enother_url", nil];
    
    [[_mockService expect] executeRequest:
     [SocializeRequest requestWithHttpMethod:@"GET"
                                resourcePath:@"comment/"
                          expectedJSONFormat:SocializeDictionaryWithListAndErrors
                                      params:[NSMutableDictionary dictionaryWithObjectsAndKeys:ids, @"id", keys, @"key", nil]
      ]];
 
    [_mockService getCommentsList: ids andKeys:keys];
    
    [_mockService verify];
}

-(void) testGetListOfCommentsWithEmptyParams
{
    GHAssertThrows([_service getCommentsList:nil andKeys:nil], nil);
}

-(void) testGetListOfCommentsByEntityKey
{
    [[_mockService expect] executeRequest:
     [SocializeRequest requestWithHttpMethod:@"GET"
                                resourcePath:@"comment/"
                          expectedJSONFormat:SocializeDictionaryWithListAndErrors
                                      params:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"http://www.example.com/interesting-story/", @"entity_key", nil]
      ]];
    

    NSString* entryKey = @"http://www.example.com/interesting-story/";
    [_mockService getCommentList:entryKey first:nil last:nil];
    
    [_mockService verify];
}

-(void) testGetCommentListWithPageInfo
{   
    NSNumber* first = [NSNumber numberWithInt:2]; 
    NSNumber* last = [NSNumber numberWithInt:800]; 
    
    [[_mockService expect] executeRequest:
     [SocializeRequest requestWithHttpMethod:@"GET"
                                resourcePath:@"comment/"
                          expectedJSONFormat:SocializeDictionaryWithListAndErrors
                                      params:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"http://www.example.com/interesting-story/", @"entity_key", first, @"first", last, @"last", nil]
      ]];
    
    

    NSString* entryKey = @"http://www.example.com/interesting-story/";
    [_mockService getCommentList:entryKey first:first last:last];
    
    [_mockService verify];
}

+ (NSString*)testEntityKey {
    return @"http://www.example.com/interesting-story/";
}

+ (NSString*)testEntityName {
    return @"Something";
}

+ (SZEntity*)testEntity {
    return [SZEntity entityWithKey:[self testEntityKey] name:[self testEntityName]];
}

+ (SZComment*)testComment {
    SZComment *comment = [SZComment commentWithEntity:[[self class] testEntity] text:@"Nothing"];
    comment.lat = @20;
    comment.lng = @50;
    
    return comment;
}

+ (NSDictionary*)fakeCreateCommentResponse {
    
    SZComment *testComment = [self testComment];
    
    return
             @{@"errors": @[],
                 @"items": @[@{@"application":
                                   @{@"id": @267189,
                                       @"name": @"MoviePal"
                                     },
                               @"date": @"2013-03-05 19:18:09+0000",
                               @"entity": @{
                                       @"comments": @891,
                                       @"id": @7573051,
                                       @"key": [self testEntityKey],
                                       @"name": [self testEntityName],
                                       @"likes": @414,
                                       @"meta": @"null",
                                       @"shares": @304,
                                       @"total_activity": @2821,
                                       @"type": @"article",
                                       @"views": @1212
                                       },
                 @"id": @4158835,
                               @"lat": testComment.lat,
                               @"lng": testComment.lng,
                               @"propagation_info_response": @{},
                               @"share_location": @YES,
                               @"text": testComment.text,
                               @"user": @{
                                       @"first_name": @"null", @"id": @122634992, @"last_name": @"null", @"location": @"null", @"meta": @"null",
                                       @"small_image_uri": @"null", @"username": @"User122634992"}
                               }]};
}


- (void)expectCreateCommentsNotification {
    OCMockObserver *observer = [OCMockObject observerMock];
    [[observer expect] notificationWithName:SZDidCreateObjectsNotification object:nil userInfo:OCMOCK_ANY];
    [[NSNotificationCenter defaultCenter] addMockObserver:observer
                                                     name:SZDidCreateObjectsNotification
                                                   object:nil];
    [self atTearDown:^{
        [observer verify];
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }];
}

- (void)respondToNextRequestWithData:(NSData*)data {
    [[[_mockService expect] andDo1:^(SocializeRequest *request) {
        [_service request:request didLoadRawResponse:data];
    }] executeRequest:OCMOCK_ANY];
}

- (void)testCreateCommentWithBlock {
    [self respondToNextRequestWithData:[[[self class] fakeCreateCommentResponse] JSONData]];
    
    [self expectCreateCommentsNotification];

    [self prepare];
    [_service createComment:[[self class] testComment] success:^(id<SocializeComment> comment) {
        [self notify:kGHUnitWaitStatusSuccess];
    } failure:^(NSError *error) {
        [self notify:kGHUnitWaitStatusFailure];
    }];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:0.5];
    
    GHAssertTrue(_didCreateCalled, @"Should have called didCreate");
}

- (void)testCreateComment {
    [self respondToNextRequestWithData:[[[self class] fakeCreateCommentResponse] JSONData]];
    
    [self expectCreateCommentsNotification];
    
    [_service createCommentForEntity:[[self class] testEntity] comment:@"this was a great story" longitude:nil latitude:nil];
//    [_mockService verify];
    
    GHAssertTrue(_didCreateCalled, @"Should have called didCreate");


}
//-(void) testCreateCommentForNew
//{
//    SocializeEntity *entity = [[SocializeEntity new] autorelease];
//    id expectedComment = [SZComment commentWithEntity:entity text:@"hi"];
//    
//    entity.key = @"http://www.example.com/interesting-story/";
//    entity.name = @"example";
//    
//    OCMockObserver *observer = [OCMockObject observerMock];
//    [[observer expect] notificationWithName:SZDidCreateObjectsNotification object:nil userInfo:@{kSZCreatedObjectsKey: @[ expectedComment ]} ];
//    [[NSNotificationCenter defaultCenter] addMockObserver:observer
//                                                     name:SZDidCreateObjectsNotification
//                                                   object:nil];
//    [self atTearDown:^{
//        [[NSNotificationCenter defaultCenter] removeObserver:observer];
//    }];
//    
//
//    [[[_mockService expect] andDo1:^(SocializeRequest *request) {
//        BLOCK_CALL_1(request.successBlock, @[ expectedComment ]);
//    }] executeRequest:OCMOCK_ANY];
//    
//    [_service createCommentForEntity:entity comment:@"this was a great story" longitude:nil latitude:nil];
//    
//    [_mockService verify];
//    [observer verify];
//    
//}

-(void) testCreateCommentForNewWithGeo
{   
    SocializeEntity *entity = [[SocializeEntity new] autorelease];  
    entity.key = @"http://www.example.com/interesting-story/";
    entity.name = @"example";
    
    NSArray* mockArray = [NSArray arrayWithObject:
                          [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           [NSDictionary dictionaryWithObjectsAndKeys:entity.key, @"key", entity.name, @"name", nil],@"entity",
                           @"this was a great story", @"text",
                           [NSNumber numberWithFloat:1.2], @"lng",
                           [NSNumber numberWithFloat:1.1], @"lat",
                           [NSNumber numberWithBool:NO], @"subscribe",
                           nil]];
    
    [[_mockService expect] executeRequest:
     [SocializeRequest requestWithHttpMethod:@"POST"
                                resourcePath:@"comment/"
                          expectedJSONFormat:SocializeDictionaryWithListAndErrors
                                      params:mockArray
      ]];

    [_service createCommentForEntity:entity comment:@"this was a great story" longitude:[NSNumber numberWithFloat:1.2] latitude:[NSNumber numberWithFloat:1.1]];
    
    [_mockService verify];
}

-(void) testCreateCommentWithGeo
{
    NSArray* mockArray = [NSArray arrayWithObjects:
                            [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             @"http://www.example.com/interesting-story/",ENTITY,
                             @"this was a great story", @"text",
                             [NSNumber numberWithFloat:1.2], @"lng",
                             [NSNumber numberWithFloat:1.1], @"lat",                             
                             [NSNumber numberWithBool:NO], @"subscribe",

                             nil],
                          nil];
    
    [[_mockService expect] executeRequest:
     [SocializeRequest requestWithHttpMethod:@"POST"
                                resourcePath:@"comment/"
                          expectedJSONFormat:SocializeDictionaryWithListAndErrors
                                      params:mockArray
      ]];

    [_service createCommentForEntityWithKey: @"http://www.example.com/interesting-story/"
                                    comment: @"this was a great story" 
                                  longitude: [NSNumber numberWithFloat:1.2] 
                                   latitude: [NSNumber numberWithFloat:1.1]];
    
    [_mockService verify];
}

#pragma mark response tests
-(void) testServiceFailed
{
    [_service request:nil didFailWithError:_testError];
}

-(void) testServiceReceiveSingleComment
{
    NSString* jsonResponse = [self helperGetJSONStringFromFile:@"responses/comment_single_response.json"];
    NSData* jsonData = [jsonResponse dataUsingEncoding:NSUTF8StringEncoding];
    [_service request:nil didLoadRawResponse:jsonData];
}

-(void) testServiceReceiveCommentsList
{
    NSString* jsonResponse = [self helperGetJSONStringFromFile:@"responses/comment_list_response.json"];
    NSData* jsonData = [jsonResponse dataUsingEncoding:NSUTF8StringEncoding];
    [_service request:nil didLoadRawResponse:jsonData];
}

- (void)testCreateComments {
    SocializeEntity *entity1 = [SocializeEntity entityWithKey:@"key1" name:@"name1"];
    SocializeEntity *entity2 = [SocializeEntity entityWithKey:@"key2" name:@"name2"];
    
    SocializeComment *comment1 = [SocializeComment commentWithEntity:entity1 text:@"first comment"];
    SocializeComment *comment2 = [SocializeComment commentWithEntity:entity2 text:@"second comment"];
     
    [[[_mockService expect] andDo1:^(SocializeRequest *request) {
        NSArray *params = [request params];
        GHAssertTrue([params count] == 2, @"Bad count");
    }] executeRequest:OCMOCK_ANY];

    [_service createComments:[NSArray arrayWithObjects:comment1, comment2, nil]];
}

#pragma mark helper methods


-(NSString *)helperGetJSONStringFromFile:(NSString *)fileName
{
    NSString * JSONFilePath = [[NSBundle mainBundle]pathForResource:[NSString stringWithFormat:@"%@/%@",@"JSON-RequestAndResponse-TestFiles", fileName ] ofType:nil];
    
    
    NSString * JSONString = [NSString stringWithContentsOfFile:JSONFilePath 
                                                      encoding:NSUTF8StringEncoding 
                                                         error:nil];
    
    return  JSONString;
}
-(void)service:(SocializeService*)service didCreate:(id<SocializeObject>)object{
    _didCreateCalled = YES;
    NSLog(@"didCreate %@", object);
}

-(void)service:(SocializeService*)service didDelete:(id<SocializeObject>)object{
    NSLog(@"didDelete %@", object);
}

-(void)service:(SocializeService*)service didUpdate:(id<SocializeObject>)object{
    NSLog(@"didUpdate %@", object);
}

-(void)service:(SocializeService*)service didFetch:(id<SocializeObject>)object{
    NSLog(@"didFetch %@", object);
}

-(void)service:(SocializeService*)service didFail:(NSError*)error{
    NSLog(@"didFail %@", error);
}

-(void)service:(SocializeService*)service didFetchElements:(NSArray*)dataArray{
    NSLog(@"didFetchElements %@", dataArray);
}

@end
