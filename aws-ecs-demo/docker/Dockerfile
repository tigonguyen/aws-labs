FROM python:3.6-alpine

WORKDIR /app
COPY . .

RUN pip install -r requirements.txt
EXPOSE 80

CMD ["python", "app.py"]