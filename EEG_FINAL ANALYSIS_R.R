install.packages("tidyverse") 
install.packages("gsignal")
install.packages("patchwork")

library(tidyverse)
library(gsignal)

eeg_raw <- read.csv("train.csv")

head(eeg_raw)
fs <- 128

plot(eeg_raw$AF3[1:256], type = "l", col = "darkgreen",
     main = "Raw EEG Signal (Channel AF3)",
     xlab = "Time Points", ylab = "Voltage (uV)")
comparison <- eeg_raw %>%
  group_by(target) %>%
  summarise(Average_Voltage = mean(AF3))


print(comparison)
my_filter <- butter(3, 0.5 / (fs / 2), type = "high")

eeg_raw$AF3_clean <- filter(my_filter, eeg_raw$AF3)

plot(eeg_raw$AF3_clean[1:256], type = "l", col = "red",
     main = "Filtered EEG (Drift Removed)",
     xlab = "Time Points", ylab = "Voltage")

psd_0 <- pwelch(eeg_raw$AF3_clean[eeg_raw$target == 0], fs = fs)

psd_1 <- pwelch(eeg_raw$AF3_clean[eeg_raw$target == 1], fs = fs)

# 10*log10 for dB scale; easier to see peaks
plot(psd_0$freq, 10*log10(psd_0$spec), type = "l", col = "blue", 
     xlim = c(0, 40), ylim = c(10, 60),
     main = "Brainwave Frequency Comparison",
     xlab = "Frequency (Hz)", ylab = "Power (dB)")

lines(psd_1$freq, 10*log10(psd_1$spec), col = "red")

legend("topright", legend=c("Target 0", "Target 1"), col=c("blue", "red"), lty=1)

library(tidyverse)
library(gsignal)

fs <- 128 
eeg_raw <- read.csv("train.csv")

my_filter <- butter(3, 0.5 / (fs / 2), type = "high")
eeg_raw$AF3_clean <- filter(my_filter, eeg_raw$AF3)

# Welch's method
psd_0 <- pwelch(eeg_raw$AF3_clean[eeg_raw$target == 0], fs = fs)
psd_1 <- pwelch(eeg_raw$AF3_clean[eeg_raw$target == 1], fs = fs)

plot(psd_0$freq, 10*log10(psd_0$spec), type = "l", col = "blue", 
     xlim = c(2, 40), ylim = c(10, 60),
     main = "Spectral Analysis: Neural State Comparison",
     xlab = "Frequency (Hz)", ylab = "Power (dB)")
lines(psd_1$freq, 10*log10(psd_1$spec), col = "red")
legend("topright", legend=c("Baseline (0)", "Active State (1)"), 
       col=c("blue", "red"), lty=1)
