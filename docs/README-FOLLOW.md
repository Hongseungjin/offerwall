# FOLLOW OFFERWALL

## Offerwall type `install`

### Handle UI

- Tìm kiếm nhiệm vụ tại danh sách nhiệm vụ ở màn hình home
  
![Alt text](./image_offerwall/install/image1.jpg) -> ![Alt text](./image_offerwall/install/image2.jpg)  -> ![Alt text](./image_offerwall/install/image3.jpg) -> ![Alt text](./image_offerwall/install/image4.jpg)

### Handle Code

- Check install

![Alt text](./image_offerwall/install/image_code1.jpg)

- Nếu chưa được cài đặt thì chuyển màn hình đến store

![Alt text](./image_offerwall/install/image_code3.jpg)

- Khi hoàn thành nhiệm vụ call lên service để xác nhận

![Alt text](./image_offerwall/install/image_code2.jpg)

## Offerwall type `visit`

### Handle UI

![Alt text](./image_offerwall/visit/image1.jpg) -> ![Alt text](./image_offerwall/visit/image2.jpg)  -> ![Alt text](./image_offerwall/visit/image3.jpg)

### Handle Code

- Mở màn hình thực hiện nhiệm vụ

![Alt text](./image_offerwall/visit/image_code1.png)

- Khi xử lý thành công gọi lên service để xác nhận

![Alt text](./image_offerwall/visit/image_code2.png)

## Offerwall type `shopping`

### Handle UI

![Alt text](./image_offerwall/shopping/image1.png) -> ![Alt text](./image_offerwall/shopping/image2.png) -> ![Alt text](./image_offerwall/shopping/image3.png) -> ![Alt text](./image_offerwall/shopping/image4.png) -> ![Alt text](./image_offerwall/shopping/image5.png)

### Handle Code

- Xử lý webview bắt sự kiện mua sắm
  
![Alt text](./image_offerwall/shopping/image_code1.png)

## Offerwall type `subscribe`

### Handle UI

![Alt text](./image_offerwall/subscribe/image5.png) -> ![Alt text](./image_offerwall/subscribe/image1.png) -> ![Alt text](./image_offerwall/subscribe/image2.png) -> ![Alt text](./image_offerwall/subscribe/image3.png) -> ![Alt text](./image_offerwall/subscribe/image4.png)

### Handle Code

- Mở trang cần nhiệm vụ subscribe
  
![Alt text](./image_offerwall/subscribe/image_code1.png)

- Mở trang cần subscribe

![Alt text](./image_offerwall/subscribe/image_code2.png)

- Gửi hình ảnh xác mình đã subscribe

![Alt text](./image_offerwall/subscribe/image_code3.png)

- Khi xử lý thành công gọi lên service để xác nhận

![Alt text](./image_offerwall/subscribe/image_code4.png)
