default: update-chart-index update-chart-version update-dep-repo install-repo-version-hook

update-chart-index:
	@scripts/chart-dep-parse.py

update-chart-version:
	@scripts/update-chart-sync-version-from-VERSION.sh

update-dep-repo:
	@scripts/update-dep-repo.sh

install-repo-version-hook:
	@scripts/install-repo-hook.sh