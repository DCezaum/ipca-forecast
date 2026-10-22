# Validação out-of-sample por walk-forward (janela expansiva, origens mensais desde 2015)
source("R/00_utils.R")
library(forecast)
library(ggplot2)

y <- carregar_ipca()
criar_pastas_saida()
h <- 12

modelos <- list(
  `Ingênuo sazonal` = function(x, h) snaive(x, h = h),
  `ARIMA (auto)`    = function(x, h) forecast(auto.arima(x), h = h),
  `STL + ARIMA`     = function(x, h) stlf(x, h = h, method = "arima")
)

# Cada origem estima o modelo só com os dados disponíveis até aquele mês
inicial <- which(time(y) >= 2015)[1] - 1
erros <- lapply(modelos, function(f) tsCV(y, f, h = h, initial = inicial))

rmse <- sapply(erros, function(e) sqrt(colMeans(e^2, na.rm = TRUE)))
tabela <- data.frame(horizonte = seq_len(h), round(rmse, 3), check.names = FALSE)
readr::write_csv(tabela, "output/tables/rmse_por_horizonte.csv")
print(tabela)

d <- tidyr::pivot_longer(tabela, -horizonte, names_to = "modelo", values_to = "rmse")
g <- ggplot(d, aes(horizonte, rmse, colour = modelo)) +
  geom_line(linewidth = 0.7) +
  geom_point() +
  scale_x_continuous(breaks = seq_len(h)) +
  labs(title = "Erro de projeção fora da amostra do IPCA mensal",
       subtitle = "RMSE por horizonte, walk-forward com origens de 2015 em diante",
       x = "Horizonte (meses)", y = "RMSE (p.p.)", colour = NULL) +
  theme_minimal() +
  theme(legend.position = "bottom")
ggsave("output/figures/rmse_walkforward.png", g, width = 8, height = 4.5, dpi = 200)
