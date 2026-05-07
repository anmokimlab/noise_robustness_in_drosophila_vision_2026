# ============================================================
# 3D ResNet - HMDB Dataset Noise Robustness Analysis
# Resolution: 320x240 | Movement Patterns
# ============================================================

# ---- 0. Install & Load Libraries ----
install.packages("rjson")
install.packages("tidyverse")
install.packages("moonBook")
install.packages("nord")

library(moonBook)
library(rjson)
library(tidyverse)
library(dplyr)
library(directlabels)
library(nord)
library(gridExtra)


# ---- 1. Load JSON Results ----
# Set working directory to the target results folder
# (Uncomment the path that matches your experiment setting)

# Without noise (baseline)
# setwd("/Volumes/nisl/soobin/1.3DResnet/2.RESULTS(onon)/5.HMDB_RESOLUTION(320x240)_movement/NOISE_W.O.TRAIN/results2(default)")

# With Gaussian noise training (SNR 10)
# setwd("/Volumes/nisl/soobin/1.3DResnet/2.RESULTS(onon)/5.HMDB_RESOLUTION(320x240)_movement/NOISE_W.G.N.TRAIN/NOISE_10/results2")

# With Gaussian noise training (SNR 40)
setwd("/Volumes/nisl/soobin/1.3DResnet/2.RESULTS(onon)/5.HMDB_RESOLUTION(320x240)_movement/NOISE_W.G.N.TRAIN/NOISE_40/results1")

val_json     <- fromJSON(file = "val.json")
val_json_df  <- as.data.frame(val_json)


# ---- 2. Parse JSON into a Structured Data Frame ----
# Extracts ground truth label, noise percentage, predicted label, and prediction score
# from each entry in the JSON result file.
# Each sample occupies 'topk * 2' columns (label + score, repeated for top-k predictions).

table_func <- function(JSONfile, topk_num) {

  label        <- c()
  ground_truth <- c()
  score        <- c()
  noise_pct    <- c()
  topk         <- 8
  len          <- length(attributes(val_json_df)$name)

  for (i in seq(1, len, topk * 2)) {
    tmp <- strsplit(str_sub(attributes(val_json_df)$name[i], 9, -7), split = "_")

    if (sum(tmp[[1]] %in% c("noise", "noisev2")) >= 1) {
      # Sample with noise: extract pattern name and noise percentage
      ground_truth <- c(ground_truth, paste(tmp[[1]][1], tmp[[1]][2], sep = "_"))
      noise_pct    <- c(noise_pct, gsub("\\D", "", str_sub(attributes(val_json_df)$name[i], -9, -1)))
      label        <- c(label, val_json_df[attributes(val_json_df)$name[[i]]][[1]])
      score        <- c(score, val_json_df[attributes(val_json_df)$name[i + 1]][[1]])

    } else {
      # Clean sample (no noise): assign noise percentage as "0"
      ground_truth <- c(ground_truth, paste(tmp[[1]][1], tmp[[1]][2], sep = "_"))
      noise_pct    <- c(noise_pct, "0")
      label        <- c(label, val_json_df[attributes(val_json_df)$name[[i]]][[1]])
      score        <- c(score, val_json_df[attributes(val_json_df)$name[i + 1]][[1]])
    }
  }

  Scores <- data.frame(ground_truth, noise_pct, label, score)
  return(Scores)
}

Scores <- table_func(val_json_df, 8)
write.csv(Scores, file = "Scores.csv", quote = FALSE)


# ---- 3. Compute Accuracy per Pattern and Noise Level ----

# Total number of samples per (pattern, noise) group
t2 <- Scores %>%
  group_by(ground_truth, noise_pct) %>%
  summarise(len = n(), .groups = "keep")

# Correct predictions only: compute average score and hit count
t1 <- Scores %>%
  group_by(ground_truth, label, noise_pct) %>%
  filter(ground_truth == label) %>%
  summarise(avg = mean(score), hit_num = n(), .groups = "keep")

# Number of samples per class (used for accuracy denominator)
l <- 180

FINAL_dt <- t1 %>%
  group_by(ground_truth, label, noise_pct, hit_num) %>%
  summarise(acc = hit_num / l * 100, .groups = "keep")

write.csv(FINAL_dt, file = "final.csv", quote = FALSE)


# ---- 4. Fill Missing Entries with Zero Accuracy ----
# If a pattern was never correctly classified at a given noise level,
# no row exists in t1. This block fills those missing cases with acc = 0.

patterns <- unique(Scores$ground_truth)

for (i in patterns) {
  tmp <- FINAL_dt %>% filter(ground_truth == i)

  if (nrow(tmp) < 8) {
    add_r        <- 8 - nrow(tmp)
    ground_truth <- rep(i, add_r)
    label        <- rep(i, add_r)
    noise_pct    <- as.character(tail(seq(0, 70, 10), add_r))
    acc          <- rep(0, add_r)
    avg          <- rep(0, add_r)
    t            <- tibble(ground_truth, label, noise_pct, avg, acc)
    assign(paste0(i, "_acc"), bind_rows(tmp, t))
  } else {
    assign(paste0(i, "_acc"), tmp)
  }
}

ACC_RESULT <- bind_rows(
  bar_R_acc, bar_L_acc,
  looming_R_acc, looming_L_acc,
  grating_R_acc, grating_L_acc,
  spotup_R_acc, spotup_L_acc
)

write.csv(ACC_RESULT, "acc_lowres.csv")


# ---- 5. Plot Accuracy by Direction (Left vs Right) ----
# Prepare and order subsets for each pattern type

prepare_dt <- function(data, pattern_names) {
  dt <- data %>% filter(ground_truth %in% pattern_names)
  dt$noise_pct <- as.integer(dt$noise_pct)
  dt <- dt[order(dt$noise_pct), ]
  dt <- dt[1:16, ]
  return(dt)
}

dt_bar     <- prepare_dt(ACC_RESULT, c("bar_L",     "bar_R"))
dt_grating <- prepare_dt(ACC_RESULT, c("grating_L", "grating_R"))
dt_looming <- prepare_dt(ACC_RESULT, c("looming_L", "looming_R"))
dt_spotup  <- prepare_dt(ACC_RESULT, c("spotup_L",  "spotup_R"))

# Bar pattern
g_bar <- ggplot(data = dt_bar, aes(x = noise_pct, y = acc, color = ground_truth)) +
  geom_line(aes(group = ground_truth)) +
  geom_point(size = 2) +
  ggtitle("Bar: Left vs Right") +
  xlab("Noise (%)") + ylab("Accuracy (%)") +
  theme_classic() +
  scale_x_continuous(breaks = seq(0, 70, 10)) +
  scale_y_continuous(limits = c(0, 100))

# Looming pattern
g_looming <- ggplot(data = dt_looming, aes(x = noise_pct, y = acc, color = ground_truth)) +
  geom_line(aes(group = ground_truth)) +
  geom_point(size = 2) +
  ggtitle("Looming: Left vs Right") +
  xlab("Noise (%)") + ylab("Accuracy (%)") +
  theme_classic() +
  scale_x_continuous(breaks = seq(0, 70, 10)) +
  scale_y_continuous(limits = c(0, 100))

# Spot-up pattern
g_spotup <- ggplot(data = dt_spotup, aes(x = noise_pct, y = acc, color = ground_truth)) +
  geom_line(aes(group = ground_truth)) +
  geom_point(size = 2) +
  ggtitle("Spot-up: Left vs Right") +
  xlab("Noise (%)") + ylab("Accuracy (%)") +
  theme_classic() +
  scale_x_continuous(breaks = seq(0, 70, 10)) +
  scale_y_continuous(limits = c(0, 100))

# Grating pattern
g_grating <- ggplot(data = dt_grating, aes(x = noise_pct, y = acc, color = ground_truth)) +
  geom_line(aes(group = ground_truth)) +
  geom_point(size = 2) +
  ggtitle("Grating: Left vs Right") +
  xlab("Noise (%)") + ylab("Accuracy (%)") +
  theme_classic() +
  scale_x_continuous(breaks = seq(0, 70, 10)) +
  scale_y_continuous(limits = c(0, 100))

# Combined 2x2 plot
grid.arrange(g_bar, g_grating, g_looming, g_spotup, nrow = 2)


# ---- 6. Plot Mean Accuracy (Directions Averaged) ----
# Merge left/right directions into a single mean accuracy per pattern

merge_directions <- function(data, pattern_names, new_name) {
  dt  <- data %>% filter(ground_truth %in% pattern_names)
  n   <- dim(dt)[1]
  dt$ground_truth <- rep(new_name, n)
  dt  <- dt %>% group_by(noise_pct) %>% summarise(acc = mean(acc))
  dt$ground_truth <- rep(new_name, n / 2)
  return(dt)
}

dt_bar     <- merge_directions(ACC_RESULT, c("bar_L",     "bar_R"),     "bar")
dt_grating <- merge_directions(ACC_RESULT, c("grating_L", "grating_R"), "grating")
dt_looming <- merge_directions(ACC_RESULT, c("looming_L", "looming_R"), "looming")
dt_spotup  <- merge_directions(ACC_RESULT, c("spotup_L",  "spotup_R"),  "spotup")

dt_combined           <- rbind(dt_bar, dt_grating, dt_looming, dt_spotup)
dt_combined$noise_pct <- as.integer(dt_combined$noise_pct)
dt_combined           <- dt_combined[order(dt_combined$noise_pct), ]

ggplot(data = dt_combined[1:32, ], aes(x = noise_pct, y = acc, group = ground_truth)) +
  geom_line(aes(colour = ground_truth), size = 1) +
  theme_classic() +
  xlab("Noise (%)") +
  ylab("Accuracy (%)") +
  ggtitle("Mean Accuracy of Each Pattern by Noise Level") +
  theme(plot.title = element_text(hjust = 0.5, size = 15, face = "bold")) +
  scale_y_continuous(limits = c(0, 100)) +
  scale_x_continuous(breaks = seq(0, 70, 10))
