//
//  NASWall.h
//  NASWall
//
//  Created by Young Chul Park on 2013. 10. 25..
//  Copyright (c) 2013년 NextApps, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define NAS_WALL_AD_TYPE_CPI        11

typedef enum {
    NAS_WALL_JOIN_STATUS_NO_JOIN = 0,
    NAS_WALL_JOIN_STATUS_JOIN,
    NAS_WALL_JOIN_STATUS_COMPLETE
} NAS_WALL_JOIN_STATUS;

typedef enum {
    NAS_WALL_SEX_UNKNOWN = 0,
    NAS_WALL_SEX_MALE,
    NAS_WALL_SEX_FEMALE
} NAS_WALL_SEX;
#pragma mark - NASWallAdInfo

@interface NASWallAdInfo : NSObject
@property (nonatomic, retain)   NSString                *adKey;         // 광고 KEY
@property (nonatomic, retain)   NSString                *packageName;   // 패키지명 (Bundle Identifier)
@property (nonatomic, retain)   NSString                *title;         // 광고명
@property (nonatomic, retain)   NSString                *introText;     // 소개글
@property (nonatomic, retain)   NSString                *missionText;   // 참여방법
@property (nonatomic, retain)   NSString                *iconUrl;       // 아이콘 URL
@property (nonatomic, retain)   NSString                *adPrice;       // 참여 비용
@property (nonatomic, assign)   int                     rewardPrice;    // 적립금
@property (nonatomic, assign)   int                     adType;         // 광고 유형
@property (nonatomic, retain)   NSString                *rewardUnit;    // 적립금 단위
@property (nonatomic, assign)   NAS_WALL_JOIN_STATUS    joinStatus;     // 참여 상태
@property (nonatomic, assign)   BOOL                    isOnline;       // 참여가능 여부
@property (nonatomic, retain)   NSString                *urlScheme;     // URL스키마
@property (nonatomic, assign)   BOOL                    isOverChargeLimitTime;  // 광고 참여 제한시간 초과

@property (nonatomic, assign)   int                     timeChargeTypeId;
@property (nonatomic, assign)   int                     timeChargeCount;
@property (nonatomic, assign)   int                     timeChargeMaxCount;
@end

@interface NASWallServiceAdInfo : NSObject
@property (nonatomic, retain)   NSString                *jurl;
@property (nonatomic, retain)   NSString                *curl;
@property (nonatomic, assign)   int                     adId;
@property (nonatomic, retain)   NSString                *adKey;
@property (nonatomic, assign)   int                     adTypeId;
@property (nonatomic, assign)   int                     adTypeChargeId;
@property (nonatomic, retain)   NSString                *image1;
@property (nonatomic, assign)   BOOL                    isOverChargeLimitTime;
@property (nonatomic, retain)   NSString                *marketKey;
@property (nonatomic, assign)   int                     marketId;
@property (nonatomic, retain)   NSString                *packageId;
@end

#pragma mark - NASWallDelegate

@protocol NASWallDelegate <NSObject>
@optional
- (void)NASWallClose;
- (void)NASWallGetUserPointSuccess:(int)point unit:(NSString*)unit;
- (void)NASWallGetUserPointError:(int)errorCode;
- (void)NASWallPurchaseItemSuccess:(NSString*)itemId count:(int)count point:(int)point unit:(NSString*)unit;
- (void)NASWallPurchaseItemNotEnoughPoint:(NSString*)itemId count:(int)count;
- (void)NASWallPurchaseItemError:(NSString*)itemId count:(int)count errorCode:(int)errorCode;
- (void)NASWallGetAdListSuccess:(NSArray*)adList;
- (void)NASWallGetAdListError:(int)errorCode;
- (void)NASWallGetAdListMoneySuccess:(int)money unit:(NSString*)unit;
- (void)NASWallGetAdListMoneyError:(int)errorCode;
- (void)NASWallGetAdDescriptionSuccess:(NASWallAdInfo*)adInfo description:(NSString*)description;
- (void)NASWallGetAdDescriptionError:(NASWallAdInfo*)adInfo errorCode:(int)errorCode;
- (void)NASWallJoinAdSuccess:(NASWallAdInfo*)adInfo url:(NSString*)url;
- (void)NASWallJoinAdError:(NASWallAdInfo*)adInfo errorCode:(int)errorCode;
- (void)NASWallOpenUrlSuccess:(NSString*)url;
- (void)NASWallOpenUrlError:(NSString*)url errorCode:(int)errorCode;
- (void)NASWallUserKeySuccess:(NSString*)userKey;
- (void)NASWallFullScreenAdLoadSuccess;
- (void)NASWallFullScreenAdClose;
- (void)NASWallMustRefreshAdList;
@end

#pragma mark - NASWall

@interface NASWall : NSObject

+ (void)showAlertController:(NSString *)title msg:(NSString *)msg cancleTitle:(NSString *)cTitle orderTitle:(NSString *)oTitle;
+ (void)initWithAppKey:(NSString*)appKey testMode:(BOOL)testMode delegate:(id <NASWallDelegate>)delegate;
+ (void)initWithAppKey:(NSString*)appKey testMode:(BOOL)testMode userId:(NSString*)userId delegate:(id <NASWallDelegate>)delegate;
+ (void)openWallWithUserData:(NSString*)userData;
+ (void)openWallWithUserData:(NSString*)userData age:(int)age sex:(NAS_WALL_SEX)sex;
+ (void)embedWallWithParent:(UIView*)parent userData:(NSString*)userData;
+ (void)embedWallWithParent:(UIView*)parent userData:(NSString*)userData age:(int)age sex:(NAS_WALL_SEX)sex;
+ (void)getUserPoint;
+ (void)purchaseItem:(NSString*)itemId;
+ (void)purchaseItem:(NSString*)itemId count:(int)count;
+ (void)getAdList:(NSString*)userData;
+ (void)getAdList:(NSString*)userData age:(int)age sex:(NAS_WALL_SEX)sex;
+ (void)getAdListMoney:(int)age sex:(NAS_WALL_SEX)sex;
+ (void)getAdDescription:(NASWallAdInfo*)adInfo;
+ (void)joinAd:(NASWallAdInfo*)adInfo;
//+ (void)loadFullScreenAdWithAge:(int)age sex:(NAS_WALL_SEX)sex;
//+ (BOOL)isLoadFullScreenAd;
//+ (void)showFullScreenAdWithRootViewController:(UIViewController*)rootViewController;
+ (void)openUrl:(NSString*)url;
+ (UIImage*)getCSImage;
+ (void)openCS;
+ (void)userKey;
+ (NSString*)appKey;

+ (void)applicationDidEnterBackground;
+ (void)applicationWillEnterForeground;

@end
