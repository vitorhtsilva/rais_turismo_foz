# OBTENÇÃO DOS MICRODADOS RAIS 2020 (VÍNCULOS) PARA O SETOR TURÍSTICO DE FOZ DO IGUAÇU-PR
##Autor: Vitor Hugo Tavares da Silva

# Este script traz os procedimentos adotados para obtenção dos dados do emprego formal do setor turístico de Foz do Iguaçu - PR através da Relação Anual de Informações Sociais (RAIS) do ano de 2020. Os resultados foram apresentados na primeira seção do Trabalho de Conclusão de Curso intitulado "O Setor Turístico em Foz do Iguaçu-PR: mercado de trabalho e o projeto 'Trilha Jovem Iguassu'" (SILVA, 2022).

# 1) OBTENÇÃO DO DATA FRAME COM OS DADOS DO EMPREGO FORMAL DE FOZ DO IGUAÇU-PR

# Instalação dos pacotes utilizados:

library('bigrquery')
library('fastDummies')
library('dplyr')

# Os microdados dos vínculos relatados na RAIS foram obtidos a partir do data lake público organizado pela Base dos Dados. Nesta pesquisa, foi realizada uma consulta no Google BigQuery para obter a tabela com os dados de 2020 para Foz do Iguaçu - salva num projeto pessoal (mais informações no GitHub da Base dos Dados). De lá, os dados foram carregados no R através do pacote 'bigrquery'.

# A consulta SQL que deu origem à tabela foi:

### "SELECT \* FROM basedosdados.br_me_rais.microdados_vinculos WHERE id_municipio = '4108304' AND ano = 2020"

# Naturalmente, esta consulta pode ser personalizada para os mais diversos fins.

# Por fim, a tabela foi importada para o R:

projectid<-'raisturismofoz'
query<-("SELECT * FROM `raisturismofoz.microdadosvinculos2020.vinculos2020`")
tb <- bq_project_query(projectid, query)
df <- bq_table_download(tb)


# Como resultados, tem-se o dataframe 'df' com 90.863 observações, correspondente a todos os vínculos formais de Foz do Iguaçu em 2020.


# 2) PREPARAÇÃO DAS VARIÁVEIS DE INTERESSE:
# Gênero:
## Padronização:
### Masculino = 1; Feminino = 0
df$sexo[df$sexo==2]<-0

# Etnia:

# Cria uma variável dummy para cada valor de 'raca_cor':
df <- dummy_cols(df, select_columns = 'raca_cor')

# Cria uma variável do tipo 'string' para as etnias:
df$etnia <- NA
df$etnia[df$raca_cor_1 == 1] <- "INDIGENA"
df$etnia[df$raca_cor_2 == 1] <- "BRANCA"
df$etnia[df$raca_cor_6 == 1] <- "AMARELA"
df$etnia[df$raca_cor_9 == 1] <- "NÃO IDENTIFICADA"
df$etnia[df$raca_cor_8 == 1] <- "PARDA"
df$etnia[df$raca_cor_4 == 1] <- "PRETA"

# Faixa etária:
## Foram consideradas 3 faixas etárias: Jovem (menos de 30 anos), Adulto (de 30 a 64 anos) e Idoso (65 anos ou mais)
df$grupo_etario <- NA
df$grupo_etario[df$idade <30]<-"JOVEM"
df$grupo_etario[df$idade >29 & df$idade <65]<-"ADULTO"
df$grupo_etario[df$idade >64]<-"IDOSO"

# Rendimento médio por vínculo:

## Para cada vínculo (linha), soma os valores das variáveis que computam a remuneração mês a mês (colunas de índices 27 a 38)
df$total_remuneracao<-rowSums(df[,c(27:38)],na.rm=TRUE)

## Converte todos os meses onde remuneração = 0 (vínculo inativo) para NA
for(i in df[,27:38]){
  df[,27:38]<- na_if(df[,27:38],0)
}

## Soma os meses efetivamente trabalhados (onde o vínculo esteve ativo e a remuneração foi diferente de 'NA')
df$meses_trabalhados<-rowSums(!is.na(df[,c(27:38)]))
## Calcula a remuneração médio (total/meses trabalhados) para cada vínculo:
df$remuneracao_media<-df$total_remuneracao/df$meses_trabalhados

# 3) DEFININDO OS VÍNCULOS DO SETOR TURÍSTICO:

# Para classificação das chamadas Atividades Características do Turismo (ACTs), foi utilizada a padronização proposta por Gonçalves, Faria e Horta (2020), baseada nas subclasses CNAE 2.0. Mais informações sobre os procedimentos metodológicos deste trabalho em Silva (2022).

# Converte a variável com as subclasses CNAE 2.0 para numérico:
df$cnae_2_subclasse <- as.numeric(df$cnae_2_subclasse)

# Define uma dummy para identificar os vínculos com as atividades de Transporte:
df$turismo_transporte <- NA
df$turismo_transporte <- ifelse(df$cnae_2_subclasse== 4912401| df$cnae_2_subclasse==4922101| df$cnae_2_subclasse==4922102| df$cnae_2_subclasse==4922103| df$cnae_2_subclasse==4923001| df$cnae_2_subclasse==4929902| df$cnae_2_subclasse==4929904| df$cnae_2_subclasse==4950700| df$cnae_2_subclasse==5011402| df$cnae_2_subclasse==5012202| df$cnae_2_subclasse==5022002| df$cnae_2_subclasse==5091202| df$cnae_2_subclasse==5099801| df$cnae_2_subclasse==5111100| df$cnae_2_subclasse==5112901| df$cnae_2_subclasse==5112999| df$cnae_2_subclasse==5222200| df$cnae_2_subclasse==5229001| df$cnae_2_subclasse==5229099| df$cnae_2_subclasse==5240101| df$cnae_2_subclasse==5240199,1,0)

# Define uma dummy para identificar os vínculos com as atividades de Alojamento e Alimentação:
df$turismo_aloja_alim <- NA
df$turismo_aloja_alim <- ifelse(df$cnae_2_subclasse == 5510801| df$cnae_2_subclasse==5510802| df$cnae_2_subclasse==5590601| df$cnae_2_subclasse==5590602| df$cnae_2_subclasse==5590603| df$cnae_2_subclasse==5590699| df$cnae_2_subclasse==5611201| df$cnae_2_subclasse==5611202| df$cnae_2_subclasse==5611203| df$cnae_2_subclasse==5612100,1,0)

# Define uma dummy para identificar os vínculos com as atividades Complementares:
df$turismo_complement <- NA
df$turismo_complement <- ifelse(df$cnae_2_subclasse==7711000| df$cnae_2_subclasse==7721700| df$cnae_2_subclasse==7911200| df$cnae_2_subclasse==7912100| df$cnae_2_subclasse==7990200,1,0)

# Define uma dummy para identificar os vínculos com as atividades de Lazer:
df$turismo_lazer <- NA
df$turismo_lazer <- ifelse(df$cnae_2_subclasse == 9001901| df$cnae_2_subclasse==9001902| df$cnae_2_subclasse==9001903| df$cnae_2_subclasse==9001904| df$cnae_2_subclasse==9001905| df$cnae_2_subclasse==9001999| df$cnae_2_subclasse==9002701| df$cnae_2_subclasse==9102301| df$cnae_2_subclasse==9103100| df$cnae_2_subclasse==9200301| df$cnae_2_subclasse==9200302| df$cnae_2_subclasse==9200399| df$cnae_2_subclasse==9319199| df$cnae_2_subclasse==9321200| df$cnae_2_subclasse==9329801| df$cnae_2_subclasse==9329802| df$cnae_2_subclasse==9329803| df$cnae_2_subclasse==9329804| df$cnae_2_subclasse==9329899,1,0)

# Por fim, define uma dummy para identificar os vínculos de todo o setor turístico:
df$turismo <- NA
df$turismo <- ifelse(df$turismo_aloja_alim==1|df$turismo_complement==1|df$turismo_lazer==1|df$turismo_transporte==1,1,0)

# Criação do data frame do setor turístico - utilizado no TCC:
df_turismo <- subset(df,df$turismo==1)

write.csv(df_turismo,"C:/Users/vitor/Documents/UNILA/TCC_2022/rais_tcc/rais_turismo_foz/df_turismo_foz.csv")


# REFERÊNCIAS

## BASE DOS DADOS. Documentação BigQuery. 2022. Disponível em: https://basedosdados.github.io/mais/access_data_bq/#primeiros-passos. Acesso em: 15 abr. 2022.

## GONÇALVES, Caio César Soares; FARIA, Diomira Maria Cicci Pinto; HORTA, Tatiana de Almeida Pires. Metodologia para Mensuração das Atividades Características do Turismo. Revista Brasileira de Pesquisa em Turismo, [S.L.], v. 14, n. 3, p. 89-108, 1 set. 2020.ANPTUR - Associação Nacional de Pesquisa e Pós-Graduação em Turismo. http://dx.doi.org/10.7784/rbtur.v14i3.1908.

## SILVA, Vitor Hugo Tavares da. O Setor Turístico em Foz do Iguaçu-PR: mercado de trabalho e o projeto 'Trilha Jovem Iguassu'. 2022. 58 f. TCC (Graduação) - Curso de Ciências Econômicas, Universidade Federal da Integração Latino-americana, Foz do Iguaçu, 2022. Disponível em: https://dspace.unila.edu.br/handle/123456789/6679. Acesso em: 04 ago. 2022.