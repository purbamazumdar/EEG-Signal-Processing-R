install.packages("tidyverse") # For cleaning and organizing data
install.packages("gsignal")   # For filtering the EEG brainwaves
install.packages("patchwork") # For making beautiful side-by-side graphs
# 1. Open the toolboxes
library(tidyverse)
library(gsignal)

# 2. Load your EEG data into a variable called 'eeg_raw'
eeg_raw <- read.csv("train.csv")

# 3. Look at the data structure
head(eeg_raw)
fs <- 128  # This tells R there are 128 data points per second
# Plotting the first 256 points of the AF3 channel
plot(eeg_raw$AF3[1:256], type = "l", col = "darkgreen",
     main = "Raw EEG Signal (Channel AF3)",
     xlab = "Time Points", ylab = "Voltage (uV)")
# Group the data by 'target' and find the average voltage for channel AF3
comparison <- eeg_raw %>%
  group_by(target) %>%
  summarise(Average_Voltage = mean(AF3))

# Print the result to the console
print(comparison)
# 1. Create a filter that removes everything below 0.5 Hz
my_filter <- butter(3, 0.5 / (fs / 2), type = "high")

# 2. Apply it to the AF3 channel
eeg_raw$AF3_clean <- filter(my_filter, eeg_raw$AF3)

# 3. Plot the cleaned version to see the difference
plot(eeg_raw$AF3_clean[1:256], type = "l", col = "red",
     main = "Filtered EEG (Drift Removed)",
     xlab = "Time Points", ylab = "Voltage")
# 1. Calculate the Power Spectral Density (PSD) for Target 0
psd_0 <- pwelch(eeg_raw$AF3_clean[eeg_raw$target == 0], fs = fs)

# 2. Calculate the Power Spectral Density (PSD) for Target 1
psd_1 <- pwelch(eeg_raw$AF3_clean[eeg_raw$target == 1], fs = fs)

# 3. Plot the result to compare them
# We use 10*log10 to put the power on a decibel (dB) scale, making it easier to see peaks
plot(psd_0$freq, 10*log10(psd_0$spec), type = "l", col = "blue", 
     xlim = c(0, 40), ylim = c(10, 60),
     main = "Brainwave Frequency Comparison",
     xlab = "Frequency (Hz)", ylab = "Power (dB)")

# Add the second line for Target 1
lines(psd_1$freq, 10*log10(psd_1$spec), col = "red")

# Add a legend so we know which is which
legend("topright", legend=c("Target 0", "Target 1"), col=c("blue", "red"), lty=1)
# --- PROJECT: EEG Signal Processing & State Classification ---
# Goal: To identify neural markers (Alpha/Beta power) between two states.
# 1. Load necessary libraries for Signal Processing and Data Wrangling
library(tidyverse)
library(gsignal)

# 2. Import raw EEG data (Assuming 128Hz sampling rate)
fs <- 128 
eeg_raw <- read.csv("train.csv")

# 3. Pre-processing: Apply a 3rd-order Butterworth High-pass filter
# This removes low-frequency 'drift' (noise) below 0.5 Hz
my_filter <- butter(3, 0.5 / (fs / 2), type = "high")
eeg_raw$AF3_clean <- filter(my_filter, eeg_raw$AF3)

# 4. Spectral Analysis: Calculate Power Spectral Density (PSD)
# Using Welch's Method to estimate the power of different brain rhythms
psd_0 <- pwelch(eeg_raw$AF3_clean[eeg_raw$target == 0], fs = fs)
psd_1 <- pwelch(eeg_raw$AF3_clean[eeg_raw$target == 1], fs = fs)

# 5. Visualization: Compare Frequency Power between Target 0 and Target 1
plot(psd_0$freq, 10*log10(psd_0$spec), type = "l", col = "blue", 
     xlim = c(2, 40), ylim = c(10, 60),
     main = "Spectral Analysis: Neural State Comparison",
     xlab = "Frequency (Hz)", ylab = "Power (dB)")

# Add Target 1 (Red) to the plot for direct comparison
lines(psd_1$freq, 10*log10(psd_1$spec), col = "red")

# Add a legend for professional clarity
legend("topright", legend=c("Baseline (0)", "Active State (1)"), 
       col=c("blue", "red"), lty=1)