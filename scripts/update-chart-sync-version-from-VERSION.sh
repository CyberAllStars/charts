REPOVERSION=$(cat VERSION)
sed -i "s/^version:.*/version: $REPOVERSION/" Chart.yaml
sed -i "s/^appVersion:.*/appVersion: \"$REPOVERSION\"/" Chart.yaml


