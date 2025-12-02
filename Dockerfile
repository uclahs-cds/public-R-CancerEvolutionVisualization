ARG BPG_VERSION=7.1.0
ARG CEV_VERSION=3.0.0

FROM ghcr.io/uclahs-cds/boutroslabplottinggeneral:${BPG_VERSION} AS builder

USER root

RUN apt-get update && apt-get install -y pandoc && rm -rf /var/lib/apt/lists/*

RUN R -q -e 'install.packages(c("gridExtra", "gtable", "testthat", "rmarkdown", "knitr", "data.table"), repos = "http://cran.us.r-project.org", lib = "/usr/lib/R/site-library", dependencies = TRUE)'

RUN mkdir -p /usr/local/CancerEvolutionVisualization
COPY . /usr/local/CancerEvolutionVisualization
RUN cd /usr/local/CancerEvolutionVisualization && \
    R CMD build . && \
    R -q -e 'install.packages("CancerEvolutionVisualization_'${CEV_VERSION}'.tar.gz", lib = "/usr/lib/R/site-library", repos = NULL, type = "source")'

# Add a new user/group called bldocker
RUN groupadd -g 500001 bldocker && \
    useradd -r -u 500001 -g bldocker bldocker

# Change the default user to bldocker from root
USER bldocker

LABEL maintainer="Helena Winata <hwinata@mednet.ucla.edu>" \
    org.opencontainers.image.source=https://github.com/uclahs-cds/package-CancerEvolutionVisualization
