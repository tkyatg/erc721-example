<template>
  <v-container fluid>
    <v-row>
      <v-col cols="12">
        <v-card>
          <v-list-item>
            <v-list-item-title>
              現在のユーザー public key: {{ this.user.publicKey }}
            </v-list-item-title>
          </v-list-item>
          <v-divider />
          <v-list-item>
            <v-text-field
              v-model="userForm.publicKey"
              label="publicKey"
              class="pr-3"
            ></v-text-field>
            <v-text-field
              v-model="userForm.privateKey"
              label="privateKey"
              class="pl-3"
            ></v-text-field>
          </v-list-item>

          <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn outlined rounded color="primary" large @click="changeUser()">
              変更する
            </v-btn>
          </v-card-actions>
        </v-card>
      </v-col>
      <v-col cols="6">
        <v-card>
          <v-list-item>
            <v-list-item-title> NFT作成 </v-list-item-title>
          </v-list-item>
          <v-list-item>
            <v-text-field
              v-model="createNftForm.uri"
              label="URI"
            ></v-text-field>
          </v-list-item>
          <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn outlined rounded color="primary" large @click="createNft()">
              作成
            </v-btn>
          </v-card-actions>
        </v-card>
      </v-col>
      <v-col cols="12">
        <v-card>
          <v-list-item>
            <v-list-item-title> 持っているNFT一覧 </v-list-item-title>
          </v-list-item>
          <v-card-title>
            <v-text-field
              v-model="transfer.to"
              label="プレゼント先のアドレス"
            ></v-text-field>
          </v-card-title>
          <v-data-table :headers="nftTable.headers" :items="nftTable.nfts">
            <template v-slot:[`item.actions`]="{ item }">
              <v-btn color="primary" large @click="transferToken(item)">
                プレゼントする
              </v-btn>
            </template>
          </v-data-table>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import Web3 from "web3";
export default {
  data() {
    return {
      contractAddress: "0x5FbDB2315678afecb367f032d93F642f64180aa3",
      endpoint: "http://localhost:13040",
      nftContract: null,
      web3: null,
      createNftForm: {
        uri: "",
      },
      user: {
        publicKey: "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
        privateKey:
          "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80",
      },
      userForm: {},
      nftTable: {
        headers: [
          { text: "tokenId", value: "tokenId" },
          { text: "tokenUri", value: "tokenUri" },
          { text: "Actions", value: "actions" },
        ],
        nfts: [],
      },
      transfer: {
        to: "",
      },
    };
  },
  async created() {
    const web3 = new Web3(this.endpoint);
    const json = require("../../artifacts/contracts/Nft.sol/Nft.json");
    const nftContract = new web3.eth.Contract(json.abi, this.contractAddress);
    this.web3 = web3;
    this.nftContract = nftContract;
    await this.setApprovalForAll();
    await this.getOwnNfts();
  },
  methods: {
    async setApprovalForAll() {
      const nonce = await this.web3.eth.getTransactionCount(
        this.user.publicKey,
        "latest"
      );
      const tx = {
        from: this.user.publicKey,
        to: this.contractAddress,
        nonce: nonce,
        gas: 500000,
        data: this.nftContract.methods
          .setApprovalForAll(process.env.appPublicKey, true)
          .encodeABI(),
      };
      const signPromise = this.web3.eth.accounts.signTransaction(
        tx,
        this.user.privateKey
      );
      await signPromise
        .then((signedTx) => {
          const tx = signedTx.rawTransaction;
          if (tx !== undefined) {
            this.web3.eth.sendSignedTransaction(tx, function (err, hash) {
              if (err) {
                alert(err);
              }
            });
          }
        })
        .catch((err) => {
          console.log("Promise failed:", err);
        });
    },
    changeUser() {
      this.user = {
        publicKey: this.userForm.publicKey,
        privateKey: this.userForm.privateKey,
      };
      this.getOwnNfts();
      this.setApprovalForAll();
    },
    async getOwnNfts() {
      const num = await this.nftContract.methods
        .balanceOf(this.user.publicKey)
        .call();
      this.nftTable.nfts = [];
      for (let i = 0; i < num; i++) {
        let tokenId = await this.nftContract.methods
          .tokenOfOwnerByIndex(this.user.publicKey, i)
          .call();
        let tokenUri = await this.nftContract.methods.tokenURI(tokenId).call();
        this.nftTable.nfts.push({
          tokenId: tokenId,
          tokenUri: tokenUri,
        });
      }
    },
    async transferToken(item) {
      const nonce = await this.web3.eth.getTransactionCount(
        process.env.appPublicKey,
        "latest"
      );
      const tx = {
        from: process.env.appPublicKey,
        to: this.contractAddress,
        nonce: nonce,
        gas: 500000,
        data: this.nftContract.methods
          .transferFrom(this.user.publicKey, this.transfer.to, item.tokenId)
          .encodeABI(),
      };
      const signPromise = this.web3.eth.accounts.signTransaction(
        tx,
        process.env.appPrivateKey
      );
      await signPromise
        .then((signedTx) => {
          const tx = signedTx.rawTransaction;
          if (tx !== undefined) {
            this.web3.eth.sendSignedTransaction(tx, function (err, hash) {
              if (err) {
                alert(err);
              }
            });
          }
        })
        .catch((err) => {
          console.log("Promise failed:", err);
        });
      alert("プレゼントしました。");
      this.getOwnNfts();
    },
    async createNft() {
      const nonce = await this.web3.eth.getTransactionCount(
        this.user.publicKey,
        "latest"
      );
      const tx = {
        from: this.user.publicKey,
        to: this.contractAddress,
        nonce: nonce,
        gas: 500000,
        data: this.nftContract.methods.mint(this.createNftForm.uri).encodeABI(),
      };
      const signPromise = this.web3.eth.accounts.signTransaction(
        tx,
        this.user.privateKey
      );
      await signPromise
        .then((signedTx) => {
          const tx = signedTx.rawTransaction;
          if (tx !== undefined) {
            this.web3.eth.sendSignedTransaction(tx, function (err, hash) {
              if (err) {
                alert(err);
              }
            });
          }
        })
        .catch((err) => {
          console.log("Promise failed:", err);
        });
      this.getOwnNfts();
    },
  },
};
</script>
