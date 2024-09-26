cat Chart.yaml | grep condition | cut -d':' -f2  > values.yaml ; sed -i 's/$/: false/g' values.yaml

