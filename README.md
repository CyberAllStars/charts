## Usage

[Helm](https://helm.sh) must be installed to use the charts.  Please refer to
Helm's [documentation](https://helm.sh/docs) to get started.

Once Helm has been set up correctly, add the repo as follows:

    helm repo add YOUR_REPO_NAME YOUR_REPO_URL

If you had already added this repo earlier, run `helm repo update` to retrieve
the latest versions of the packages.  You can then run `helm search repo
{alias}` to see the charts.

To install the YOUR_REPO_NAME chart:

    helm install demo YOUR_REPO_NAME/YOUR_CHART_NAME

To uninstall the chart:

    helm delete demo