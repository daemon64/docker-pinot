Pinot on Kubernetes
===================

This is a simple set up to run Pinot in Kubernetes, so that it can easily be deployed locally or on your favorite cloud service.

Local setup
-----------

1. Install Docker
2. Install Kubernetes and `minikube`
3. Configure `minikube` to allocate more memory: `minikube config set memory 8192`
4. Start `minikube` to create a local Kubernetes cluster: `minikube start`
5. Open the Kubernetes dashboard: `minikube dashboard`
6. Deploy ZK and Pinot (one Zookeeper, one Pinot controller, one Pinot server and one Pinot broker): `kubectl apply -f minikube`
7. Wait until all components are started (it should take a couple of minutes until all persistent volumes are bound and components are successfully started)
8. Open the Pinot controller interface: `minikube service pinot-controller-headless`
9. Congrats, enjoy your Pinot! :)

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
8. Deploy ZK and Pinot on Azure (three Zookeepers in an ensemble, one Pinot controller, two Pinot brokers and three Pinot servers) : `kubectl apply -f azure`
9. Wait until the Kubernetes deployment is complete (should take several minutes to create Azure disk volumes, bind them to persistent volumes and start all components)
10. Wait for the load balancer to grab a public IP address: `watch 'kubectl get svc'`
11. Once you get a public IP address, go to the Pinot console
12. Enjoy your Pinot!

AWS setup
---------
1. Configure a Kubernetes cluster using `kops`: https://github.com/kubernetes/kops/blob/master/docs/aws.md
2. Wait until your kubernetes cluster is ready: `kops validate cluster`
3. Install the dashboard `kops` addon: `kubectl create -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/kubernetes-dashboard/v1.7.1.yaml`
4. Open the dashboard to monitor the configuration: `kubectl proxy kubernetes-dashboard`
5. Apply the Azure configuration: `kubectl apply -f azure`
6. Enjoy your Pinot!

GCP setup
---------
In theory, you should be able to deploy the Azure configuration directly on GKE or GCP with `kops`. We haven't tested this.

1. Configure a Kubernetes cluster, either through GKE (https://cloud.google.com/kubernetes-engine/docs/quickstart) or `kops` (https://github.com/kubernetes/kops/blob/master/docs/tutorial/gce.md)
2. Apply the Azure configuration: `kubectl apply -f azure`

Enjoying Pinot
--------------
1. First, get a nice glass of your favorite `Pinot (Noir|Grigio)`
2. Deploy Pinot on either locally, on Azure, AWS, or GCP as described above.
3. Proxy the controller API locally: `kubectl port-forward pinot-controller-0 9001:9000`
4. Open the controller landing page in your browser: http://localhost:9001/
5. Create a schema: `bin/pinot-admin.sh AddSchema -schemaFile sample_data/airlineStats_schema.json -exec -controllerHost 127.0.0.1 -controllerPort 9001`
6. Create a table: `bin/pinot-admin.sh AddTable -filePath sample_data/airlineStats_offline_table_config.json -exec -controllerHost 127.0.0.1 -controllerPort 9001`
7. Upload data (TODO)

Building Docker images
----------------------

```
docker login
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
- Kubernetes Pinot instances aren't configured with memory/CPU requirements so the deployment might overcommit resources
