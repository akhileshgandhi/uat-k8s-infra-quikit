superuser :- postgres  , password:-  g4illuqDtkkCqh6zf9wcjctUS3ciqyMHM4GgNs2oDqVThC67FGFiShn5veIMe7WL

superuser :-  quikit    , password:- Quikit123!

host name :-  pg18-cluster-rw.db.svc.cluster.local


redis host name : redis-0.redis-headless.db.svc.cluster.local , redis-0.redis-headless.db.svc


update the signoz :-  helm upgrade my-release signoz/k8s-infra  -n default  -f .\observability\signoz-values.yaml

192.168.1.100


 kubectl create configmap dex-config --from-file=config.yaml -n quikit

 if error: You must be logged in to the server (Unauthorized)
  kubectl oidc-login clean


 helm setup:- 
 


 helm repo add argo https://argoproj.github.io/argo-helm

helm repo update

helm install argocd argo/argo-cd  --namespace argocd

[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String((kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}")))

MFL1wlQ8PManRnU4


BAO_TOKEN=s.1wIlhzLhjFPPa6a3fcmEELWx




 kubectl port-forward -n openbao pod/openbao-0 8200:8200

open bao url - http://127.0.0.1:8200/


https://uatargocd.moreyeahs.in/


git stash
git pull
git stash pop



postgress url http://192.168.1.100:32080/browser/



get alias
PowerShell command


New-Item -ItemType File -Path $PROFILE -Force
notepad $PROFILE
. $PROFILE


 kubectl exec -n db pg18-cluster-1 -- pg_dump -U postgres -d quikit -F c > .\quikit-full.dump


 CREATE USER dev WITH PASSWORD 'quikit';



test job :---------------  
kubectl delete job hrms-recruit-test -n quikit  

kubectl create job --from=cronjob/hrms-recruit-daily-report hrms-recruit-test -n quikit


unseal command
kubectl exec -it -n openbao openbao-0 -- bao operator unseal