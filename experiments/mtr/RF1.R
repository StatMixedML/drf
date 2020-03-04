# RF1 dataset

# RF 
# The river flow datasets concern the prediction of river network flows for 48 h in the future
# at specific locations. The dataset contains data from hourly flow observations for 8 sites in
# the Mississippi River network in the United States and were obtained from the US National
# Weather Service. Each row includes the most recent observation for each of the 8 sites as
# well as time-lagged observations from 6, 12, 18, 24, 36, 48 and 60 h in the past. In RF1, each
# site contributes 8 attribute variables to facilitate prediction. There are a total of 64 variables
# plus 8 target variables.The RF2 dataset extends the RF1 data by adding precipitation forecast
# information for each of the 8 sites (expected rainfall reported as discrete values: 0.0, 0.01, 0.25,
#                                      1.0 inches). For each observation and gauge site, the precipitation forecast for 6 h windows
# up to 48 h in the future is added (6, 12, 18, 24, 30, 36, 42, and 48 h). The two datasets both
# contain over 1 year of hourly observations (>9000 h) collected from September 2011 to
# September 2012. The domain is a natural candidate for multi-target regression because there
# are clear physical relationships between readings in the contiguous river network.

# repro
set.seed(1)

# libs
require(mrf)

# source
source("./experiments/mtr/helpers.R")

# 
d <- loadMTRdata(dataset.name = "RF1")


# fit an mrf
mRF <- mrf(X = d$X, Y = d$Y, splitting.rule = "fourier", num_features = 100)

# variable importance
plot(factor(colnames(d$X)),as.numeric(variable_importance(mRF)))


# kfold validation
folds <- kFoldCV(n = nrow(d$X), k = 5)

RMSE_t_mat <- matrix(0,nrow=2, ncol=ncol(d$Y))
colnames(RMSE_t_mat) <- colnames(d$Y)

# fourier
for (k in 1:5) {
  mRF <- mrf(X = d$X[-folds[[k]],], Y = d$Y[-folds[[k]],], splitting.rule = "fourier", num_features = 100)
  p_fourier <- predict(mRF, newdata = d$X[folds[[k]],])
  Yhat <- sapply(1:ncol(p_fourier$y), function(d) apply(p_fourier$weights, 1, function(w) sum(w*p_fourier$y[,d])))
  RMSE_t_mat[1,] <- RMSE_t_mat[1,] + RMSE_t(d$Y[folds[[k]],],Yhat)/10
  print(k)
}

# gini
for (k in 1:5) {
  mRF <- mrf(X = d$X[-folds[[k]],], Y = d$Y[-folds[[k]],], splitting.rule = "gini")
  p_gini <- predict(mRF, newdata = d$X[folds[[k]],])
  Yhat <- sapply(1:ncol(p_gini$y), function(d) apply(p_gini$weights, 1, function(w) sum(w*p_gini$y[,d])))
  RMSE_t_mat[2,] <- RMSE_t_mat[2,] + RMSE_t(d$Y[folds[[k]],],Yhat)/10
  print(k)
}

# see the results 
print(RMSE_t_mat)


