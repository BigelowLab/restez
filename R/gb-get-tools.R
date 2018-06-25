#' @name gb_sql_query
#' @title Query the GenBank SQL
#' @description Generic query function for retrieving
#' data from the SQL database for the get functions.
#' @param nm character, column name
#' @param id character, sequence accession ID(s)
#' @return data.frame
#' @noRd
gb_sql_query <- function(nm, id) {
  # reduce ids to accessions
  id <- sub(pattern = '\\.[0-9]+', replacement = '', x = id)
  qry_id <- paste0('(', paste0(paste0("'", id, "'"), collapse = ','), ')')
  qry <- paste0("SELECT accession,", nm,
                " FROM nucleotide WHERE accession in ", qry_id)
  connection <- DBI::dbConnect(drv = RSQLite::SQLite(),
                               dbname = sql_path_get())
  on.exit(DBI::dbDisconnect(conn = connection))
  qry <- DBI::dbSendQuery(conn = connection, statement = qry)
  on.exit(expr = {
    DBI::dbClearResult(res = qry)
    DBI::dbDisconnect(conn = connection)
  })
  res <- DBI::dbFetch(res = qry)
  res
}

#' @name gb_fasta_get
#' @title Get fasta from GenBank
#' @family get
#' @description Get sequence and definition data
#' in FASTA format.
#' @param id character, sequence accession ID(s)
#' @return named vector of fasta sequences, if no results found NULL
#' @export
#' @example examples/gb_fasta_get.R
gb_fasta_get <- function(id) {
  seqs <- gb_sequence_get(id = id)
  if (length(seqs) == 0) {
    return(NULL)
  }
  defs <- gb_definition_get(id = id)
  fastas <- paste0('>', defs, '\n', seqs)
  names(fastas) <- names(defs)
  fastas
}

#' @name gb_sequence_get
#' @title Get sequence from GenBank
#' @family get
#' @description Return the sequence(s) for a record(s)
#' from the accession ID(s).
#' @param id character, sequence accession ID(s)
#' @return named vector of sequences, if no results found NULL
#' @export
#' @example examples/gb_sequence_get.R
gb_sequence_get <- function(id) {
  res <- gb_sql_query(nm = 'raw_sequence', id = id)
  sqs <- lapply(res[['raw_sequence']], rawToChar)
  names(sqs) <- res[['accession']]
  unlist(sqs)
}

#' @name gb_record_get
#' @title Get record from GenBank
#' @family get
#' @description Return the entire GenBank record
#' for an accession ID.
#' @param id character, sequence accession ID(s)
#' @return named vector of records, if no results found NULL
#' @export
#' @example examples/gb_record_get.R
gb_record_get <- function(id) {
  res <- gb_sql_query(nm = 'raw_record', id = id)
  rcs <- lapply(res[['raw_record']], rawToChar)
  names(rcs) <- res[['accession']]
  unlist(rcs)
}

#' @name gb_definition_get
#' @title Get definition from GenBank
#' @family get
#' @description Return the definition line
#' for an accession ID.
#' @param id character, sequence accession ID(s)
#' @return named vector of definitions, if no results found NULL
#' @export
#' @example examples/gb_definition_get.R
gb_definition_get <- function(id) {
  res <- gb_sql_query(nm = 'raw_definition', id = id)
  dfs <- lapply(res[['raw_definition']], rawToChar)
  names(dfs) <- res[['accession']]
  unlist(dfs)
}

#' @name gb_organism_get
#' @title Get organism from GenBank
#' @family get
#' @description Return the organism name
#' for an accession ID.
#' @param id character, sequence accession ID(s)
#' @return named vector of definitions, if no results found NULL
#' @export
#' @example examples/gb_organism_get.R
gb_organism_get <- function(id) {
  res <- gb_sql_query(nm = 'organism', id = id)
  if (nrow(res) == 0) {
    return(NULL)
  }
  ors <- res[['organism']]
  names(ors) <- res[['accession']]
  ors
}

#' @name gb_version_get
#' @title Get version from GenBank
#' @family get
#' @description Return the accession version
#' for an accession ID.
#' @param id character, sequence accession ID(s)
#' @return named vector of versions, if no results found NULL
#' @export
#' @example examples/gb_version_get.R
gb_version_get <- function(id) {
  res <- gb_sql_query(nm = 'version', id = id)
  vrs <- res[['version']]
  names(vrs) <- res[['accession']]
  vrs
}