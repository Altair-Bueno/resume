# Build resume
# mkdir out
# docker build -t resume .
# docker run --rm -v "$PWD/out:/out" resume /out

FROM python:3.11 as pybuilder
RUN mkdir resume
WORKDIR resume
COPY Makefile requirements.txt .
RUN make deps/python
COPY . .
RUN make out/resume.tex


FROM alpine:3.17 as texbuilder
RUN apk update
RUN apk add msttcorefonts-installer
RUN apk add make
RUN apk add tectonic
RUN apk add fontconfig
RUN update-ms-fonts
RUN fc-cache -fv
RUN fc-match Arial

RUN mkdir resume
COPY Makefile resume
COPY --from=pybuilder resume/out resume/out
WORKDIR resume
RUN make -o out/resume.tex out/resume.pdf


FROM alpine:3.17
COPY --from=texbuilder resume/out/resume.pdf /resume.pdf
ENTRYPOINT ["cp", "/resume.pdf"] 
