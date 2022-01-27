<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        account publicKey :{{ account }}
        <v-btn outlined rounded color="primary" large @click="signin()">
          Metamask
        </v-btn>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
export default {
  data() {
    return {
      account: "",
    };
  },
  methods: {
    async signin() {
      try {
        const newAccounts = await ethereum.request({
          method: "eth_requestAccounts",
        });
        const accounts = newAccounts;
        if (accounts[0] !== "") {
          this.account = accounts[0];
        }
      } catch (error) {
        console.error(error);
      }
    },
  },
};
</script>
