# Merge-queue bypass lab. One old tag per stage; each scenario enables one of them in Renovate.
FROM alpine:3.24 AS s1
FROM nginx:1.31 AS s2
FROM python:3.14 AS s3
FROM golang:1.27 AS s4
FROM busybox:1.38 AS s5
FROM perl:5.45 AS s6
FROM ruby:4.0 AS s7
FROM php:8.1 AS s8
FROM haproxy:2.6 AS s9
FROM postgres:15 AS s10
