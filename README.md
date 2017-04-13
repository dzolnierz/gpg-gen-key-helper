# gpg-gen-key-helper

Helper script to ease generating GPG keys.

## Requirements

* Debian-based systems:

```shell
apt-get install gnupg
```

* MacOS X:

```shell
brew install gnupg
```

## Usage

Just run:

```shell
bash ./gen-key.sh
```

and answear couple of questions. If you are using GnuPG classic version (1.4) after successful run you should have two files in dir:

*  rsa-4096.pub - public key
*  rsa-4096.sec - private key

If you answear Y to export, you should also have (applicable to classic and modern GnuPG versions):

*  public.key.asc - public key in ASCII format

## Known issues

(Linux-only)

If GnuPG complains about small entropy, you can check its "quality":

```shell
cat /proc/sys/kernel/random/entropy_avail
```

If it returns anything less than 100-200, you have a problem. You can solve that by installing haveged - a simple entropy daemon.

```shell
apt-get install haveged
```
