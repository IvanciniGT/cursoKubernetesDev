# Para hablar con el cluster de kubernetes usamos el cliente de linea de comandos KUBECTL

kubectl [verbo] [TIPO DE OBJETO] <argumentos>

## ARGUMENTOS
-n --namespace              Me permite asignar un namespace de trabajo
--all-namespaces

-o wide (Usamos en el verbo GET)    Ofrece informacion adicional

## TIPOS DE OBJETOS:
                                ALIAS
- namespace                     namespaces ns
- pod                           pods
- deployment                    deployments
- statefulset
- daemonset 
- service                       services svc
- ingress
- node
- configMap
- secret
- persistentvolume              pv
- perstistenvolumeclaim         pvc
- job
- cronjob

## VERBOS

- get
- describe
- create
- delete
- logs
- exec

En general, este comando le usamos SOLO para consultar objetos, al menos con esas sintaxis

Para crear / modificar OBJETOS / CONFIGURACION, usamos:

kubectl create -f   ARCHIVO_METADATOS_KUBERNETES.yaml       CREAR CONFIGURACIONES
kubectl apply -f    ARCHIVO_METADATOS_KUBERNETES.yaml       CREAR o MODIFICAR CONFIGURACIONES
kubectl delete -f   ARCHIVO_METADATOS_KUBERNETES.yaml       BORRAR CONFIGURACIONES