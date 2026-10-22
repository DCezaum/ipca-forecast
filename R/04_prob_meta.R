# Probabilidade de o IPCA ficar dentro da banda da meta, por simulação de Monte Carlo
source("R/00_utils.R")
library(forecast)
library(ggplot2)

set.seed(2026)
y <- carregar_ipca()
criar_pastas_saida()
n_sim <- 10000
h <- 12

fit <- auto.arima(y)
print(fit)

# Trajetórias futuras com resíduos reamostrados (sem impor normalidade): matriz h x n_sim
caminhos <- replicate(n_sim, as.numeric(simulate(fit, nsim = h, bootstrap = TRUE)))

# (a) IPCA acumulado nos próximos 12 meses
acum_12m <- apply(caminhos, 2, acumular)

# (b) IPCA do ano-calendário: meses já observados no ano + meses simulados até dezembro
ultimo_mes <- cycle(y)[length(y)]
k <- if (ultimo_mes == 12) 12 else 12 - ultimo_mes
observado <- if (k == 12) numeric(0) else tail(as.numeric(y), ultimo_mes)
acum_ano <- apply(caminhos[seq_len(k), , drop = FALSE], 2,
                  function(sim) acumular(c(observado, sim)))
ano_alvo <- floor(time(y)[length(y)]) + (k == 12)

resumo <- function(x, rotulo) data.frame(
  horizonte = rotulo,
  mediana = round(median(x), 2),
  p05 = round(quantile(x, 0.05), 2),
  p95 = round(quantile(x, 0.95), 2),
  prob_dentro_banda = round(mean(x >= BANDA[1] & x <= BANDA[2]), 3),
  prob_acima_teto = round(mean(x > BANDA[2]), 3)
)
tabela <- rbind(resumo(acum_12m, "Próximos 12 meses"),
                resumo(acum_ano, paste("Ano de", ano_alvo)))
rownames(tabela) <- NULL
readr::write_csv(tabela, "output/tables/probabilidade_meta.csv")
print(tabela)

g <- ggplot(data.frame(acum = acum_12m), aes(acum)) +
  annotate("rect", xmin = BANDA[1], xmax = BANDA[2], ymin = -Inf, ymax = Inf,
           alpha = 0.15, fill = "steelblue") +
  geom_histogram(bins = 60, fill = "grey30") +
  geom_vline(xintercept = META, linetype = "dashed", colour = "steelblue") +
  labs(title = "Distribuição simulada do IPCA acumulado nos próximos 12 meses",
       subtitle = sprintf("%s simulações; probabilidade dentro da banda: %.0f%%",
                          format(n_sim, big.mark = ".", decimal.mark = ","), 100 * tabela$prob_dentro_banda[1]),
       x = "IPCA acumulado (%)", y = "Simulações") +
  theme_minimal()
ggsave("output/figures/prob_meta.png", g, width = 8, height = 4.5, dpi = 200)
