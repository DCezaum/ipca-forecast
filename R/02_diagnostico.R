# Diagnóstico da série: decomposição sazonal STL e testes de raiz unitária
source("R/00_utils.R")
library(tseries)
library(ggplot2)

y <- carregar_ipca()
criar_pastas_saida()

# Decomposição STL (sazonalidade fixa ao longo da amostra)
png("output/figures/stl.png", width = 1600, height = 1200, res = 200)
plot(stl(y, s.window = "periodic"), main = "IPCA mensal (%): decomposição STL")
dev.off()

# ADF e KPSS têm hipóteses nulas opostas; usar os dois evita conclusões frágeis
adf <- adf.test(y)
kpss <- kpss.test(y)
testes <- data.frame(
  teste = c("ADF (H0: raiz unitária)", "KPSS (H0: estacionária em nível)"),
  estatistica = round(c(adf$statistic, kpss$statistic), 3),
  p_valor = round(c(adf$p.value, kpss$p.value), 3)
)
readr::write_csv(testes, "output/tables/testes_raiz_unitaria.csv")
print(testes)

# IPCA acumulado em 12 meses com a banda atual da meta
d12 <- data.frame(data = as.Date(paste(floor(time(y)), cycle(y), 1, sep = "-")),
                  acum12 = as.numeric(acum12(y)))
g <- ggplot(na.omit(d12), aes(data, acum12)) +
  annotate("rect", xmin = -Inf, xmax = Inf, ymin = BANDA[1], ymax = BANDA[2],
           alpha = 0.15, fill = "steelblue") +
  geom_hline(yintercept = META, linetype = "dashed", colour = "steelblue") +
  geom_line(linewidth = 0.6) +
  labs(title = "IPCA acumulado em 12 meses",
       subtitle = "Faixa azul: banda da meta contínua vigente desde 2025 (3% ± 1,5 p.p.)",
       x = NULL, y = "%", caption = "Fonte: SIDRA/IBGE") +
  theme_minimal()
ggsave("output/figures/ipca_12m.png", g, width = 8, height = 4.5, dpi = 200)
