#!/bin/bash

set -euo pipefail

cd "${BASH_SOURCE%/*}"

GPG_VERSION_MAJ_MIN="$(gpg --version | awk 'NR == 1 && /^gpg/ { print $3 }' | cut -d. -f1,2)"

verlte() {
    [ "$1" = "$(printf "$1\n$2" | sort -V | head -n1)" ]
	echo $?
}

echo -n "Real name: "
read realName

echo -n "Email address: "
read emailAddress

unset keyPassphrase
unset CHARCOUNT
PROMPT=""

echo -n "Key passphrase: "
stty -echo

CHARCOUNT=0
while IFS= read -p "$PROMPT" -r -s -n 1 CHAR
do
	if [[ "$CHAR" == $'\0' ]] ; then
		break
	fi
	if [[ "$CHAR" == $'\177' ]] ; then
		if [ "$CHARCOUNT" -gt 0 ] ; then
			CHARCOUNT=$((CHARCOUNT - 1))
			PROMPT=$'\b \b'
			keyPassphrase="${keyPassphrase%?}"
		else
			PROMPT=""
		fi
	else
		CHARCOUNT=$((CHARCOUNT + 1))
		PROMPT='*'
		keyPassphrase+="$CHAR"
	fi
done

stty echo
echo

KEYCONF="$(mktemp --tmpdir=$PWD keyconf.XXXXXXXXXX)"
sed -e s/_REAL_NAME_/"$realName"/g -e s/_EMAIL_/"$emailAddress"/g -e s/_PASSPHRASE_/"$keyPassphrase"/ ./key.template > $KEYCONF

if [[ "$(verlte "$GPG_VERSION_MAJ_MIN" "1.4")" == "0" ]]; then
	< $KEYCONF gpg --batch --gen-key -
else
	< $KEYCONF sed -r '/^%(pub|sec)ring/d' | gpg --batch --full-gen-key -
fi
rm -f $KEYCONF

confirm() {
	read -r -p "${1:-Are you sure? [y/N]: }" yesNo

	case "$yesNo" in
		[yY][eE][sS]|[yY])
			true
			;;
		*)
			false
			;;
	esac
}

[[ "$(verlte "$GPG_VERSION_MAJ_MIN" "1.4")" == "0" ]] && { \
	confirm "Add private key to keyring? [y/N]: " && gpg --import rsa-4096.sec
}
confirm "Export public key? [y/N]: " && gpg -a --export "$emailAddress" > public.key.asc
