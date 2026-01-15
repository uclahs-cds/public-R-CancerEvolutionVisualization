get.CP.polygons <- function(clone.out, start.angle = 0, ...) {
    polygon.list <- list();

    for (j in 1:length(clone.out$clones)) {
        # Get original polygon coordinates
        poly.x <- clone.out$clones[[j]]$x;
        poly.y <- clone.out$clones[[j]]$y;

        # Apply rotation if start.angle is non-zero
        if (start.angle != 0) {
            # Use the existing rotate.coords function to apply rotation
            # Rotation origin is (0, 0) which should align with the root node
            rotated <- rotate.coords(
                x = poly.x,
                y = poly.y,
                rotate.by = start.angle,
                x.origin = 0,
                y.origin = 0
                );
            poly.x <- rotated$x;
            poly.y <- rotated$y;
            }

        polygon.list[[j]] <- polygonGrob(
            name = paste0('clone.polygon.', j),
            x = poly.x,
            y = poly.y,
            default.units = 'native',
            gp = gpar(
                fill = clone.out$clones[[j]]$col,
                col = 'transparent',
                alpha = clone.out$clones[[j]]$alpha
                )
            );
        }

    clone.out$grobs <- c(clone.out$grobs, polygon.list);
    }
