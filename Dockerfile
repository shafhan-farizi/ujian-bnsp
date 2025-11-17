FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY --exclude=terraform --exclude=Dockerfile --exclude=Jenkinsfile --exclude=README.md --exclude=.* . .

RUN useradd app
USER app 

EXPOSE 5152

CMD ["python3", "app.py"]