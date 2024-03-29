.PHONY: check
check:
	cargo check

.PHONY: clippy
clippy:
	cargo clippy

PHONY: test
test: unit-test

.PHONY: unit-test
unit-test:
	cargo unit-test

# This is a local build with debug-prints activated. Debug prints only show up
# in the local development chain (see the `localsecret` command below)
# and mainnet won't accept contracts built with the feature enabled.
.PHONY: build _build
build: _build compress-wasm
_build:
	RUSTFLAGS='-C link-arg=-s' cargo build --release --target wasm32-unknown-unknown

# This is a build suitable for uploading to mainnet.
# Calls to `debug_print` get removed by the compiler.
.PHONY: build-mainnet _build-mainnet
build-mainnet: _build-mainnet compress-wasm
_build-mainnet:
	RUSTFLAGS='-C link-arg=-s' cargo build --release --target wasm32-unknown-unknown

# like build-mainnet, but slower and more deterministic
.PHONY: build-mainnet-reproducible
build-mainnet-reproducible:
	docker run --rm -v "$$(pwd)":/contract \
		--mount type=volume,source="$$(basename "$$(pwd)")_cache",target=/contract/target \
		--mount type=volume,source=registry_cache,target=/usr/local/cargo/registry \
		enigmampc/secret-contract-optimizer:1.0.10

.PHONY: compress-wasm
compress-wasm:
	cp ./target/wasm32-unknown-unknown/release/*.wasm ./contract.wasm
	@## The following line is not necessary, may work only on linux (extra size optimization)
	@# wasm-opt -Os ./contract.wasm -o ./contract.wasm
	cat ./contract.wasm | gzip -9 > ./contract.wasm.gz

.PHONY: schema
schema:
	cargo run --example schema

# Run local development chain with four funded accounts (named a, b, c, and d)
.PHONY: localsecret
localsecret: # CTRL+C to stop
	docker run -it --rm \
		-p 26657:26657 -p 1317:1317 -p 5000:5000 -p 9090:9090 -p 9091:9091 \
		-v $$(pwd):/root/code \
		--name localsecret ghcr.io/scrtlabs/localsecret:v1.8.0

# This relies on running `localsecret` in another console
# You can run other commands on the secretcli inside the dev image
# by using `docker exec secretdev secretcli`.
.PHONY: deploy
deploy:
	docker exec localsecret secretcli tx compute store -y --from a --gas 1000000 /root/code/contract.wasm.gz

# Uploads and instantiates Secret Box, by running create_secret_box.sh
.PHONY: deploybox
deploybox: build
	./scripts/create_secret_box.sh

# Launched Secret Box front end app 
.PHONY: launchapp
launchapp:
	yarn --cwd ./app/ install && \
	yarn --cwd ./app/ dev

CONTR_SRC = ./src
APP_SRC = ./app/src/components/SecretBox
CONTR_SOL = ./app/tutorial/solutions/contract
APP_SOL = ./app/tutorial/solutions/webapp
CONTR_START = ./app/tutorial/lessonstart/contract
APP_START = ./app/tutorial/lessonstart/webapp

.PHONY: apply-src-as-solutions
apply-src-as-solutions:
	cp $(CONTR_SOL)/** ./local/solutions/contract
	cp $(CONTR_SRC)/** $(CONTR_SOL)

	cp $(APP_SOL)/** ./local/solutions/webapp
	cp $(APP_SRC)/** $(APP_SOL)

.PHONY: apply-solutions-on-src
apply-solutions-on-src:
	cp $(CONTR_SRC)/** ./local/src/contract
	cp $(CONTR_SOL)/** $(CONTR_SRC)

	cp $(CONTR_SRC)/** ./local/src/webapp
	cp $(APP_SOL)/** $(APP_SRC)

.PHONY: apply-src-as-lessonstart
apply-src-as-lessonstart:
	cp $(CONTR_START)/** ./local/lessonstart/contract
	cp $(CONTR_SRC)/** $(CONTR_START)

	cp $(APP_START)/** ./local/lessonstart/webapp
	cp $(APP_SRC)/** $(APP_START)

.PHONY: apply-lessonstart-on-src
apply-lessonstart-on-src:
	cp $(CONTR_SRC)/** ./local/src/contract
	cp $(CONTR_START)/** $(CONTR_SRC)

	cp $(APP_SRC)/** ./local/src/webapp
	cp $(APP_START)/** $(APP_SRC)

.PHONY: clean
clean:
	cargo clean
	-rm -f ./contract.wasm ./contract.wasm.gz
	-rm -rf ./app/node_modules
