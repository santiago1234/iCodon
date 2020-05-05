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


# compare with the csc ----------------------------------------------------

csc_scores <- read_csv("https://elifesciences.org/download/aHR0cHM6Ly9jZG4uZWxpZmVzY2llbmNlcy5vcmcvYXJ0aWNsZXMvNDUzOTYvZWxpZmUtNDUzOTYtZmlnMS1kYXRhMi12Mi5jc3Y=/elife-45396-fig1-data2-v2.csv?_hash=nbm%2BWR4OoqoKYxyrjy3d3MXcEN9Etr0iBEb1OoLnRes%3D")

csc_scores <- csc_scores %>%
  select(codon:K562_SLAM) %>%
  select(-contains('ORFome')) %>%
  gather(key = profile, value = csc, -codon, -Name) %>%
  group_by(codon, Name) %>%
  summarise(CSC = median(csc))


csc_scores <-
  usage %>%
  filter(specie == "human") %>%
  inner_join(csc_scores)

csc_scores %>%
  ggplot(aes(x=usage, y=CSC)) +
  geom_point() +
  ggrepel::geom_text_repel(aes(label=codon)) +
  scale_x_log10() +
  ggpubr::stat_cor()

csc_scores %>%
  filter(Name %in% c("Arg", "Thr")) %>%
  ggplot(aes(x=CSC, y=usage)) +
  geom_point(shape = 16, size = 2, alpha =  .99, color = "steelblue") +
  geom_text_repel(aes(label = codon), size=3, color = 'grey30') +
  scale_x_continuous(breaks = c(-.1, 0, .1)) +
  scale_y_continuous(labels = scales::percent) +
  facet_wrap(~Name) +
  geom_rangeframe(size=1/4) +
  ggpubr::stat_cor(method = 'spearman', size = 3, color = "grey20") +
  labs(
    x = "Codon Stabilization Coefficient",
    y = "Codon usage"
  )
ggsave("usageVScsc.pdf", height = 2, width = 4)

