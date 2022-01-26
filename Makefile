init:
	npm install
	docker-compose up -d
## hardhat commands
hh-node:
	docker exec -it contract npx hardhat node
hh-compile:
	docker exec -it contract npx hardhat compile
hh-deploy:
	docker exec -it contract npx hardhat run --network localhost scripts/deploy.ts
hh-test:
	docker exec -it contract npx hardhat test