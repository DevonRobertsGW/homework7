FROM python:3.11-slim as builder

WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends gcc

COPY requirements.txt .
RUN pip install --upgrade pip && pip install --user -r requirements.txt

COPY . .

RUN apt-get remove -y gcc && apt-get autoremove -y && rm -rf /root/.cache

FROM python:3.11-slim

RUN useradd -m flaskuser

ENV PATH=/home/flaskuser/.local/bin:$PATH \
    PYTHONUNBUFFERED=1

WORKDIR /app
COPY --from=builder /app /app
COPY --from=builder /root/.local /home/flaskuser/.local

USER flaskuser

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:5000/ || exit 1

EXPOSE 5000

CMD ["python", "app.py"]