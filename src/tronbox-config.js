module.exports = {
    networks: {
        mainnet: {
            // Don't put your private key here:
            privateKey: process.env.PRIVATE_KEY_MAINNET,
            /**
             * Create a .env file (it must be gitignored) containing something like
             *
             *   export PRIVATE_KEY_MAINNET=4E7FEC...656243
             *
             * Then, run the migration with:
             *
             *   source .env && tronbox migrate --network mainnet
             */
            userFeePercentage: 100,
            feeLimit: 1000 * 1e6,
            fullHost: 'https://api.trongrid.io',
            network_id: '1'
        },
        shasta: {
            // Obtain test coin at https://shasta.tronex.io/
            privateKey: process.env.PRIVATE_KEY_SHASTA,
            userFeePercentage: 50,
            feeLimit: 1000 * 1e6,
            fullHost: 'https://api.shasta.trongrid.io',
            network_id: '2'
        },
        nile: {
            // Obtain test coin at https://nileex.io/join/getJoinPage
            privateKey: "1184b35f821ec2f8d174bf887485df893615df251f952f92b157ee204628d6be",
            userFeePercentage: 100,
            feeLimit: 3000 * 1e6,
            fullHost: 'https://nile.trongrid.io',
            network_id: '3',
            privateKeys: [
                // import 0 
                "1184b35f821ec2f8d174bf887485df893615df251f952f92b157ee204628d6be",
                "2b4abbdb4061b52cf599e539b8c506b732d903aaa14937027d4d8a58a7a311e7",
                "16a68ae9f2fe1eb5c68fe96d03628bd2592fcc1848f9d52283144632ed2d048b",
                "e7f6db78d275e1f520f01c2d61043c40062e6d1ff6a963b29ad9ffe5727041d2",
                "f08f649044ff1ca7fc463f1206c8227ecc104064aa145ff6c3beba7de366d8c5",
                "a8362a20ad2878a5edad414334df4ba8e0a00ddf9bdfc738aa5f17d055a92766"
            ]
        },
        development: {
            // For tronbox/tre docker image
            // See https://hub.docker.com/r/tronbox/tre
            privateKey: '',
            userFeePercentage: 0,
            feeLimit: 1000 * 1e6,
            fullHost: 'http://10.10.1.108:9090',
            network_id: '9'
        }
    },
    compilers: {
        solc: {
            version: '0.8.24',
            // An object with the same schema as the settings entry in the Input JSON.
            // See https://docs.soliditylang.org/en/latest/using-the-compiler.html#input-description
            settings: {
                optimizer: {
                    enabled: true,
                    runs: 200
                }
                ,evmVersion: "cancun"
                //,viaIR: true,
            }
        }
    }
};
