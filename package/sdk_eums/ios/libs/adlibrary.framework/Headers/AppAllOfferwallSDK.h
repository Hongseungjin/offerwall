//
//  AppAllOfferwallSDK.h
//  adlibrary
//
//  Created by MobileKing on 6/15/17.
//  Copyright © 2017 MobileKing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDToast.h"

#define SERVER_VERSION @"401"

#define AppAllOfferwallSDK_SUCCES           0
#define AppAllOfferwallSDK_INVALID_USER_ID  -1
#define AppAllOfferwallSDK_INVALID_KEY      -2
#define AppAllOfferwallSDK_NOT_GET_ADID     -3

/**
 * 서버 연결이 실패하였습니다.
 */
#define CODE_SERVER_CONNECTION_FAILED       -401
/**
 * 알수없는 오류입니다.
 */
#define CODE_UNKNOWN_ERROR                  -402

@protocol AppAllOfferwallSDKListener <NSObject>
- (void)AppAllOfferwallSDKCallback:(int)result;
@end

@interface AppAllOfferwallSDK : NSObject

@property(nonatomic, retain)NSString *userID;
@property(nonatomic, retain)NSString *apiKey;
@property(nonatomic, assign)int appInfo;
@property(nonatomic, retain)NSString *googleAdID;
@property(nonatomic, assign)BOOL isCheckInit;

@property(nonatomic, retain)id<AppAllOfferwallSDKListener>callbackListener;


+ (AppAllOfferwallSDK*)getInstance;
- (void)initOfferWall:(id)context offerkey:(NSString*)offerkey userid:(NSString*)userid;
- (BOOL)showAppAllOfferwallPop:(id)context;
- (void)showToast:(NSString*)msg;

#define TRACKING_APPALL
#ifdef TRACKING_APPALL
- (void)initOfferWall:(id)context offerkey:(NSString*)offerkey userid:(NSString*)userid appinfo:(int)appinfo;
- (BOOL)showAppAllOfferwallPush:(id)context tracking:(NSString*)track offerkey:(NSString*)offerkey userid:(NSString*)userid;
- (void)testAPI:(void (^)(int result, int version))callback;
#endif

@end



