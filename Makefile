init:
	npm install
	docker-compose up -d
run-node:
	docker exec -it contract npx hardhat node
compile:
	docker exec -it contract npx hardhat compile
deploy:
	docker exec -it contract npx hardhat run --network localhost scripts/deploy.ts
test:
	docker exec -it contract npx hardhat test