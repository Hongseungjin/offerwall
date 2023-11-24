# FOLLOW OFFERWALL

## Offerwall type `install`

### Handle UI

- Tìm kiếm nhiệm vụ tại danh sách nhiệm vụ ở màn hình home (홈 화면의 미션 목록에서 검색)
  
![Alt text](./image_offerwall/install/image1.jpg) -> ![Alt text](./image_offerwall/install/image2.jpg)  -> ![Alt text](./image_offerwall/install/image3.jpg) -> ![Alt text](./image_offerwall/install/image4.jpg)

### Handle Code

- Check install

![Alt text](./image_offerwall/install/image_code1.jpg)

- Nếu chưa được cài đặt thì chuyển màn hình đến store (설치 아직 안하면 스투어 화면으로 이동)

![Alt text](./image_offerwall/install/image_code3.jpg)

- Khi hoàn thành nhiệm vụ call lên service để xác nhận (미션 환료되면 인증하기 위해서는 서비스 호출)

![Alt text](./image_offerwall/install/image_code2.jpg)

## Offerwall type `visit`

### Handle UI

![Alt text](./image_offerwall/visit/image1.jpg) -> ![Alt text](./image_offerwall/visit/image2.jpg)  -> ![Alt text](./image_offerwall/visit/image3.jpg)

### Handle Code

- Mở màn hình thực hiện nhiệm vụ (미션 실행 화면 열기)

![Alt text](./image_offerwall/visit/image_code1.png)

- Khi xử lý thành công gọi lên service để xác nhận (미션 실행 화면 열기)

![Alt text](./image_offerwall/visit/image_code2.png)

## Offerwall type `shopping`

### Handle UI

![Alt text](./image_offerwall/shopping/image1.png) -> ![Alt text](./image_offerwall/shopping/image2.png) -> ![Alt text](./image_offerwall/shopping/image3.png) -> ![Alt text](./image_offerwall/shopping/image4.png) -> ![Alt text](./image_offerwall/shopping/image5.png)

### Handle Code

- Xử lý webview bắt sự kiện mua sắm (웹뷰를 처리하여 구입 이벤트 잡기)
  
![Alt text](./image_offerwall/shopping/image_code1.png)

## Offerwall type `subscribe`

### Handle UI

![Alt text](./image_offerwall/subscribe/image5.png) -> ![Alt text](./image_offerwall/subscribe/image1.png) -> ![Alt text](./image_offerwall/subscribe/image2.png) -> ![Alt text](./image_offerwall/subscribe/image3.png) -> ![Alt text](./image_offerwall/subscribe/image4.png)

### Handle Code

- Mở trang nhiệm vụ subscribe (구독 미션 페이지 열기)
  
![Alt text](./image_offerwall/subscribe/image_code1.png)

- Mở trang cần subscribe (구독 페이지 열기)

![Alt text](./image_offerwall/subscribe/image_code2.png)

- Gửi hình ảnh xác mình đã subscribe (구독후에 화면캡쳐 사진 보내기)

![Alt text](./image_offerwall/subscribe/image_code3.png)

- Khi xử lý thành công gọi lên service để xác nhận (미션 실행 화면 열기)

![Alt text](./image_offerwall/subscribe/image_code4.png)

## Offerwall type `join`

### Handle UI

![Alt text](./image_offerwall/join/image1.png) -> ![Alt text](./image_offerwall/join/image2.png) -> ![Alt text](./image_offerwall/join/image3.png) -> ![Alt text](./image_offerwall/join/image4.png)

### Handle Code

- Mở trang nhiệm vụ subscribe (구독 미션 페이지 열기)
  
![Alt text](./image_offerwall/join/image_code1.png)

- Khi xử lý thành công gọi lên service để xác nhận (미션 실행 화면 열기)

![Alt text](./image_offerwall/join/image_code2.png)
