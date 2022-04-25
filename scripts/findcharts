

o=$(pwd)
        
for i in $( find $1 -iname Chart.yaml ); do
        n=$(echo $i  | sed 's/Chart\.yaml//g');
        cd $n; 
        helm dependency update;
        cd $o
        helm package $n
done

helm repo index .
     