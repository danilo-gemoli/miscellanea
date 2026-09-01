install:
	sudo ./install-service.sh
.PHONY: install

remove:
	sudo ./remove-service.sh
.PHONY: remove

status:
	systemctl status xresources-fix.service
.PHONY: status

logs:
	journalctl -fu xresources-fix.service -e
.PHONY: logs
