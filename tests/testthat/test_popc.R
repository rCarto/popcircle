context("TEST ALL")


mtq <- st_read(system.file("gpkg/mtq.gpkg", package="popcircle"), quiet = TRUE)
test_that("contour works", {
  expect_silent(popcircle(mtq, "POP"))
})
