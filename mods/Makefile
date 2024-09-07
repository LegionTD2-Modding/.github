FILES_TO_SIGN := \
	config.json \
	LTD2Mods.ps1 \
	LTD2Mods.sh \
	mods_menu.html \
	Uninstall_LTD2Mods.ps1 \
	Uninstall_LTD2Mods.sh \
	core/Core_linux.zip \
	core/Core_win.zip \
	core/LegionTD2-Mods-Installer.ps1 \
	core/LegionTD2-Mods-Installer.sh

GPG_KEY := 4E8CD129EB607A51
SIGNATURES_DIR := signatures

all: sign

$(SIGNATURES_DIR):
	mkdir -p $@

check_key:
	@if ! gpg --list-keys $(GPG_KEY) > /dev/null 2>&1; then \
		echo "GPG key $(GPG_KEY) not found locally. Attempting to fetch from key servers..."; \
		gpg --keyserver hkps://keys.openpgp.org --recv-keys $(GPG_KEY) || \
		gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys $(GPG_KEY) || \
		{ echo "Failed to fetch GPG key $(GPG_KEY). Please ensure the key ID is correct and the key is available."; exit 1; } \
	fi

sign: $(SIGNATURES_DIR) check_key
	@for file in $(FILES_TO_SIGN); do \
		if [ -f $$file ]; then \
			echo "Signing $$file..."; \
			gpg --default-key $(GPG_KEY) --detach-sign --armor $$file; \
			mv $$file.asc $(SIGNATURES_DIR)/$$(basename $$file).asc; \
		else \
			echo "Warning: $$file not found, skipping."; \
		fi; \
	done
	@echo "Signing process completed. Signatures are in $(SIGNATURES_DIR)/"

verify: check_key
	@echo "Verifying signatures..."
	@exit_code=0; \
	for file in $(FILES_TO_SIGN); do \
		base_name=$$(basename $$file); \
		if [ -f $$file ] && [ -f $(SIGNATURES_DIR)/$$base_name.asc ]; then \
			echo "Verifying $$file..."; \
			if gpg --verify $(SIGNATURES_DIR)/$$base_name.asc $$file; then \
				echo "Signature for $$file is valid."; \
			else \
				echo "Error: Signature verification failed for $$file."; \
				exit_code=1; \
			fi; \
		else \
			echo "Error: $$file or its signature not found."; \
			exit_code=1; \
		fi; \
	done; \
	if [ $$exit_code -ne 0 ]; then \
		echo "Verification failed. One or more signatures could not be verified."; \
		exit 1; \
	else \
		echo "All signatures verified successfully."; \
	fi

clean:
	rm -rf $(SIGNATURES_DIR)

.PHONY: all sign clean check_key verify