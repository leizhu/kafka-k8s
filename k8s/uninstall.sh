kubectl delete -f ./zookeeper/zookeeper-stateful-StatefulSets.yaml
kubectl delete -f ./zookeeper/zookeeper-stateful-svc.yaml 

kubectl delete -f ./kafka/kafka-svc.yaml
kubectl delete -f ./kafka/kafka-rc.yaml
