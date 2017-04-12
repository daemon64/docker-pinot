Pinot in Kubernetes
===================

This is a simple set up to run Pinot in Kubernetes, so that it can easily be deployed locally or on your favorite cloud service.

Local setup
-----------

1. Install Docker
2. Install Kubernetes and minikube
3. Configure minikube to allocate more memory: `minikube config set memory 8000`
4. Start minikube to create a local Kubernetes cluster: `minikube start`
5. Open the Kubernetes dashboard: `minikube dashboard`
6. Deploy ZK and Pinot (one Zookeeper, one Pinot controller, one Pinot server and one Pinot broker): `kubectl create -f pinot-zk-minikube.yaml`
7. Open the Pinot controller interface: `minikube service pinot-controller-headless`
8. Congrats, enjoy your Pinot! :)

Azure setup
-----------

Do not use this yet in prod, there are no persistent volumes so your data will go away!

1. Install the Azure 2.0 CLI tools
2. Login into azure: `az login`
3. Double check that your account is set to "Pay as you go," as the limits for free trial accounts are too low. See https://azure.microsoft.com/en-us/offers/ms-azr-0003p/
4. Create a resource group, either through the Azure web interface or through the command line: `az group create --name=pinot-test --location=westus`
5. Create a Kubernetes cluster: `az acs create --orchestrator-type=kubernetes --resource-group pinot-test --name=pinot-test-cluster --generate-ssh-keys`
6. Download your Kubernetes cluster credentials: `az acs kubernetes get-credentials --resource-group=pinot-test --name=pinot-test-cluster`
7. Open the Kubernetes web interface: `kubectl proxy` and then go to http://localhost:8001/ui
8. Deploy ZK and Pinot on Azure (three Zookeepers in an ensemble, one Pinot controller, two Pinot brokers and three Pinot servers) : `kubectl create -f pinot-zk-azure.yaml`
9. Wait until the Kubernetes deployment is complete
10. Wait for the load balancer to grab a public IP address: `watch 'kubectl get svc'`
11. Once you get a public IP address, go to the Pinot console
12. Enjoy your Pinot!

Building Docker images
----------------------

```
docker build -t jfim/pinot:latest -f Dockerfile-pinot .
docker build -t jfim/pinot-server:latest -f Dockerfile-server .
docker build -t jfim/pinot-broker:latest -f Dockerfile-broker .
docker build -t jfim/pinot-controller:latest -f Dockerfile-controller .
docker push jfim/pinot:latest
docker push jfim/pinot-server:latest
docker push jfim/pinot-broker:latest
docker push jfim/pinot-controller:latest
```

Caveats
-------

- Persistent volumes aren't configured at all, so stopping any of the instances will eat your data.
