<template>
  <v-container fluid>
    <v-row>
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
    </v-row>
  </v-container>
</template>

<script>
import Web3 from "web3";
export default {
  data() {
    return {
      contractAddress: "0x5FbDB2315678afecb367f032d93F642f64180aa3",
      publicKey: "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
      privateKey:
        "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80",
      endpoint: "http://localhost:13040",
      nftContract: null,
      web3: null,
      createNftForm: {
        uri: "",
      },
    };
  },
  methods: {
    async createNft() {
      const web3 = new Web3(this.endpoint);
      const json = require("../../artifacts/contracts/Nft.sol/Nft.json");
      const nftContract = new web3.eth.Contract(json.abi, this.contractAddress);
      const nonce = await web3.eth.getTransactionCount(
        this.publicKey,
        "latest"
      );
      const tx = {
        from: this.publicKey,
        to: this.contractAddress,
        nonce: nonce,
        gas: 500000,
        data: nftContract.methods.mint(this.createNftForm.uri).encodeABI(),
      };
      const signPromise = web3.eth.accounts.signTransaction(
        tx,
        this.privateKey
      );
      signPromise
        .then((signedTx) => {
          const tx = signedTx.rawTransaction;
          if (tx !== undefined) {
            web3.eth.sendSignedTransaction(tx, function (err, hash) {
              if (!err) {
                console.log("The hash of your transaction is: ", hash);
              } else {
                console.log(
                  "Something went wrong when submitting your transaction:",
                  err
                );
              }
            });
          }
        })
        .catch((err) => {
          console.log("Promise failed:", err);
        });
      // const signPromise = this.web3.eth.accounts.signTransaction(
      //   tx,
      //   this.privateKey
      // );
      // signPromise
      //   .then((signedTx) => {
      //     const tx = signedTx.rawTransaction;
      //     if (tx !== undefined) {
      //       this.web3.eth.sendSignedTransaction(tx, function (err, hash) {
      //         if (!err) {
      //           console.log("The hash of your transaction is: ", hash);
      //         } else {
      //           console.log(
      //             "Something went wrong when submitting your transaction:",
      //             err
      //           );
      //         }
      //       });
      //     }
      //   })
      //   .catch((err) => {
      //     console.log("Promise failed:", err);
      //   });
    },
  },
};
</script>
