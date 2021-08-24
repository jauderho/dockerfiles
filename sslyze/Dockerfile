FROM python:3.9-slim
#FROM python:3.9-alpine

ARG BUILD_VERSION

COPY requirements.txt . 

#RUN pip install sslyze==${BUILD_VERSION}
RUN pip install --no-cache-dir -r requirements.txt

ENTRYPOINT ["sslyze"]
CMD ["-h"]
