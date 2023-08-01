/**
    @file       adsync2.h
    @project    adsync2
    @author     Created by Moramcnt on 2019. 11. 11.
    @Copyright © 2019년 Moramcnt. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
 
typedef void (^PointSuccessBlock)(BOOL result, int point);
typedef void (^PointFailureBlock)(NSString *errorMessage);

@interface adsync2 : NSObject

/**
    @property custAge - 타겟팅을 할 경우에 사용됩니다. 타겟팅할 고객 나이, 기본값은 0
    @type - NSInteger
 */
@property (nonatomic, assign) NSInteger custAge;
/**
    @property custGender - 타겟팅을 할 경우에 사용됩니다. 타겟팅할 고객 성별, 기본값은 A
    @type - NSString
    @desc - 남자인 경우 M, 여자인 경우 F
 */
@property (nonatomic, strong) NSString *custGender;
/**
    @property title - 광고목록에서 isNewWindow가 YES인 경우에 상단에 표시하는 타이틀값, 기본값은 "포인트 충전"
    @type - NSString
 */
@property (nonatomic, strong) NSString *title;
/**
    @property titleTextColor - 광고목록에서 isNewWindow가 YES인 경우에 상단에 표시하는 타이틀의 텍스트 색상, 0xFFFFFF
    @type - UIColor
 */
@property (nonatomic, strong) UIColor *titleTextColor;
/**
    @property titleTextColor - 광고목록에서 isNewWindow가 YES인 경우에 상단에 표시하는 타이틀영역의 배경 색상, 0x747474
    @type - UIColor
 */
@property (nonatomic, strong) UIColor *titleBackgroundColor;
/**
    @property parent - 광고목록에서 isNewWindow가 YES인 경우에는 현재의 ViewController를 NO인 경우에는 현재 ViewController의 view를 지정
    @type - id
 */
@property (nonatomic, assign) id parent;
/**
    @property isDevelopeMode - 광고목록 가져오기에서 개발서버인지 상용서버인지를 구분
    @type - BOOL
 */
@property (nonatomic, assign) BOOL isDevelopeMode;

+ (id)sharedManager;

/**
    디바이스 아이디 값을 리턴합니다.
 */
+ (NSString *)getDeviceId;

/**
    AdSync2.0의 버전 정보를 리턴합니다.
 */
+ (NSString *)getSDKVersion;

/**
    AdSync2.0의 라이브러리 명 [AdSync2.0] 으로 리턴합니다.
 */
+ (NSString *)getSDKLibraryName;

/**
    안드로이드 또는 iOS여부를 리턴합니다. 항상 I를 리턴합니다. (iOS)
 */
+ (NSString *)getOSType;

/**
    OS 버전을 리턴합니다.
 */
+ (NSString *)getOSVersion;

/**
    광고목록 갱신하기
    AppDelegate applicationWillEnterForeground 에서 호출
 */
- (void)redraw;

/**
 광고목록 창 닫기
 광고목록 창을 특별히 응용프로그램에서 닫아야 하는 특별한 경우에만 호출
 새로운 창을 띄우는 경우(isNewWindow = YES)에만 적용
 */
- (void)closeOfferwall;

/**
    광고목록 가져오기
 
    @param frame - 광고목록 화면의 크기를 지정합니다.
    @param partnerId - 파트너아이디
    @param custId - 앱 내에서 관리하는 고객 아이디입니다.
    @param isNewWindow - 광고목록을 새로운 윈도우로 할 것인지 아니면 현재 View에 포함할 것인지를 지정합니다.
 */
- (void)openOfferwallWithframe:(CGRect)frame partner_id:(NSString *)partnerId cust_id:(NSString *)custId newWindow:(BOOL)isNewWindow;

/**
    포인트 조회 요청하기 - 현재는 지원되지 않음.
 
    @param partnerId - 파트너아이디
    @param uid - AdSync 회원 고유 넘버
    @param custId - 앱 내에서 관리하는 고객 아이디입니다.
    @param successBlock - 메쏘드가 성공했을 때 호출되는 값으로 리턴되는 형식은 다음과 같습니다.
            - BOOL result : 성공인 경우 YES
            - int point : custId의 point 값
    @param failureBlock - 메쏘드가 실패했을 때 호출되는 값으로 리턴되는 형식은 다음과 같습니다.
            - NSString *errorMessage
 */
- (void)requestPoint:(NSString *)partnerId uid:(int)uid cus_id:(NSString *)custId success:(PointSuccessBlock)successBlock failure:(PointFailureBlock)failureBlock;

/**
    포인트 요청하기 - 현재는 지원되지 않음.
 
    @param partnerId - 파트너아이디
    @param uid - adsync에서 제공한 uid 값
    @param custId - 앱 내에서 관리하는 고객 아이디입니다.
    @param desc - 인출내용입니다.
    @param successBlock - 메쏘드가 성공했을 때 호출되는 값으로 리턴되는 형식은 다음과 같습니다.
            - BOOL result : 성공인 경우 YES
            - int point : custId의 point 값
    @param failureBlock - 메쏘드가 실패했을 때 호출되는 값으로 리턴되는 형식은 다음과 같습니다.
            - NSString *errorMessage
 */
- (void)withDrawPoint:(NSString *)partnerId uid:(int)uid cus_id:(NSString *)custId description:(NSString *)desc success:(PointSuccessBlock)successBlock failure:(PointFailureBlock)failureBlock;

@end
