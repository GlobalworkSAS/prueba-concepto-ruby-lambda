# Prueba de concepto AWS Lambda Ruby Selenium

Este proyecto contiene el código necesario para levantar una lambda de AWS en una máquina de AL2 con el tag de ruby 2.7 (Versión de ruby oficial soportada por AL2 en 2022)

El proyecto contiene un `Dockerfile` que sirve para levantar en local una instancia de AL2 junto con el repo de Google Chrome. Este tiene instrucciones para instalar la última versión del navegador, necesariro para emularlo.

Luego se debe incluir el `chromedriver`, actualmente uso la versión 102, así que esto se deberá ajustar conforme la versión del binario de Chrome sea actualizada.

# Instalación
1. Correr `make build`

# Ejecución

1. En una terminal correr `make run`
2. En otra terminal correr `make test`

Estos comandos se probaron en una mac con procesador Intel. En un procesador M1 se deben ajustar los comandos, #TODO: Colocar aqui esos comandos.

# Despliegue

## Setear el perfil de aws cli de Globalwork!!!
`export AWS_PROFILE=globalw` ó Correr el comando `aws configure` 

## Si es la primera vez:

### Crear el repositorio
aws ecr create-repository --repository-name prueba --image-scanning-configuration scanOnPush=true --image-tag-mutability MUTABLE

### Loguearse - En el paso anterior salió una URL, reemplazarla en el param --pasword-stdin
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin XXX.dkr.ecr.us-east-1.amazonaws.com/prueba

### Taguear la versión (Cada vez que se haga un cambio en el código)
docker tag prueba:latest XXX.dkr.ecr.us-east-1.amazonaws.com/prueba:latest

### Push. Cada vez
docker push XXX.dkr.ecr.us-east-1.amazonaws.com/prueba:latest

### Asignar una nueva imagen al lambda
Hay que ir al dashboard de Amazon, crear una lambda (O ir a la que ya esté creada) e indicarle que use la nueva versión de la imagen de Docker que subimos en el paso anterior

#### Para crearla:
- Ir al dashboard de Lambda
- Click en crear nueva función
- Escoger la opción Container Image
- Llenar el formulario y escoger la imagen de Docker creada en el paso anterior
- Configurar para que dure 15 minutos (Máximo permitido)
- Agregar memoria (Por defecto viene en 128MB, hay que ir probando, yo lo probé con 1024MB)


## Para actualizar la función
Correr el comando `make deploy`

### TODO: Automatizar esto
- Ir a la función de Lambda
- Click en 'Deploy new Image'
- Seleccionar la imagen con el tag 'latest'
- Esperar que actualice y probar