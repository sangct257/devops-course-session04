# Sử dụng Base Image JRE Alpine siêu nhẹ tối ưu dung lượng
FROM eclipse-temurin:17-jre-alpine

# Thiết lập thư mục làm việc trong container
WORKDIR /app

# Sao chép file .jar đã biên dịch từ thư mục build/libs/ vào container
COPY build/libs/*.jar app.jar

# Khai báo cổng 8080 ứng dụng lắng nghe
EXPOSE 8080

# Lệnh khởi chạy ứng dụng Spring Boot khi container bật
ENTRYPOINT ["java", "-jar", "app.jar"]