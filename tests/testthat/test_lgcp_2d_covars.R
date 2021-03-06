context("2D LGCP fitting and prediction: Covariates")
library(INLA)
data(gorillas, package = "inlabru")
init.tutorial()

test_that("2D LGCP fitting: Factor covariate (as SpatialPixelsDataFrame)", {
  mdl <- coordinates ~ veg(map = gorillas$gcov$vegetation, model = "factor") - Intercept 
  fit <- lgcp(mdl, gorillas$nests, samplers = gorillas$boundary, domain = list(coordinates = gorillas$mesh),
               options = list(control.fixed = list(expand.factor.strategy = "inla")))
  
  expect_equal(fit$summary.fixed[,"mean"], c(4.269611,2.219120,1.557980,4.455956,3.590849,4.175845), tolerance = lowtol)
  expect_equal(fit$summary.fixed[,"sd"], c(0.57677865,0.11041125,0.22336546,0.04484612,0.21299094,0.21800205), tolerance = lowtol)
  
})

test_that("2D LGCP fitting: Continuous covariate (as function)", {
  
  elev <- gorillas$gcov$elevation
  elev$elevation <- elev$elevation - mean(elev$elevation, na.rm = TRUE)
  f.elev <- function(x,y) {
    spp <- SpatialPoints(data.frame(x=x,y=y)) 
    proj4string(spp) <- CRS(proj4string(elev))
    v <- over(spp, elev) 
    v[is.na(v)] <- 0 # NAs are a problem! Remove them
    return(v$elevation)
  } 

  mdl <- coordinates ~ beta.elev(map = f.elev(x,y), model = "linear") + Intercept
  fit <- lgcp(mdl, gorillas$nests, samplers = gorillas$boundary) 
  
  expect_equal(fit$summary.fixed["beta.elev","mean"], 0.003249187, tolerance = lowtol)
  expect_equal(fit$summary.fixed["beta.elev","sd"], 0.0002526346, tolerance = lowtol)
  expect_equal(fit$summary.fixed["Intercept","mean"], 3.498229, tolerance = lowtol)
  expect_equal(fit$summary.fixed["Intercept","sd"], 0.05654166, tolerance = lowtol)
  
})


