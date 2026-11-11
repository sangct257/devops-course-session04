
Hệ thống triển khai StoreX được tối ưu hóa theo nguyên tắc DRY sử dụng tính năng File Overriding của Docker Compose.

Chạy lệnh bên dưới (Docker Compose sẽ tự động hợp nhất `docker-compose.yml` và `docker-compose.override.yml`):

```bash
docker compose up -d