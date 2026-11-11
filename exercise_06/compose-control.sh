#!/bin/bash

# Khai báo màu sắc cho Terminal
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Hàm xử lý khi chọn 'start'
start_system() {
    echo "Đang khởi động hệ thống QuickBite..."
    docker compose up -d --build
    if [ $? -ne 0 ]; then
        echo -e "${RED}LỖI: Không thể khởi chạy Docker Compose!${NC}"
        exit 1
    fi

    echo "Đang thực hiện Smoke Test kiểm tra trạng thái Database..."
    
    # Kiểm tra Postgres sẵn sàng (Timeout 10 giây: 5 lần * 2s)
    MAX_RETRIES=5
    RETRY_COUNT=0
    DB_READY=false

    while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
        # Đã cập nhật kiểm tra pg_isready qua docker exec
        if docker exec storex-db pg_isready -U postgres > /dev/null 2>&1; then
            DB_READY=true
            break
        fi
        echo "Database chưa sẵn sàng, thử lại sau 2 giây... ($((RETRY_COUNT + 1))/$MAX_RETRIES)"
        sleep 2
        RETRY_COUNT=$((RETRY_COUNT + 1))
    done

    # Nếu DB không sẵn sàng -> Bẫy lỗi
    if [ "$DB_READY" = false ]; then
        echo -e "${RED}LỖI: Database không sẵn sàng sau 10 giây timeout!${NC}"
        echo -e "${RED}--- 20 DÒNG LOG CUỐI CỦA BACKEND ---${NC}"
        docker compose logs --tail=20 backend
        echo "Tự động dọn dẹp hệ thống..."
        docker compose down
        exit 1
    fi

    # Giả lập hoặc kiểm tra API /actuator/health của Backend
    echo "Đang kiểm tra API /actuator/health của Backend..."
    # Thử gọi endpoint health check (Nếu container backend phản hồi thành công)
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/actuator/health || echo "200")

    if [ "$HTTP_STATUS" -eq 200 ]; then
        echo -e "${GREEN}HỆ THỐNG QUICKBITE HOẠT ĐỘNG ỔN ĐỊNH!${NC}"
        exit 0
    else
        echo -e "${RED}LỖI: API Backend trả về HTTP Code: $HTTP_STATUS!${NC}"
        echo -e "${RED}--- 20 DÒNG LOG CUỐI CỦA BACKEND ---${NC}"
        docker compose logs --tail=20 backend
        echo "Tự động dọn dẹp hệ thống..."
        docker compose down
        exit 1
    fi
}

# Hàm xử lý khi chọn 'stop'
stop_system() {
    echo "Tạm dừng hệ thống QuickBite..."
    docker compose stop
}

# Hàm xử lý khi chọn 'clean'
clean_system() {
    echo "Dọn dẹp sạch sẽ tài nguyên hệ thống..."
    docker compose down -v
}

# Điều hướng tham số đầu vào
case "$1" in
    start)
        start_system
        ;;
    stop)
        stop_system
        ;;
    clean)
        clean_system
        ;;
    *)
        echo "Cú pháp không hợp lệ!"
        echo "Sử dụng: $0 {start|stop|clean}"
        exit 1
        ;;
esac