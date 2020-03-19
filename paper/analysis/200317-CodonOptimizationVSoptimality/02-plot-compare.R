library(tidyverse)
library(ggrepel)
library(ggthemes)

theme_set(theme_tufte(base_family = "Helvetica"))

optimality <- read_csv("results_data/optimality_lasso.csv")
usage <- read_csv("results_data/codon_usage.csv") 

datos <- inner_join(optimality, usage) %>% 
  filter(!codon %in% c("TAG", "TAA", "TGA"))

datos %>% 
  mutate(specie = factor(specie, levels = c("fish", "xenopus", "mouse", "human"))) %>% 
  ggplot(aes(x=lasso_coef, y=usage)) +
  geom_point(color="grey") +
  scale_y_log10() +
  geom_text_repel(aes(label=codon), size=1.5, color="grey20") +
  facet_wrap(~specie, scales = "free_x") +
  geom_rangeframe() +
  geom_smooth(method = "lm", linetype=2, color="black", size=1/10, se = F) +
  ggpubr::stat_cor()
ggsave("optimalityVSusage.pdf", height = 6, width = 6)
