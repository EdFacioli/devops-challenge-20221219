# DevOps Challenge 

> O desafio pode ser acessado aqui: [DevOps Challenge](https://lab.coodesh.com/edsonfacioli/devops-challenge-20221219)

Este projeto realiza o build do projeto calculator em um bucket s3 utilizando terraform e github actions

## Configurações Iniciais

1. Primeiro de tudo para rodar este projeto você deve criar um bucket s3 que será utilizado para guardar o state do terraform, isso permite que mais de uma pessoa trabalhe no projeto;
2. Configurar o bucket criado no arquivo **setup.tf**; Esse bucket deve ser setado em:

```json
  backend "s3" {
    bucket = "bucket-que-você-criou"
    key    = "terraform/terraform.tfstate"
    region = "us-east-2"
  }
```

> Observação: não é necessário colocar a url *s3://....* apenas o nome do bucket

Após esses passos você está apto a rodar o projeto;

## Executando na sua máquina

Utilize a versão do terraform maior que igual a 1.x

Execute ***terraform init***, ele automaticamente irá ativar backend remoto no bucket que você configurou

Após o ***terraform init***, rode, ***terraform workspace new production***, para criar um workspace para o ambiente de produção, caso queira para staging faça o mesmo processo mudando apenas de production para staging;

Para executar ***terraform plan*** passe o parametro *-var-file=terraform.production.tfvars* ou *-var-file=terraform.staging.tfvars* de acordo com o ambiente que deseje executar.

> nota: crie um terraform.$environment.tfvars para cada environment que deseje usar no projeto, onde $environment é o ambiente que deseja criar os resources, exemplo: production, staging, develop, etc.

Estando tudo de acordo rode ***terraform apply*** usando o parametro, novamente, *-var-file=* indicando o arquivo de variáveis a ser utilizado;

## Processo de desenvolvimento do projeto - Localmente

Foi pedido que fosse adicionado o projeto [Calculadora](https://github.com/ahfarmer/calculator) como um  **Git Submodule**. Para esse processo utilizei o comando:

```bash
git submodule add git@github.com:ahfarmer/calculator.git calculator
git submodule init
```

No projeto da Calculadora entrei no diretório adicionado, executei as etapas de instalação das dependencias e construção. Rodei com ajuda do python3 um server dentro da pasta build, gerada, e acessei via navegador. Para surpresa o projeto simplesmente apresentava uma página com o escrito *fork me on Github* e só. Abri o inspecionar, do firefox, e na aba networking observei que os elementos, arquivos js e css não estavam sendo carregados, retornando **404**. Observei que havia na url um path *'calculator/'* e esse path não existia na pasta build, então fui para a documentação do **create react app**. Lá encontrei o seguinte [building for relative paths](https://create-react-app.dev/docs/deployment#building-for-relative-paths) e o olhando o arquivo package.json notei que ele possui a chave **"homepage"** e nela há o path calculator. Para fins de teste removi essa chave, gerei o build local e a aplicação funcionou.

Rodei o terraform, criei o bucket, e após isso sincronizei o conteúdo de build no bucket, e funcionou.

## Processo de desenvolvimento do projeto - Github Actions

Adicionei o diretório .github/workflows ao projeto, esse passo é necessário para utilizar o **Github Actions**. Utilizei o método de [workflows reusing](https://docs.github.com/en/actions/using-workflows/reusing-workflows). O arquivo *main.yml* dispara toda vez que há um evento de push, ele chama o *workflow.yml* que é um workflow reutilizavel. *main.yml* seta para dois ambientes, staging e production.

1. Primeiro job: **build** - nesse job é realizada a contrução do aplicativo, nesse job salvo o artifact do build gerado, nesse job precisei remover por meio de sed a chave *"homepage"* para que construisse sem o path *"calculator/"*
2. Segundo job: **bucket** - aqui é criado o bucket s3
3. Terceiro job: **deploy** - no job é feito uso do artifact gerado no primeiro job, build, e sincronizado com o bucket criado no job bucket;
