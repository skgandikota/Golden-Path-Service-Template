# Golden Path Service Template — Standard Dockerfile
# Every service gets an identical, minimal container definition.

FROM python:3.12-slim

# Least-privilege: run as non-root user
RUN adduser --disabled-password --no-create-home appuser

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app/ ./app/

USER appuser

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
