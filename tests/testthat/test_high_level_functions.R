test_that("high level functions working?", {
    embed_methods <- dimRedMethodList(filter = TRUE)
    quality_methods <- dimRedQualityList(filter = TRUE)
    scurve <- loadDataSet("3D S Curve", n = 300)
    for (i in seq_len(ncol(scurve@data))){
      scurve@data[, i] <- scurve@data[, i] - min(scurve@data[, i])
    }

    quality_results <- matrix(NA, length(embed_methods),
                              length(quality_methods),
                              dimnames = list(embed_methods, quality_methods))
    embedded_data <- list()

    for (e in embed_methods) {
        message("embedding: ", e)

        if (  (e != "AutoEncoder" || reticulate::py_module_available("tensorflow")) &&
              (e != "UMAP"        || reticulate::py_module_available("umap-learn"))    ) {

          suppressWarnings(
            embedded_data[[e]] <- embed(
              scurve, e,
              .mute = c("message", "output")))

          for (q in quality_methods) {
            message("  quality: ", q)
            quality_results[e, q] <- tryCatch(
              suppressWarnings(quality(embedded_data[[e]], q,
                                       .mute = c("message", "output"))),
              error = function (e) NA
            )
          }

        }
    }

    lapply(embedded_data, function(x) expect_equal(2, getNDim(x)))

    expect(inherits(quality_results, "matrix"), "should be matrix")
    expect(storage.mode(quality_results) == "double",
           'storage should be "double"')
})
