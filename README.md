# Erc721 example

# Set up

## dev

- 以下コマンドを実行

```
$ make init
```

```
$ make hh-node
```

```
$ make hh-deploy
```

- front/pages/index.vue の contractaddress をデプロイした address にする

```
$ cd front && yarn dev
```

- localhost:3000 を開くと表示されるはず！

## test net

- front/pages/testnet.vue の contractAddress/endpoint を修正する

- front アプリ起動

```
$ cd front && yarn dev
```

※testnet のアプリを用意する必要があります。
