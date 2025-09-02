.PHONY: up down check-backbone

help:
	@echo "Usage: make [target] [MODE=single|multiple]"
	@echo ""
	@echo "Targets:"
	@echo "  up               Démarrer les machines virtuelles"
	@echo "  down             Arrêter et détruire les machines virtuelles"
	@echo "  check-backbone   Vérifier et démarrer le réseau backbone si nécessaire"
	@echo ""
	@echo "Variables:"
	@echo "  MODE             Choisir l'environnement (single|multiple). Défaut: single"

# Valeur par défaut
MODE ?= single

# Validation du mode
VALID_MODES = single multiple
ifeq ($(filter $(MODE),$(VALID_MODES)),)
$(error MODE must be either 'single' or 'multiple', got '$(MODE)')
endif

check-backbone:
	@if virsh --connect qemu:///system net-info backbone 2>/dev/null | grep "Actif" | grep -E "oui|yes"; then \
		echo "Le réseau backbone est déjà actif"; \
	else \
		virsh --connect qemu:///system net-define ./configurations/networks/net-backbone.xml; \
		virsh --connect qemu:///system net-start backbone; \
		echo "Réseau backbone démarré avec succès"; \
	fi


up: check-backbone
	@cd $(MODE) && vagrant up

down:
	@cd $(MODE) && vagrant destroy -f

up-all:
	@cd single && vagrant up
	@cd multiple && vagrant up

down-all:
	@cd single && vagrant destroy -f
	@cd multiple && vagrant destroy -f
