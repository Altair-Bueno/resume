# Build resume
# mkdir out
# docker build -t resume .
# docker run --rm -v "$PWD/out:/out" resume /out

FROM denoland/deno:alpine-1.30.3 as templatebuilder
RUN apk update
RUN apk add make

RUN mkdir resume
WORKDIR resume
RUN mkdir scripts
COPY deno.* .
COPY scripts/*.ts scripts/
RUN deno cache --lock=deno.lock scripts/*.ts
COPY . .
RUN make out/resume.tex

FROM alpine:3.17 as texbuilder
RUN apk update
RUN apk add make
RUN apk add msttcorefonts-installer
RUN apk add fontconfig
RUN update-ms-fonts
RUN mkdir resume
COPY Makefile resume
COPY --from=templatebuilder resume/out resume/out
WORKDIR resume
RUN make -o out/resume.tex out/resume.pdf


FROM alpine:3.17
COPY --from=texbuilder resume/out/resume.pdf /resume.pdf
ENTRYPOINT ["cp", "/resume.pdf"] 
