<template>
  <v-container fluid>
    <v-row>
      <v-col cols="6">
        <v-card>
          <v-list-item>
            <v-list-item-title> NFT作成 </v-list-item-title>
          </v-list-item>
          <v-list-item>
            <v-list-item-title>
              現在のユーザー public key （デバッグ用）</v-list-item-title
            >
            <v-list-item-subtitle>{{
              this.web3.eth.defaultAccount
            }}</v-list-item-subtitle>
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
      contractAddress: process.env.contractAddress,
      endpoint: process.env.contractNetEndpoint,
      nftContract: null,
      web3: null,
      createNftForm: {
        uri: "",
      },
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
    try {
      const newAccounts = await ethereum.request({
        method: "eth_requestAccounts",
      });
      const accounts = newAccounts;
      if (accounts[0] !== "") {
        this.web3.eth.defaultAccount = accounts[0];
      } else {
        alert("public keyの取得に失敗");
      }
    } catch (error) {
      console.error(error);
    }
    await this.getOwnNfts();
  },
  methods: {
    async getOwnNfts() {
      const num = await this.nftContract.methods
        .balanceOf(this.web3.eth.defaultAccount)
        .call();
      this.nftTable.nfts = [];
      for (let i = 0; i < num; i++) {
        let tokenId = await this.nftContract.methods
          .tokenOfOwnerByIndex(this.web3.eth.defaultAccount, i)
          .call();
        let tokenUri = await this.nftContract.methods.tokenURI(tokenId).call();
        this.nftTable.nfts.push({
          tokenId: tokenId,
          tokenUri: tokenUri,
        });
      }
    },
    async transferToken(item) {
      const tx = {
        from: this.web3.eth.defaultAccount,
        to: this.contractAddress,
        data: this.nftContract.methods
          .transferFrom(
            this.web3.eth.defaultAccount,
            this.transfer.to,
            item.tokenId
          )
          .encodeABI(),
      };
      try {
        const txHash = await window.ethereum.request({
          method: "eth_sendTransaction",
          params: [tx],
        });
        console.log(txHash);
      } catch (error) {
        console.log(error);
      }
    },
    async createNft() {
      const tx = {
        from: this.web3.eth.defaultAccount,
        to: this.contractAddress,
        data: this.nftContract.methods.mint(this.createNftForm.uri).encodeABI(),
      };
      try {
        const txHash = await window.ethereum.request({
          method: "eth_sendTransaction",
          params: [tx],
        });
        console.log(txHash);
      } catch (error) {
        console.log(error);
      }
    },
  },
};
</script>
