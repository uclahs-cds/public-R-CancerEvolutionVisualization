# Regression tests for the axis loss introduced by commit db616d9 (PR #190).
#
# That commit added, in add.axes():
#
#     if (plotting.direction != 'down') {
#         message('Non-vertical plotting direction detected; skipping (nSNV) x-axis rendering.');
#         yaxis.position <- 'none';
#         }
#
# The stated intent was to drop the nSNV axis for horizontal fish plots, but:
#   * it set yaxis.position, removing the Y-axes, while the message says x-axis;
#   * it fired for every direction other than 'down', not just horizontal ones;
#   * `plotting.direction != 'down'` compares numeric to character, so R coerces
#     30 to "30" and numeric angles tripped it too.
#
# Result: up / left / right / 30 / 45 all rendered with zero y-axes.

axis.names <- function(grob) {
    grob$childrenOrder[grepl('axis', grob$childrenOrder)];
    }

two.length.tree <- function() {
    load(test_path('data', 'linear.data.Rda'));
    linear.test.data$tree[, c('parent', 'length.1', 'length.2')];
    }

test_that('y-axes are drawn for every plotting direction (regression, PR #190)', {
    tree <- two.length.tree();

    for (direction in list('down', 'up', 'left', 'right', 30, 45, -60)) {
        plt <- suppressMessages(SRCGrob(
            tree,
            yaxis2.label = '',
            plotting.direction = direction
            ));

        expect_setequal(axis.names(plt), c('axis.left', 'axis.right'));
        }
    });

test_that('a numeric direction is not string-compared against "down" (PR #190)', {
    # The guard used `plotting.direction != 'down'`, which coerces 30 to "30".
    # Any numeric angle must behave like the named directions here.
    tree <- two.length.tree();

    numeric.axes <- axis.names(suppressMessages(
        SRCGrob(tree, yaxis2.label = '', plotting.direction = 30)
        ));
    named.axes <- axis.names(suppressMessages(
        SRCGrob(tree, yaxis2.label = '', plotting.direction = 'down')
        ));

    expect_setequal(numeric.axes, named.axes);
    });

test_that('is.horizontal.direction classifies directions correctly', {
    expect_true(is.horizontal.direction('left'));
    expect_true(is.horizontal.direction('right'));
    expect_true(is.horizontal.direction(90));
    expect_true(is.horizontal.direction(270));
    expect_true(is.horizontal.direction(-90));

    expect_false(is.horizontal.direction('down'));
    expect_false(is.horizontal.direction('up'));
    expect_false(is.horizontal.direction(0));
    expect_false(is.horizontal.direction(30));
    expect_false(is.horizontal.direction(180));
    });

# tests/testthat/data/fish.data.Rda has no length columns at all
# (get.y.axis.position returns 'none'), so it never had an nSNV axis and cannot
# exercise the suppression. Build a fish plot that actually has two branch
# length scales.
two.length.fish.tree <- function() {
    data.frame(
        parent   = c(NA, '1', '1'),
        node.id  = c('1', '2', '3'),
        length.1 = c(NA, 20, 30),
        length.2 = c(NA, 200, 300),
        CP       = c(0.9, 0.5, 0.4),
        stringsAsFactors = FALSE
        );
    }

test_that('a vertical fish plot keeps both y-axes and the CCF axis (PR #190)', {
    plt <- suppressMessages(SRCGrob(
        two.length.fish.tree(),
        yaxis2.label = 'nSNV'
        ));

    expect_setequal(
        axis.names(plt),
        c('axis.bottom', 'axis.left', 'axis.right')
        );
    });

test_that('a horizontal fish plot drops only the nSNV axis (PR #190 intent)', {
    # db616d9's stated goal: a horizontal fish plot keeps its first y-axis and
    # loses only the second. It must not lose every axis.
    for (direction in c('left', 'right')) {
        plt <- suppressMessages(SRCGrob(
            two.length.fish.tree(),
            yaxis2.label = 'nSNV',
            plotting.direction = direction
            ));

        expect_length(axis.names(plt), 2);
        expect_true(length(axis.names(plt)) > 0);
        }
    });

test_that('a non-fish tree keeps both y-axes when horizontal (PR #190)', {
    # Suppression is scoped to fish plots. A plain two-length tree flowing
    # sideways still needs both scales.
    tree <- two.length.fish.tree();
    tree$CP <- NULL;

    plt <- suppressMessages(SRCGrob(
        tree,
        yaxis2.label = 'nSNV',
        plotting.direction = 'right'
        ));

    expect_true('axis.right' %in% axis.names(plt));
    });
