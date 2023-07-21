//
//  TnkRwdSdk.h
//  TnkRwdSdk
//
//  Created by  김동혁 on 2022/04/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//! Project version number for TnkRwdSdk.
FOUNDATION_EXPORT double TnkRwdSdkVersionNumber;

//! Project version string for TnkRwdSdk.
FOUNDATION_EXPORT const unsigned char TnkRwdSdkVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <TnkRwdSdk/PublicHeader.h>

// 게시앱 상태값 정의
#define TNK_STATE_NO        0
#define TNK_STATE_YES       1
#define TNK_STATE_TEST      2
#define TNK_STATE_CHECK     3
#define TNK_STATE_PASSED    4
#define TNK_STATE_STOP      8
#define TNK_STATE_ERROR     9
#define TNK_STATE_UNKNOWN   99

#define TNK_CODE_MALE       @"M"
#define TNK_CODE_FEMALE     @"F"

// Interstitial TnkAdViewDelegate 관련 상수값 정의
#define AD_CLOSE_SIMPLE     0   // 사용자가 닫기버튼을 눌러서 광고화면을 닫은 경우
#define AD_CLOSE_CLICK      1   // 사용자가 광고를 클릭해서 화면이 닫히는 경우
#define AD_CLOSE_EXIT       2   // 사용자가 종료버튼을 클릭해서 화면을 닫은 경우

#define AD_FAIL_NO_AD       -1  // no ad available
#define AD_FAIL_NO_IMAGE    -2  // ad image not available
#define AD_FAIL_TIMEOUT     -3  // ad arrived after 5 secs.
#define AD_FAIL_CANCEL      -4  // ad frequency settings
#define AD_FAIL_NOT_PREPARED     -5      // not prepared (2015.05.12)

#define AD_FAIL_SYSTEM      -9

#define TNK_PPI             @"__tnk_ppi__"
#define TNK_CPC             @"__tnk_cpc__"

// for Native Ad
#define AD_STYLE_TEXT_ONLY      0
#define AD_STYLE_PORTRAIT       1
#define AD_STYLE_LANDSCAPE      2
#define AD_STYLE_SQUARE         3
#define AD_STYLE_ICON           4
// 2018.05.15  배너 타입 추가
#define AD_STYLE_BANNER_LANDSCAPE       26
#define AD_STYLE_BANNER_LANDSCAPE_200   90

// v4.28, 오퍼월에 띄울 상품종류를 선택하기 위한 상수값
// setAdListAdType:  API 참고
#define ADLIST_ALL      -1
#define ADLIST_PPI      1
#define ADLIST_CPS      4

// 오퍼월 정렬 순서 (2022.09.26)
#define ADLIST_SORT_DEFAULT 0
#define ADLIST_SORT_POINT_DESC  1  // 리워드 많은 순서
#define ADLIST_SORT_POINT_ASC   2  // 리워드 적은 순서

@protocol TnkAdViewDelegate <NSObject>
@optional

// Called when AdListView is closed
- (void)adListViewClosed;

// 전면광고 화면 닫힐 때 호출됩니다. 화면이 닫히는 이유를 파라메터로 전달해 줍니다.
- (void)adViewDidClose:(int)type;

// 전면 광고를 화면에 띄우지 못했을 경우 호출됩니다.
// 시스템 오류나 광고가 없어서 광고를 띄우지 못했을 경우,
// 광고가 늦게 도착(5초 이상) 하여 광고가 뜨지 않은 경우,
// 광고 노출 주기에 따라서 노출이 취소된 경우에 호출됩니다.
- (void)adViewDidFail:(int)errCode;

// 전면광고 화면이 나타나는 시점에 호출됩니다.
- (void)adViewDidShow;

// 전면 광고 prepare: API 호출 후 show: API 호출 전에 광고가 도착하면 호출됩니다.
// 만약 광고 도착 전에 show: API 가 호출된 경우에는 이후 광고가 도착하였을 때
// 바로 광고가 표시되고 adViewDidShow:가 호출됩니다.
- (void)adViewDidLoad;
@end

@protocol IconLoaderCell <NSObject>

- (void) setImageIcon:(UIImage *)image;
- (void) setImageFeed:(UIImage *)image; // 2022.09.22 광고목록에 feed 형태 구현을 위하여 추가함.
- (void) setKey:(id)key;
- (id) getKey;

@end

// adlistitem 용 abstract class
@interface AdListItemView : UIControl <IconLoaderCell>

+ (float) calculateHeight:(float)width;
- (void) setData:(NSDictionary *)dic;
- (void) setImageIcon:(UIImage *)image; // from IconLoaderCell
- (void) setImageFeed:(UIImage *)image; // from IconLoaderCell

// 2022.09.22 광고목록에 아이콘 이미지와 Feed 이미지 사용여부를 반환한다. (번개장터 커스터마이징 요청으로 기능 추가됨)
- (BOOL) useImageIcon; // 기본값 YES
- (BOOL) useImageFeed; // 기본값 NO
- (void) handleItemClick;

@end

// 상세화면을 구성하는 섹션들의 공통 상위 클래스
@interface AdDetailSectionView : UIView

- (void) setData:(NSDictionary *)dic;
- (void) setImageIcon:(UIImage *)image;

- (UIButton *) getActionButton;

- (NSString *) getStepDescription:(NSDictionary *)dic;

@end

// 2022.09.30 광고 상세화면 하단의 유의사항 UI 를 커스터마이징할 때 이것을 상속받는다.
@interface AdDetailNoticeView : AdDetailSectionView

@end

// 광고리스트 아이템 커스터마이징할 때 상속받아서 구현한다.
@interface AdListItemViewFactory : NSObject

- (AdListItemView *) getListItemView:(CGRect)frame;
- (float) getListItemViewHeight:(float)width;

- (AdDetailSectionView *) getDetailHeaderView:(CGRect)frame;
- (float) getDetailHeaderViewHeight:(float)width;

- (AdDetailSectionView *) getDetailActionView:(CGRect)frame;
- (float) getDetailActionViewHeight:(float)width;

// 2021.03.03 추가 (v4.28)
- (AdDetailSectionView *) getDetailInfoView:(CGRect)frame;
- (float) getDetailInfoViewHeight:(float)width;
@end

// ServiceCallback
@protocol TnkServiceCallback <NSObject>

@required
- (void)onServiceReturn:(id)sender;

@optional
- (void)onServiceError:(id)sender;

@end

// Native Ad (2015.05.14)

@class TnkNativeAd;

@protocol TnkNativeAdDelegate <NSObject>

@optional

- (void) didNativeAdFail:(TnkNativeAd *)ad error:(int)errCode;
- (void) didNativeAdLoad:(TnkNativeAd *)ad;
- (void) didNativeAdClick:(TnkNativeAd *)ad;
- (void) didNativeAdShow:(TnkNativeAd *)ad;

@end

@interface TnkNativeAd : NSObject <TnkServiceCallback>

@property (nonatomic, weak) id<TnkNativeAdDelegate> delegate;
@property (nonatomic, strong) NSString *logicName;
@property (nonatomic, assign) NSInteger adStyle;

- (void) prepare:(NSString *)logicName;
- (void) prepare:(NSString *)logicName delegate:(id<TnkNativeAdDelegate>)delegate;
- (void) prepare;

// Common data for PPI, CPC
- (UIImage *) getCoverImage;
- (NSString *) getCoverImageUrl;
- (UIImage *) getIconImage;
- (NSString *) getIconImageUrl;
- (NSString *) getTitle;
- (NSString *) getDescription;

// for PPI only
- (NSString *) getPointName;
- (NSNumber *) getRewardPoint;
- (NSInteger) getRewardType;
- (NSString *) getActionText;

// attach, detach
- (void) attachLayout:(UIView *)view;
- (void) attachLayout:(UIView *)view clickView:(UIView *)clickView;
- (UIView *) getAttachedLayout;

- (void) detachLayout;

- (void) handleClick;
@end

@protocol TnkNativeAdManagerDelegate <NSObject>

@optional

- (void) didNativeAdManagerFail:(int)errCode;
- (void) didNativeAdManagerLoad;

@end

@interface TnkNativeAdManager : NSObject <TnkServiceCallback>

@property (nonatomic, weak) id<TnkNativeAdDelegate> delegate;
@property (nonatomic, weak) id<TnkNativeAdManagerDelegate> managerDelegate;

- (id) initWith:(NSString *)logicName adStyle:(NSInteger)adStyle adCount:(NSInteger)adCount;

- (TnkNativeAd *) nextAdItem;
- (TnkNativeAd *) getAdItemAt:(NSInteger)index;
- (NSUInteger) getUniqueAdCount;

- (void) prepareAds;

@end

// New API for Interstitial Ad (2015.05.14)

@class TnkInterstitialAd;

@protocol TnkInterstitialDelegate <NSObject>

@optional

- (void)didInterstitialClose:(TnkInterstitialAd *)ad close:(int)type;
- (void)didInterstitialFail:(TnkInterstitialAd *)ad error:(int)errCode;
- (void)didInterstitialShow:(TnkInterstitialAd *)ad;
- (void)didInterstitialLoad:(TnkInterstitialAd *)ad;

@end

@interface TnkInterstitialAd : NSObject <TnkServiceCallback>

@property (nonatomic, weak) UIViewController *viewControllerToShow;
@property (nonatomic, weak) id<TnkInterstitialDelegate> delegate;
@property (nonatomic, strong) NSString *logicName;
@property (nonatomic, assign) NSTimeInterval timeoutSec;

- (void) prepare;
- (void) prepare:(NSString *)logicName;
- (void) prepare:(NSString *)logicName delegate:(id<TnkInterstitialDelegate>) delegate;

- (void) show:(UIViewController *)viewController;
- (void) show;

@end

// New API for Video Ad (2015.09.30)

@protocol TnkVideoDelegate <NSObject>
@optional

- (void)didVideoClose:(NSString *)logicName close:(int)type;
- (void)didVideoShow:(NSString *)logicName;
- (void)didVideoLoad:(NSString *)logicName;
- (void)didVideoCompleted:(NSString *)logicName skip:(BOOL)skipped;
- (void)didVideoFail:(NSString *)logicName error:(int)errCode;  // 2016.07.04

@end

// AdListView (2018.01.25)
// UIAlertViewDelegate protocol 삭제 (v4.28)
@interface TnkAdListView : UITableView <UITableViewDelegate, UITableViewDataSource,
        TnkServiceCallback, UIGestureRecognizerDelegate, TnkAdViewDelegate>

- (id) initWithFrame:(CGRect)frame viewController:(UIViewController *)vc;
- (void) loadAdList;
- (void) updateAdList;
- (NSTimeInterval) getLastLoadingSeconds;

- (void) setAdListFilterType:(int)adType; // 전체, 참여형, 구매형 선택하여 보여주기
- (void) setAdListSortType:(int)sortType; // 기분순 리워드 많은 순, 리워드 적은 순

@end

// 2022.09.26
@interface TnkUtils : NSObject

+ (void) goHelpDeskLink;

@end

@interface TnkSession : NSObject {
    
    // 아래의 속성들은 광고 목록 스타일 지정을 위하여 사용됨
    /*
     * 적용 예시
     // set styles
     [[TnkSession sharedInstance] setHeaderColor:TITLE_BAR_COLOR];
     [[TnkSession sharedInstance] setHeaderTitle:LocalString(@"adlist")];
     [[TnkSession sharedInstance] setDetailBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_detail.png"]]];
     [[TnkSession sharedInstance] setListItemBackgroundColorNormal:[UIColor colorWithPatternImage:[UIImage imageNamed:@"adlist_bg_normal.png"]]];
     [[TnkSession sharedInstance] setListItemBackgroundColorStripe:[UIColor colorWithPatternImage:[UIImage imageNamed:@"adlist_bg_stripe.png"]]];
     [[TnkSession sharedInstance] setListItemBackgroundColorHighlight:[UIColor colorWithPatternImage:[UIImage imageNamed:@"adlist_bg_highlight.png"]]];
     [[TnkSession sharedInstance] setDetailHeaderBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"detail_header_bg.png"]]];
     
     [[TnkSession sharedInstance] setWebBoxButtonImage:[UIImage imageNamed:@"az_list_bt_web.png"]];
     [[TnkSession sharedInstance] setFreeBoxButtonImage:[UIImage imageNamed:@"az_list_bt_free.png"]];
     [[TnkSession sharedInstance] setPaidBoxButtonImage:[UIImage imageNamed:@"az_list_bt_pay.png"]];
     [[TnkSession sharedInstance] setConfirmBoxButtonImage:[UIImage imageNamed:@"az_list_bt_install.png"]];
     
     [[TnkSession sharedInstance] setCoinImage:[UIImage imageNamed:@"az_list_icon_coin.png"]];
     [[TnkSession sharedInstance] setBadgeNewImage:[UIImage imageNamed:@"icon_new_triangle.png"]];
     [[TnkSession sharedInstance] setBadgeBestImage:[UIImage imageNamed:@"event_bt_best.png"]];
     
     UIImage *detailButtonNormal = [UIImage imageNamed:@"detail_bt_bg.png"];
     UIImage *stretchableDetailButtonNormal = [detailButtonNormal stretchableImageWithLeftCapWidth:10 topCapHeight:0];
     [[TnkSession sharedInstance] setDetailButtonImageNormal:stretchableDetailButtonNormal];
     */
}

/*
 * 초기화. AppDelegate에서 앱 기동시 Tnk가 부여한 app Id를 사용하여 초기화한다.
 */
+ (id) initInstance:(NSString *)appId;

/*
 * Tnk에 접근하기 위한 단일 객체를 반환한다.
 */
+ (TnkSession *) sharedInstance;

/*
 * Tnk가 사용하는 단말기 고유 ID를 반환한다.
 */
- (NSString *) getUid;

/*
 * 하나의 매체앱에서 여러개의 Tnk AppId 를 사용할 수 있도록 기능을 추가함.
 */
- (void) setApplicationId:(NSString *)appId;

/*
 * 매체에서 사용하는 고유 사용자 ID를 지정할 수 있다.
 * 지정된 값은 매체서버에 포인트 전달할 때 같이 전달된다.
 */
- (void) setUserName:(NSString *)name;

/**
 * COPPA, GDPR
 */
- (void) setCOPPA:(BOOL)coppa;
- (void) setGdprConsent:(BOOL)gdpr;

/*
 * 광고목록 ViewController를 생성해준다.
 */
- (UIViewController *) adListViewController;

// 2022.09.27
// 오퍼리스트에서 광고 유형, 정렬 방식 지정을 위한 설정 기능
- (void) setAdListSortType:(int)sortType;
- (int) getAdListSortType;

- (void) setAdListFilterType:(int)filterType;
- (int) getAdListFilterType;

/*
 * 광고 목록을 띄운다. 모달 형태로 띄운다.
 */
- (void) showAdListAsModal:(UIViewController *)viewController title:(NSString *)title;
- (void) showAdListAsModal:(UIViewController *)viewController title:(NSString *)title delegate:(id<TnkAdViewDelegate>)delegate;

/*
 * 광고 목록을 띄운다. NavigationController 기반으로 하위 레벨로 이동하는 방식이다.
 */
- (void) showAdListNavigation:(UIViewController *)viewController title:(NSString *)title;
- (void) showAdListNavigation:(UIViewController *)viewController title:(NSString *)title delegate:(id<TnkAdViewDelegate>)delegate;

/*
 * 현재 포인트 조회 (비동기 방식) : 결곽를 받을 객체와 메소드를 지정해준다.
 * action에 전달되는 인자 값은 현재 포인트 값으로 NSNumber 객체이다. (오류 발생시 -1 전달됨)
 */
- (void) queryPoint:(id)target action:(SEL)action;

// 현재 포인트 조회 (동기방식) : 조회된 포인트 결과를 반환한다.
- (NSInteger) queryPoint;

/*
 * 현재 개시앱의 상태 값을 조회한다. (비동기 방식) : 결과를 받을 객체와 매소드를 지정해준다.
 * action에 전달되는 인자값은 게시앱의 상태값으로 NSNumber 객체이다. (오류 발생시 TNK_STATE_ERROR 전달됨)
 */
- (void) queryPublishState:(id)target action:(SEL)action;

// 현재 게시앱의 상태 값을 조회한다.
- (NSInteger) queryPublishState;

/*
 * 아이템 구매를 수행한다. (비동기 방식)
 * 구매하는 itemId 와 사용포인트를 전달하면 서버에서 해당 포인트만큼 차감한 후 로그를 남기고 결과를 반환한다.
 * action에 전달되는 인자값은 2개이며 첫번째 인자는 남은포인트, 두번째 인자는 고유한 거래 ID 값으로 모누 NSNumber 객체이다.
 * 네트워크 오류 또는 포인트 부족 등으로 아이템 구매가 성공하지 못한 경우 두번째 인자값은 음수를 갖는다.
 */
- (void) purchaseItem:(NSString *)itemId cost:(NSInteger)pointCost target:(id)target action:(SEL)action;

/*
 * 적립되어 있는 전체 포인트를 인출한다. (비동기 방식)
 * action에 전달하는 인자값은 인출한 포인트 값으로 NSNumber 객체이다. (오류 발생시 -1 전달됨)
 */
- (void) withdrawPoints:(NSString *)desc target:(id)target action:(SEL)action;

/*
 * 적립되어 있는 전체 포인트를 인출한다. (동기방식)
 * 인출된 포인트 값을 반환한다.
 */
- (NSInteger) withdrawPoints:(NSString *)desc;

/*
 * 사용자에게 제공될 수 있는 광고 개수와 포인트 합계를 반환한다. (비동기 방식)
 * action에 전달되는 인자값은 2개이며 첫번째 인자는 광고 개수, 두번째 인자는 제공되는 광고들의 포인트 합께 값으로 모누 NSNumber 객체이다.
 * 오류 발생시 광고개수는 -1, 포인트 합계는 0 이 리턴됨
 */
- (void) queryAdvertiseCount:(id)target action:(SEL)action;

/*
 * 실행형 지급 광고앱의 경우 앱이 정상적으로 실행되었다고 판단되는 시점에 호출한다.
 */
- (void) applicationStarted;

/*
 * 액션형 지급 광고앱의 경우 설정한 액션이 수행되었다고 판단되는 시점에 호출한다.
 */
- (void) actionCompleted;
- (void) actionCompleted:(NSString *)actionName;

/*
 * 사용자가 유료구매를 완료하는 시점에 호출한다.(구매활동 분석)
 */
- (void) buyCompleted:(NSString *)itemName;

/*
 * App Tracking 기능 사용 여부 설정 (default : YES)
 */
- (void) setTrackingEnabled:(BOOL)enabled;

/*
 * 사용자 정보 설정
 */
- (void) setUserAge:(int)age;
- (void) setUserGender:(NSString *)gender;

/*
 * 중간 전면 광고
 */
- (void) prepareInterstitialAd:(NSString *)logicName delegate:(id<TnkAdViewDelegate>)delegate;
- (void) showInterstitialAd;
- (void) showInterstitialAd:(id<TnkAdViewDelegate>)delegate;
- (void) showInterstitialAd:(id<TnkAdViewDelegate>)delegate on:(UIViewController *)viewController;
- (BOOL) isInterstitialAdVisible;
- (BOOL) isInterstitialAdVisible:(UIViewController *)viewController;
- (void) removeCurrentInterstitialAd;
- (void) removeCurrentInterstitialAd:(UIViewController *)viewController;

/*
 * 동영상 광고
 */
/*
 * 동영상 광고
 */
- (void) prepareVideoAd:(NSString *)logicName delegate:(id<TnkVideoDelegate>)delegate repeat:(BOOL)repeatFlag;
- (void) prepareVideoAd:(NSString *)logicName delegate:(id<TnkVideoDelegate>)delegate;
- (BOOL) showVideoAd:(NSString *)logicName on:(UIViewController *)viewController;
- (BOOL) showVideoAd;
- (BOOL) hasVideoAd:(NSString *)logicName;
- (BOOL) hasVideoAd;
- (BOOL) isVideoPresenting;

// helpdesk url 가져오기
- (NSString *) getHelpdeskUrl;

// 오퍼월 광고 요청시 설정 (v4.28)
// 오퍼월 광고에 구매형 상품 기능이 추가되면서 오퍼월에 어떤 광고를 보여줄지 선택할 수 있는 기능이 추가되었다.
// 전체상품(참여형 + 구매형), 기본설정임 : ADLIST_ALL
// 참여형상품만(앱광고, SNS 광고 등) : ADLIST_PPI
// 구매형상품만(쇼핑광고) : ADLIST_CPS
- (void) setAdListAdType:(int)type;

// 2020.10.8
// 추적동의 창 띄우기. iOS14는 ATT 팝업창을 띄우고 iOS13 미만인 경우에는 자체 Alert 창을 띄운다.
// 추적동의 창은 오퍼월 최초 실행시 SDK가 띄워준다. 만약 그전에 별도로 앱추적동의를 띄우고자 할 경우에는 아래의 API 를 이용하도록 한다.
// 호출 예시 :
//              [[TnkSession sharedInstance] showTrackingAgreementPopup:self
//                                                          agreeAction:^() { [self loadAdlistOnUIThread]; }
//                                                           denyAction:^() { [self cancelPressedOnUIThread]; }
//              ];
- (void) showTrackingAgreementPopup:(UIViewController *)viewController
                    agreeAction:(void (^)(void))agreeAction
                     denyAction:(void (^)(void))denyAction;

// Properties
@property (nonatomic, retain) NSString *headerTitle; // 오퍼리스트 상단(네비게이션바) 타이틀 문구
@property (nonatomic, retain) UIColor *headerColor; // 상단 타이틀 문구 배경색
@property (nonatomic, retain) UIColor *headerTextColor; // 상단 타이틀 문구 글자색
@property (nonatomic, retain) UIColor *backgroundColor; // 전체적으로 사용되는 배경색
@property (nonatomic, retain) UIColor *listItemBackgroundColorNormal;
@property (nonatomic, retain) UIColor *listItemBackgroundColorStripe;
@property (nonatomic, retain) UIColor *listItemBackgroundColorHighlight;

// v4.28 오퍼리스트 기본 디자인 변경되면서 추가된 설정 항목
@property (nonatomic, strong) UIColor *tagNormalColor; // added at v4.28, 오퍼월 포인트 표시 영역 기본색상
@property (nonatomic, strong) UIColor *tagConfirmColor; // added at v4.28, 오퍼월 포인트 표시 영역 설치확인 상태의 색상
@property (nonatomic, strong) UIColor *tagPurchaseColor; // added at v4.28, 오퍼월 포인트 표시 영역 구매형 광고의 색상을 다르게 할 경우 지정

//  v4.28 오퍼리스트 기본 디자인 변경되면서 삭제된 항목
@property (nonatomic, strong) UIImage *webBoxButtonImage; // Deprecated at v4.28
@property (nonatomic, strong) UIImage *freeBoxButtonImage; // Deprecated at v4.28
@property (nonatomic, strong) UIImage *paidBoxButtonImage; // Deprecated at v4.28
@property (nonatomic, strong) UIImage *confirmBoxButtonImage; // Deprecated at v4.28

@property (nonatomic, strong) UIImage *headerHelpButtonImage; // 2018.01.17 오퍼월 상단에 문의하기 버튼 기능
@property (nonatomic, strong) UIImage *headerCloseButtonImage; // 2019.11.28 오퍼월 Modal로 띄운경우 닫기버튼용 이미지 (2019.11.28)
@property (nonatomic, strong) UIColor *headerButtonTintColor; // 2019.12.27 (v4.20) 버튼 이미지 또는 문구 색상은 별도로 지정해야함

@property (nonatomic, assign) BOOL showAdListFooter; // 오퍼리스트하단에 문의하기 및 SDK 버젼 표시를 위한 Footer 영역 표시여부, 기본값 YES
@property (nonatomic, assign) BOOL hideAdListBottomBarWhenPushed; // 기본값 NO (2020.01.13)
@property (nonatomic, strong) UIView *adListSectionHeaderView; // 오퍼리스트의 list 영역의 Section header 를 설정하기 위한 기능이다. adlist header view 커스터마이징 (2019.11.27)

// 오퍼리스트의 list section header 기본 구현 View 의 항목들의 속성설정을 위한 항목이다. (v4.28)
// 만약 adListSectionHeaderView 에 자체 구현한 UIView 를 설정했다면 아래 항목들은 무시한다.
@property (nonatomic, strong) UIColor *adListMenuTextColor; // added at v4.28, 오퍼월 섹션해더의 메뉴 글자색상
@property (nonatomic, strong) UIColor *adListMenuSelectedColor; // added at v4.28, 오퍼월 섹션해더의 메뉴 글자색상 (selected state)
@property (nonatomic, strong) UIColor *adListMenuBackgroundColor; // added at v4.28,  오퍼월 섹션해더의 메뉴 배경색상
@property (nonatomic, strong) UIColor *adListSubMenuTextColor; // added at v4.28, 오퍼월 섹션해더의 하위메뉴 글자색상
@property (nonatomic, strong) UIColor *adListSubMenuBackgroundColor; // added at v4.28, 오퍼월 섹션해더의 하위메뉴 배경색상
@property (nonatomic, strong) UIColor *adListSubMenuPointColor; // added at v4.28, 오퍼월 섹션해더의 하위메뉴 포인트표시용 글자색상
@property (nonatomic, strong) NSString *adListSubMenuPointDesc; // added at v4.28 지금 획득가능한 문구 커스터 마이징
@property (nonatomic, strong) NSString *adListSubMenuPointFormat; // added at v4.28 지금 획득가능한 문구 포인트 표시 포맷문자열, %@ 포함해야함

@property (nonatomic, assign) UIBarStyle adListNavigationBarStyle; // 2020.01.14

@property (nonatomic, retain) UIImage *badgeNewImage; // deprecated at v4.20
@property (nonatomic, retain) UIImage *badgeBestImage; // deprecated at v4.20

@property (nonatomic, retain) UIImage *coinImage; // deprecated at v4.28

@property (nonatomic, retain) UIColor *detailHeaderBackgroundColor; // Deprecated at v4.28, replaced by detailBackgroundColor
@property (nonatomic, strong) UIColor *detailHeaderColor;  // 보상형 광고 상세화면 네비게이션 바 배경색상 (v4.20)
@property (nonatomic, strong) UIColor *detailHeaderTextColor;  // 보상형 광고 상세화면 네비게이션 바 글자색상 (v4.20)
@property (nonatomic, strong) UIImage *detailCloseButtonImage; // 보상형광고 상세 화면에서 닫기버튼용 이미지 (v4.20)
@property (nonatomic, strong) UIColor *detailCloseButtonTintColor; // 버튼 이미지 또는 문구 색상은 별도로 지정해야함 (v4.20)

@property (nonatomic, assign) UIBarStyle adDetailNavigationBarStyle; // 2020.01.14

@property (nonatomic, assign) BOOL detailCloseButtonRight; // 오른쪽에 닫기 버튼 두기 (기본값 NO) (v4.20)
@property (nonatomic, assign) BOOL detailPushNavigation;    // 2023.01.18
@property (nonatomic, strong) NSString *detailPushBackLabel; // 2023.01.18

@property (nonatomic, retain) UIColor *detailBackgroundColor;
@property (nonatomic, strong) UIColor *detailTextColor; // 상세화면 기본 글자색 (2021.03.04, v4.28)
@property (nonatomic, strong) UIColor *detailPointColor; // 상세화면 포인트 글자색 (2021.03.04, v4.28)

@property (nonatomic, retain) UIImage *detailButtonImageNormal;
@property (nonatomic, retain) UIImage *detailButtonImageHighlight;
@property (nonatomic, retain) UIColor *detailButtonTextColor;
@property (nonatomic, strong) NSString *detailButtonLabel; // 이동버튼 문구 (v4.20)

@property (nonatomic, assign) UITableViewStyle tableViewStyle;
@property (nonatomic, assign) UITableViewCellSeparatorStyle tableViewSeparatorStyle; // (v4.20)

@property (nonatomic, assign) BOOL onVideoPlay;
@property (nonatomic, assign) BOOL noVideoClose; // 2016.01.22 동영상 플레이화면에서 X 버튼 안나오게 처리
@property (nonatomic, assign) BOOL vad; // 2016.06.13 일본 v-ad 로고 표시용

@property (nonatomic, assign) int detailImageType; // offerwall 상세화면에서 전면이미지 보여줄지 여부, 0:안보여줌, 1:세로, 2:가로이미지, 3: 정사각형이미지(기본값), 9: 스크린샷

@property (nonatomic, strong) NSString *interstitialCloseTitle; // 2016.09.19 2-button 프레임에서 사용되는 종료 안내 메시지 내용
@property (nonatomic, strong) NSString *interstitialLeftButtonLabel; // 2017.06.14 2-button 프레임에서 사용되는 왼쪽 버튼 라벨
@property (nonatomic, strong) NSString *interstitialRightButtonLabel; // 2017.06.14 2-button 프레임에서 사용되는 오른쪽 버튼 라벨
@property (nonatomic, assign) BOOL interstitialCloseButtonAlignRight; // 2017.06.14 닫기 버튼 위치

@property (nonatomic, strong) AdListItemViewFactory *adItemViewFactory; // 광고리스트 아이템 뷰 객체 생성용

@property (nonatomic, assign) NSInteger adListPoint; // 오퍼월 표시 후 적립가능한 포인트가 저장된다. v4.28
// network error alertview option 처리 (2022.03.04)
@property (nonatomic, assign) BOOL showErrorAlert;

@end
