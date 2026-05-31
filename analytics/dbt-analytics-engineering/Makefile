SHELL := /usr/bin/env bash
export DBT_PROFILES_DIR := $(CURDIR)/profiles

.PHONY: deps seed compile parse debug clean

deps:
	dbt deps

seed:
	dbt seed --full-refresh

compile:
	dbt compile

parse:
	dbt parse

debug:
	dbt debug

clean:
	dbt clean
