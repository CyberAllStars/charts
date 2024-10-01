# create git submodule bash tool functions.

function add_submodule_from_chart_index() {
    local charts_index_path="../charts-index-repos"
    local charts_index_dirs=($(ls -l $charts_index_path | grep "^d" | awk '{print $9}'))
    for dir in "${charts_index_dirs[@]}"; do
        local chart_path="$charts_index_path/$dir/Chart.yaml"
        if [ -f "$chart_path" ]; then
            echo "Adding submodule $dir"
            git submodule add "$charts_index_path/$dir" "src/$dir"
        fi
    done
}

function add_chart_yaml_from_chart_index() {
    local charts_index_path="../charts-index-repos"
    local charts_index_dirs=($(ls -l $charts_index_path | grep "^d" | awk '{print $9}'))
    for dir in "${charts_index_dirs[@]}"; do
        local chart_path="$charts_index_path/$dir/Chart.yaml"
        if [ -f "$chart_path" ]; then
            echo "Adding Chart.yaml from $dir"
            cat "$chart_path" | grep -A 9999 "dependencies:" | grep -v "dependencies:" >> Chart.yaml
        fi
    done
}
