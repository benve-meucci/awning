# AWNING: A dockerized Bitcoin + LND node
Something like [Umbrel](https://umbrel.com) but uglier, Bitcoin/Lightning-Network oriented and with no frills. With all the best-practices of [RaspiBolt](https://raspibolt.org/).

**Awning** doesn't install anything on your PC, making it lightweight, customizable and portable.

# Prerequisites
- docker
- docker-compose

# Before you begin
## LND channel backups preparation
The Static Channels Backup (SCB) is a feature of LND that allows for the on-chain recovery of lightning channel balances in the case of a bricked node. Despite its name, it does not allow the recovery of your LN channels but increases the chance that you'll recover all (or most) of your off-chain (local) balances.

**Awning** will automatically upload a copy of your `channel.backup` every time it changes on a Github repository, so you will need to create one and provide upload credential (see [here](#rsa))

#### Create a GitHub repository

* Go to [GitHub](https://github.com/), sign up for a new user account, or log in with an existing one.

* Create a new repository: [https://github.com/new](https://github.com/new)
  * Select "Private" (rather than the default "Public")
  * Click on "Create repository"
  * Annotate your SSH repository address. You will need this [later](#repo).

## Edit and understand the .env file

The `.env` file contains some **Awning** setup parameters that you can customize:

- **BITCOIN_ARCH** - Here you need to choose your computer CPU architecture. Write `aarch64` for ARM (Raspberry Pi, etc) or `x86_64` for Intel or AMD.
- **LND_ARCH** - Write `arm64` for ARM (Raspberry Pi, etc) or `amd64` for Intel or AMD.
- **RTL_PASSWORD** - Choose the password for accessing the *"Ride The Lightning"* web interface. You can change it any time but don't forget to restart the RTL container afterwards with `docker-compose restart rtl`.
- <a name="pwd"></a>**LND_PASSWORD** - Choose the password to automatically protected and unlock the LND wallet. You will need to use this password again [here](#lnd). Changing this after the first setup will have no effect.
- <a name="repo"></a>**SCB_REPO** - Paste here the address of your new created Github repository. It should be something like `git@github.com:giovantenne/remote-lnd-backup.git`.


# How to begin

Run the following command:
  ```sh
  $ docker-compose up -d
  ```
This will spin-up the following services/containers in background:
- [Bitcoin Core](https://github.com/bitcoin/bitcoin)
- [Electrs](https://github.com/bitcoin/bitcoin)
- [LND](https://github.com/lightningnetwork/lnd)
- [RTL](https://github.com/Ride-The-Lightning/RTL) (Ride The Lightning)
- [TOR](https://www.torproject.org/)
- [Nginx](https://github.com/nginx) (used as reverse-proxy)
- [SCB](https://github.com/lightningnetwork/lnd/blob/master/docs/recovery.md) (Automatic static channel backups)

The first time it will take some time to build all the images from scratch (especially compiling the Electrs binary).

After all the images are built, “bitcoind” should start, begin to sync and validate the Bitcoin blockchain. If you already downloaded the blockchain somewhere else, you can just copy the data to the `./data/bitcoin` directory.

Check the status of the bitcoin daemon that was started with the following command. Exit with Ctrl-C

  ```sh
  $ docker logs -f bitcoin
  ```

You can stop all the continars with
  ```sh
  $ docker-compose down
  ```


# Finish the setup

Once you first start the containers there is still a couple of steps to do:
<a name="rsa"></a>
### Authorize SCB to be uploaded on Github

Run this command:

  ```sh
  $ docker logs scb 2> /dev/null | grep -o 'ssh-rsa.*'
  ```

* Go back to the GitHub repository webpage
  * Click on "Settings", then "Deploy keys", then "Add deploy key"
  * Type a title (e.g., "SCB")
  * In the "Key" box, copy/paste the string generated above starting (e.g. `ssh-rsa 5678efgh... scb@28ba58e278da`)
  * Tick the box "Allow write access" to enable this key to push changes to the repository
  * Click "Add key"
 <a name="lnd"></a>
### Create or restore the LND wallet

Run this command:
  ```sh
  $ docker exec -it lnd lncli create
  ```

Enter your password as wallet password (it must be exactly the same you stored in `.env` as [LND_PASSWORD](#pwd)). 

To create a a new wallet, select `n` when asked if you have an existing cipher seed. Just press enter if asked about an additional seed passphrase, unless you know what you’re doing. A new cipher seed consisting of 24 words is created.

# Directory structure
```bash
├── configs
│   ├── bitcoin.conf
│   ├── electrs.toml
│   ├── lnd.conf
│   ├── nginx.conf
│   ├── nginx-reverse-proxy.conf
│   ├── rtl.json
│   └── torrc
├── data
│   ├── bitcoin
│   ├── electrs
│   ├── lnd
│   ├── rtl
│   ├── scb
│   └── tor
├── docker-compose.yml
├── Dockerfiles
│   ├── Dockerfile.bitcoin
│   ├── Dockerfile.electrs
│   ├── Dockerfile.lnd
│   ├── Dockerfile.nginx
│   ├── Dockerfile.rtl
│   ├── Dockerfile.scb
│   ├── Dockerfile.tor
│   └── entrypoints
│       ├── lnd.sh
│       └── scb.sh
├── LICENSE
└── README.md
```
### configs
Here you can find all the configuration files. Feel free to edit them as you like, but please be carefull to not mess-up with authentication method: **Awning** currently uses cookies authentication between services instead of RPC.

### data
Here is where the data are persisted. THe Bitcon Blockchain, the Electrs indexes, the LND channels, etc. are all stored here

### Dockerfiles
Here you can find and inspect all the files used to build the images. **Don't trust, verify**!