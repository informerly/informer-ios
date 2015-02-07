//
//  PPNetworkManager.m
//
//  Created by Muhammad Junaid Butt on 02/02/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

#import "NetworkManager.h"
#define BASE_URL @"http://informerly.com/api/v1/"

@implementation NetworkManager

+ (NetworkManager *)sharedNetworkClient {
    
    static NetworkManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[NetworkManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    });
    return _sharedClient;
    
}


- (id)initWithBaseURL:(NSURL *)url {
    
    if (self = [super initWithBaseURL:url]) {
        _requestOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
        _requestOperationManager.responseSerializer = [AFJSONResponseSerializer serializer];
        _requestOperationManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        _requestOperationManager.requestSerializer = [AFJSONRequestSerializer serializer];
        
    }
    return self;
}



- (void)processGetRequestWithPath:(NSString *)path parameter:(NSDictionary *)parameter
                          success: (NetworkClientSuccessBlock) successBlock
                          failure:(NetworkClientFailureBlock) failureBlock{
    
    AFHTTPClientSuccessBlock success = ^ (AFHTTPRequestOperation *operation, id responseObject) {
        if (successBlock) {
            successBlock((int)operation.response.statusCode, responseObject, operation.response.allHeaderFields);
        }
    };
    
    AFHTTPClientFailureBlock failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failureBlock){
            
            failureBlock((int)operation.response.statusCode, error, operation.responseString);
        }
    };
    
    path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *param = parameter==nil? [NSMutableDictionary dictionary] : [NSMutableDictionary dictionaryWithDictionary:parameter];
    
    [self.requestOperationManager GET:path parameters:param success:success failure:failure];
    
}


- (void)processPostRequestWithPath:(NSString *)path parameter:(id)parameter
                           success: (NetworkClientSuccessBlock) successBlock
                           failure:(NetworkClientFailureBlock) failureBlock {
    
    AFHTTPClientSuccessBlock success = ^ (AFHTTPRequestOperation *operation, id responseObject) {
        if (successBlock) {
            successBlock((int)operation.response.statusCode, responseObject, nil);
        }
    };
    
    AFHTTPClientFailureBlock failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failureBlock){
            failureBlock((int)operation.response.statusCode, error, operation.responseObject);
        }
    };
    
    
    path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *param = parameter==nil? [NSMutableDictionary dictionary] : [NSMutableDictionary dictionaryWithDictionary:parameter];
    
    [self.requestOperationManager POST:path parameters:param success:success failure:failure];
}

- (void)processDeleteRequestWithPath:(NSString *)path parameter:(id)parameter
                             success: (NetworkClientSuccessBlock) successBlock
                             failure:(NetworkClientFailureBlock) failureBlock {
    
    AFHTTPClientSuccessBlock success = ^ (AFHTTPRequestOperation *operation, id responseObject) {
        if (successBlock) {
            successBlock((int)operation.response.statusCode, responseObject, nil);
        }
    };
    
    AFHTTPClientFailureBlock failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failureBlock){
            failureBlock((int)operation.response.statusCode, error, operation.responseObject);
        }
    };
    
    
    path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *param = parameter==nil? [NSMutableDictionary dictionary] : [NSMutableDictionary dictionaryWithDictionary:parameter];
    
    [self.requestOperationManager DELETE:path parameters:param success:success failure:failure];
}


@end
