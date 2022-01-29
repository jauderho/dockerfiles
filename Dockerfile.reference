# This is a dummy Dockerfile only used for tracking container digest to version mappings

# Alpine 3.15.0
FROM alpine@sha256:21a3deaa0d32a8057914f36584b5288d2e5ecc984380bc0118285c70fa8c9300 AS alpine3.15-base

# Ubuntu 21.04
FROM ubuntu@sha256:041767af88d66339ef063abfecb0e8052f776460325b8a2b91f5394938d27281 AS ubuntu21.04-base

# Ubuntu 21.10
FROM ubuntu@sha256:cfc189b67f53b322b0ceaabacfc9e2414c63435f362348807fe960d0fbce5ada AS ubuntu21.10-base

# Ubuntu 22.04
FROM ubuntu@sha256:0ad36748089181d832164977bdeb56d08672e352173127d8bfcd9aa4f7b3bd41 AS ubuntu21.10-base

# Go 1.17.6 on Alpine 3.15
FROM golang:alpine@sha256:519c827ec22e5cf7417c9ff063ec840a446cdd30681700a16cf42eb43823e27c AS golang1.17.6-base

# node:16-alpine3.15 
FROM node@sha256:2f50f4a428f8b5280817c9d4d896dbee03f072e93f4e0c70b90cc84bd1fcfe0d AS node16-alpine3.15

# node:17-alpine3.15
FROM node@sha256:6f8ae702a7609f6f18d81ac72998e5d6f5d0ace9a13b866318c76340c6d986b2 AS node17-alpine3.15
