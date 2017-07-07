# deploy zookeeper 
kubectl create -f ./zookeeper/zookeeper-stateful-svc.yaml
kubectl create -f ./zookeeper/zookeeper-stateful-StatefulSets.yaml

sleep 30
# deploy kafka
kubectl create -f ./kafka/kafka-svc.yaml
kubectl create -f ./kafka/kafka-rc.yaml
