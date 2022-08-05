# rais_turismo_foz
#### Autor: Vitor Hugo Tavares da Silva
#### LinkedIn: https://www.linkedin.com/in/vitor-tavares-da-silva-186874186
#### Currículo Lattes: http://lattes.cnpq.br/2401105263246819

A criação deste repositório tem como finalidade disponibilizar publicamente a base de dados utilizada na primeira seção do Trabalho de Conclusão de Curso intitulado "O Setor Turístico em Foz do Iguaçu-PR: mercado de trabalho e o projeto 'Trilha Jovem Iguassu'" (o trabalho está disponível no link: https://dspace.unila.edu.br/handle/123456789/6679). Estes dados, públicos e disponibilizados originalmente pelo IBGE através dos microdados dos vínculos informados na Relação Anual de Informações Sociais (RAIS), foram obtidos através do data lake público mantido pela organização Base dos Dados (https://basedosdados.org/). 

Primeiramente, foi realizada uma consulta em Google BigQuery para acessar uma tabela com os dados relativos ao ano de 2020 para a cidade de Foz do Iguaçu-PR. Posteriormente, esta tabela foi acessada via linguagem R (usando o software RStudio) e manipulada para identificar os vínculos relacionados ao setor turístico. Mais detalhes podem ser consultados no mencionado trabalho e, naturalmente, no script disponibilizado neste mesmo diretório - 'coleta_dados.R'.

Por fim, o arquivo 'df_turismo_foz.csv' traz o dataframe resultante, com os aproximadamente 19 mil vínculos formais do setor turístico iguaçuense relatados no ano de 2020.

