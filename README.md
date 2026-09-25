<div align="center">

# DER — Sistema de Gestão Comercial

<img src="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=500&size=20&duration=2800&pause=900&color=36BCF7&center=true&vCenter=true&width=720&lines=Modelo+de+Banco+de+Dados;Moda+Automotiva+%26+Streetwear;Compras+%7C+Vendas+%7C+Estoque+%7C+Financeiro" alt="Animação com a descrição do projeto" /> <p>
<strong>Modelagem de banco de dados para organizar os processos de uma empresa de moda automotiva e streetwear.</strong>
</p> <p>
  <img src="https://img.shields.io/badge/Projeto-Em%20desenvolvimento-orange?style=for-the-badge" alt="Status: em desenvolvimento" />
  <img src="https://img.shields.io/badge/Modelagem-DER-36BCF7?style=for-the-badge" alt="Modelagem DER" />
  <img src="https://img.shields.io/badge/Documenta%C3%A7%C3%A3o-GitHub-181717?style=for-the-badge&logo=github" alt="Documentação no GitHub" />
</p>

<a href="DER/der.png"><strong>Visualizar o diagrama</strong></a>
  ·  
<a href="DER/der.mmd"><strong>Ver código Mermaid</strong></a>

</div>

---

<div align="center">

## Sobre o projeto

</div>

Este projeto nasceu da análise das necessidades e dos desafios de uma empresa do segmento de **moda automotiva e streetwear**. A partir de uma entrevista e do levantamento de requisitos, foram identificadas as principais entidades, ocorrências e relações envolvidas nos processos comerciais.

O resultado é um modelo de banco de dados que organiza informações de compras, vendas, produtos, estoque e contas a pagar.

<div align="center">

## Objetivo

</div>

Representar, por meio de um **Diagrama Entidade-Relacionamento (DER )**, a estrutura de dados necessária para apoiar as operações da empresa e mostrar como as informações se relacionam.

### Processos contemplados

<div align="center">

`Fornecedores`   `Compras`   `Produtos`   `Estoque`   `Vendas`
`Clientes`   `Canais de venda`   `Eventos`   `Contas a pagar`

</div> <div align="center">

## Diagrama Entidade-Relacionamento

<img src="DER/der.png" alt="Diagrama Entidade-Relacionamento do sistema" width="100%" /> </div> <div align="center">

## Entidades do modelo

</div>

| Entidade | Descrição |
| --- | --- |
| `FORNECEDOR` | Armazena os dados dos fornecedores. |
| `COMPRA` | Registra as compras realizadas pela empresa. |
| `ITEM_COMPRA` | Registra os produtos presentes em cada compra. |
| `PRODUTO` | Armazena os produtos comercializados. |
| `ESTOQUE` | Controla a quantidade disponível de cada produto. |
| `MOVIMENTACAO_ESTOQUE` | Registra entradas, saídas e ajustes no estoque. |
| `CLIENTE` | Armazena os dados dos clientes. |
| `CANAL_VENDA` | Identifica o canal utilizado em cada venda. |
| `VENDA_SITE` | Registra informações relacionadas às vendas realizadas pelo site. |
| `EVENTO` | Armazena eventos relacionados às vendas. |
| `VENDA` | Registra as vendas realizadas. |
| `ITEM_VENDA` | Registra os produtos presentes em cada venda. |
| `CONTA_PAGAR` | Controla os pagamentos devidos aos fornecedores. |

<div align="center">

## Como as entidades se relacionam

</div>

- Um fornecedor pode realizar várias compras.

- Uma compra pode possuir vários itens, e cada item corresponde a um produto.

- Um cliente pode realizar várias vendas.

- Uma venda pode possuir vários itens, e um produto pode aparecer em várias vendas.

- Cada produto possui controle de estoque e pode ter várias movimentações registradas.

- Um canal de venda pode originar várias vendas.

- Um evento pode estar relacionado a várias vendas.

- Uma compra pode gerar uma ou mais contas a pagar.

<div align="center">

## Fluxos principais

</div>

### Processo de compra

1. O fornecedor é cadastrado.

1. A compra é registrada e recebe seus itens.

1. O estoque é atualizado com os produtos comprados.

1. Uma ou mais contas a pagar podem ser associadas à compra.

### Processo de venda

1. O cliente e o canal de venda são identificados.

1. A venda é registrada com seus itens.

1. O estoque é reduzido.

1. Uma movimentação de saída é registrada.

<div align="center">

## Estrutura dos arquivos

</div>

```
.
├── DER/
│   ├── der.mmd    # Código Mermaid do diagrama
│   └── der.png    # Imagem do diagrama
└── README.md      # Documentação do projeto
```

<div align="center">

## Tecnologias e conceitos

`Banco de dados`   `Modelo relacional`   `DER`   `Normalização`
`Chaves primárias e estrangeiras`   `Mermaid`   `Git`   `GitHub`

## Como visualizar o diagrama

O diagrama está disponível nesta página e também no arquivo [`DER/der.png`](DER/der.png). O código-fonte em Mermaid pode ser encontrado em [`DER/der.mmd`](DER/der.mmd) e aberto no [Mermaid Live Editor](https://mermaid.live/).

## Status

**Em desenvolvimento**

## Autor

Desenvolvido por [Larycronx](https://github.com/Larycronx).

---

<sub>README do projeto DER — Sistema de Gestão Comercial.</sub>

</div> <!-- A animação do cabeçalho é fornecida pelo readme-typing-svg. --> <!-- Se o serviço externo ficar indisponível, o restante do README continuará funcionando normalmente. -->
