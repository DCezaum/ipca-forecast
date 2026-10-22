# Funções compartilhadas entre os scripts

# Lê o CSV salvo por 01_coleta.R e devolve o IPCA mensal (%) como série ts
carregar_ipca <- function(caminho = "data/ipca_mensal.csv") {
  d <- readr::read_csv(caminho, show_col_types = FALSE)
  inicio <- as.numeric(format(min(d$data), c("%Y", "%m")))
  ts(d$ipca_mensal, start = inicio, frequency = 12)
}

# Acumula variações mensais (%) em uma variação total (%)
acumular <- function(x) 100 * (prod(1 + x / 100) - 1)

# IPCA acumulado em 12 meses (%) para cada mês da série
acum12 <- function(y) {
  out <- stats::filter(log1p(y / 100), rep(1, 12), sides = 1)
  100 * (exp(out) - 1)
}

# Banda da meta contínua de inflação (CMN, vigente desde 2025): 3% ± 1,5 p.p.
META <- 3
BANDA <- c(inferior = 1.5, superior = 4.5)

criar_pastas_saida <- function() {
  dir.create("output/figures", recursive = TRUE, showWarnings = FALSE)
  dir.create("output/tables", recursive = TRUE, showWarnings = FALSE)
}
