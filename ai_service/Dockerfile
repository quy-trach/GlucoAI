FROM python:3.9

WORKDIR /code

# Copy file requirements trước để cache layer cho nhanh
COPY ./ai_services/requirements.txt /code/requirements.txt
RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

# Tạo user để tránh lỗi quyền hạn trên HF
RUN useradd -m -u 1000 user
USER user
ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH

WORKDIR $HOME/app

# Copy folder ai_services và models vào container
COPY --chown=user ./ai_services $HOME/app/
# Nếu folder models nằm ngoài ai_services thì sửa đường dẫn tương ứng

# Chạy server ở cổng 7860
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "7860"]