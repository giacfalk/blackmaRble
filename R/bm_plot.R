#' @export
bm_plot <- function(X){

  print(plot(X))

}

#' @export
bm_trend <- function(Z){

time <- 1:nlayers(Z)
fun=function(x) { if (is.na(x[1])){ NA } else { m = lm(x ~ time); summary(m)$coefficients[2] }}
gimms.slope=calc(Z, fun)

print(plot(gimms.slope))
return(gimms.slope)

}
