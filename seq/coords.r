.gene_table = import('./gene_table')$gene_table

#TODO:
# keep track of assembly
# add seqlengths to GRanges object

#' @rdname gene
.process = function(coords, chromosomes, type, granges, start_field, end_field) {
    coords %>%
        dplyr::distinct() %>%
        dplyr::arrange(chromosome_name, start_position)

    if (!is.null(type))
        coords = dplyr::filter(coords, gene_biotype %in% type)

    if (is.null(chromosomes))
        chromosomes = c(1:100, 'X', 'Y', 'MT')
    coords = dplyr::filter(coords, chromosome_name %in% chromosomes)

    coords = mutate(coords, canonical_tss =
        ifelse(strand == 1, start_position, end_position))

    if (granges) {
        strand_lookup = setNames(c("+", "-"), c(1, -1))
        coords = coords %>%
            dplyr::mutate(strand = strand_lookup[as.character(strand)]) %>%
            GenomicRanges::makeGRangesFromDataFrame(
                start.field = start_field,
                end.field = end_field,
                keep.extra.columns = TRUE)
    }

    coords
}

#' Get gene or trascript coordinates as GRanges object
#'
#' @param idtype      biomart ID type ('hgnc_symbol', 'entrezgene', etc.)
#' @param assembly    Genome assembly
#' @param granges     Return a GRanges object instead of a data.frame
#' @param chromosomes Subset genes to specific chromosomes; in+excludes prefix
#' @param type        Only return genes of a certain type, e.g. 'protein_coding'
#' @return            A data.frame or GRanges object with gene coordinates
gene = function(idtype="hgnc_symbol", assembly="fixthis", granges=FALSE,
                chromosomes=NULL, type=NULL) {
    if (idtype %in% c("hgnc_symbol", "mgi_symbol"))
        idtype = "external_gene_name"

    keep = c(idtype, "band", "chromosome_name", "start_position",
             "end_position", "strand", "gene_biotype")
    .process(.gene_table()[,keep], chromosomes, type, granges,
             "start_position", "end_position")
}

#' @rdname gene
transcript = function(idtype="hgnc_symbol", assembly="fixthis", granges=FALSE,
                      chromosomes=NULL) {
    if (idtype %in% c("hgnc_symbol", "mgi_symbol"))
        idtype = "external_gene_name"

    .process(.gene_table(), chromosomes, type, granges,
             "transcript_start", "transcript_end")
}

#' @rdname gene
probeset = function(idtype="hgnc_symbol", assembly="fixthis", granges=FALSE,
                    chromosomes=NULL) {
    stop("not implemented")
}