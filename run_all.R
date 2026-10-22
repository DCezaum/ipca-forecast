# Roda o pipeline completo, da coleta às figuras. Execute a partir da raiz do repositório:
#   Rscript run_all.R
scripts <- c("R/01_coleta.R", "R/02_diagnostico.R", "R/03_walkforward.R", "R/04_prob_meta.R")
for (s in scripts) {
  message("\n== ", s, " ==")
  source(s, local = new.env())
}
