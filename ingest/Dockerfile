FROM python:3.11-slim

WORKDIR /load

COPY requirements.txt .
#RUN pip install --no-cache-dir -r requirements.txt
RUN pip install -r requirements.txt

COPY . .

CMD ["python3", "ingest.py"]
