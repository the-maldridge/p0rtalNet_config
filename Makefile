.PHONY: mkdir_secrets secrets inspircd_inspircd_power_diepass inspircd_inspircd_power_restartpass inspircd_links_minecraft_recvpass inspircd_links_minecraft_sendpass inspircd_modules_cloak_key inspircd_opers

SECRETS_DIR = secret

secrets: mkdir_secrets inspircd_inspircd_power_diepass inspircd_inspircd_power_restartpass inspircd_modules_cloak_key inspircd_opers

mkdir_secrets:
	mkdir -pm 0700 ${SECRETS_DIR}

inspircd_links_minecraft_recvpass inspircd_links_minecraft_sendpass inspircd_modules_cloak_key:
	export LC_CTYPE=C; tr -dc '!-~' < /dev/urandom | fold -w 32 | head -n 1 > ${SECRETS_DIR}/$@

inspircd_inspircd_power_diepass:
	python -c 'from inspircd_opers import *; HMAC_shim()' ${SECRETS_DIR} inspircd_inspircd_power_diepass "Password to shutdown the IRC server: "

inspircd_inspircd_power_restartpass:
	python -c 'from inspircd_opers import *; HMAC_shim()' ${SECRETS_DIR} inspircd_inspircd_power_restartpass "Password to restart the IRC server: "

inspircd_opers:
	python inspircd_opers.py ${SECRETS_DIR}
