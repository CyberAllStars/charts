default: update-chart-index update-chart-version install-repo-version-hook

update-chart-index:
	@chartprocess #scripts/chart-dep-parse.py

update-chart-version:
	@scripts/update-chart-sync-version-from-VERSION.sh

update-dep-repo:
	@/scripts/update-default-values-file.sh

install-repo-version-hook:
	@scripts/install-repo-hook.sh
