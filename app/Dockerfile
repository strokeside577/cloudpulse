FROM python:3.11-slim

LABEL maintainer="CloudPulse Team"
LABEL version="1.0.0"
LABEL description="CloudPulse Flask application with Prometheus metrics"
LABEL org.opencontainers.image.source="https://github.com/your-org/cloudpulse"

WORKDIR /app

# Create non-root user before copying files for better layer caching
RUN useradd -m -u 1000 appuser

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

RUN chown -R appuser:appuser /app
USER appuser

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c 'import urllib.request,sys; exit(0) if urllib.request.urlopen("http://localhost:8080/health").status == 200 else sys.exit(1)'

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "4", "app:app"]
