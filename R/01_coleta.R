# Coleta do IPCA mensal na API do SIDRA/IBGE (tabela 1737, variável 63)
library(jsonlite)
library(readr)

url <- "https://apisidra.ibge.gov.br/values/t/1737/n1/all/v/63/p/all?formato=json"
bruto <- fromJSON(url)[-1, ] # a primeira linha da resposta repete o cabeçalho

ipca <- data.frame(
  data = as.Date(paste0(bruto$D3C, "01"), format = "%Y%m%d"),
  ipca_mensal = suppressWarnings(as.numeric(bruto$V)) # meses sem dado vêm como texto e viram NA
)

# Amostra a partir de 2000: regime de metas de inflação já consolidado
ipca <- ipca[ipca$data >= as.Date("2000-01-01"), ]

dir.create("data", showWarnings = FALSE)
write_csv(ipca, "data/ipca_mensal.csv")
message("IPCA salvo: ", nrow(ipca), " meses, até ", format(max(ipca$data), "%m/%Y"))
