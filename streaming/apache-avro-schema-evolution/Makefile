.PHONY: up down install register-v1 register-v2 produce-v1 produce-v2 consume check-compatibility subject-status

up:
	docker compose up -d

down:
	docker compose down -v

install:
	pip install -r requirements.txt

register-v1:
	bash scripts/register_v1.sh

register-v2:
	bash scripts/register_v2.sh

check-compatibility:
	bash scripts/check_backward_compatibility.sh

subject-status:
	bash scripts/subject_status.sh

produce-v1:
	python producer/producer.py --version v1

produce-v2:
	python producer/producer.py --version v2

consume:
	python consumer/consumer.py
