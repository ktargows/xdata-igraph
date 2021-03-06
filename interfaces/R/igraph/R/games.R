
#   IGraph R package
#   Copyright (C) 2005-2012  Gabor Csardi <csardi.gabor@gmail.com>
#   334 Harvard street, Cambridge, MA 02139 USA
#   
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#   
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc.,  51 Franklin Street, Fifth Floor, Boston, MA
#   02110-1301 USA
#
###################################################################

ba.game <- function(n, power=1, m=NULL, out.dist=NULL, out.seq=NULL,
                    out.pref=FALSE, zero.appeal=1,
                    directed=TRUE, algorithm=c("psumtree",
                                     "psumtree-multiple", "bag"),
                    start.graph=NULL) {

  if (!is.null(start.graph) && !is.igraph(start.graph)) {
    stop("`start.graph' not an `igraph' object")
  }
  
  # Checks
  if (! is.null(out.seq) && (!is.null(m) || !is.null(out.dist))) {
    warning("if `out.seq' is given `m' and `out.dist' should be NULL")
    m <- out.dist <- NULL
  }
  if (is.null(out.seq) && !is.null(out.dist) && !is.null(m)) {
    warning("if `out.dist' is given `m' will be ignored")
    m <- NULL
  }
  if (!is.null(m) && m==0) {
    warning("`m' is zero, graph will be empty")
  }
  if (power < 0) {
    warning("`power' is negative")
  }
  
  if (is.null(m) && is.null(out.dist) && is.null(out.seq)) {
    m <- 1
  }
  
  n <- as.numeric(n)
  power <- as.numeric(power)
  if (!is.null(m)) { m <- as.numeric(m) }
  if (!is.null(out.dist)) { out.dist <- as.numeric(out.dist) }
  if (!is.null(out.seq)) { out.seq <- as.numeric(out.seq) }
  out.pref <- as.logical(out.pref)

  if (!is.null(out.dist)) {
    nn <- if (is.null(start.graph)) n else n-vcount(start.graph)
    out.seq <- as.numeric(sample(0:(length(out.dist)-1), nn,
                                 replace=TRUE, prob=out.dist))
  }

  if (is.null(out.seq)) {
    out.seq <- numeric()
  }

  algorithm <- igraph.match.arg(algorithm)
  algorithm1 <- switch(algorithm,
                       "psumtree"=1, "psumtree-multiple"=2,
                       "bag"=0)
  
  on.exit( .Call("R_igraph_finalizer", PACKAGE="igraph") )
  res <- .Call("R_igraph_barabasi_game", n, power, m, out.seq, out.pref,
               zero.appeal, directed, algorithm1, start.graph,
               PACKAGE="igraph")
  
  if (getIgraphOpt("add.params")) {
    res$name <- "Barabasi graph"
    res$power <- power
    res$m <- m
    res$zero.appeal <- zero.appeal
    res$algorithm <- algorithm
  }

  res
}

barabasi.game <- ba.game

erdos.renyi.game <- function(n, p.or.m, type=c("gnp", "gnm"),
                             directed=FALSE, loops=FALSE, ...) {
  
  type <- igraph.match.arg(type)
  type1 <- switch(type, "gnp"=0, "gnm"=1)

  on.exit( .Call("R_igraph_finalizer", PACKAGE="igraph") )
  res <- .Call("R_igraph_erdos_renyi_game", as.numeric(n), as.numeric(type1),
               as.numeric(p.or.m), as.logical(directed), as.logical(loops),
               PACKAGE="igraph")

  if (getIgraphOpt("add.params")) {
    res$name <- sprintf("Erdos renyi (%s) graph", type)
    res$type <- type
    res$loops <- loops
    if (type=="gnp") { res$p <- p.or.m }
    if (type=="gnm") { res$m <- p.or.m }
  }
  res
}

random.graph.game <- erdos.renyi.game

degree.sequence.game <- function(out.deg, in.deg=NULL,
                                 method=c("simple", "vl",
                                   "simple.no.multiple"),
                                 ...) {

  method <- igraph.match.arg(method)
  method1 <- switch(method, "simple"=0, "vl"=1, "simple.no.multiple"=2)
  if (!is.null(in.deg)) { in.deg <- as.numeric(in.deg) }

  on.exit( .Call("R_igraph_finalizer", PACKAGE="igraph") )
  res <- .Call("R_igraph_degree_sequence_game", as.numeric(out.deg),
               in.deg, as.numeric(method1),
               PACKAGE="igraph")
  if (getIgraphOpt("add.params")) {
    res$name <- "Degree sequence random graph"
    res$method <- method
  }
  res
}

growing.random.game <- function(n, m=1, directed=TRUE, citation=FALSE) {
  on.exit( .Call("R_igraph_finalizer", PACKAGE="igraph") )
  res <- .Call("R_igraph_growing_random_game", as.numeric(n), as.numeric(m),
               as.logical(directed), as.logical(citation),
               PACKAGE="igraph")
  if (getIgraphOpt("add.params")) {
    res$name <- "Growing random graph"
    res$m <- m
    res$citation <- citation
  }
  res
}

aging.prefatt.game <- function(n, pa.exp, aging.exp, m=NULL, aging.bin=300,
                               out.dist=NULL, out.seq=NULL,
                               out.pref=FALSE, directed=TRUE,
                               zero.deg.appeal=1, zero.age.appeal=0,
                               deg.coef=1, age.coef=1,
                               time.window=NULL) {
  # Checks
  if (! is.null(out.seq) && (!is.null(m) || !is.null(out.dist))) {
    warning("if `out.seq' is given `m' and `out.dist' should be NULL")
    m <- out.dist <- NULL
  }
  if (is.null(out.seq) && !is.null(out.dist) && !is.null(m)) {
    warning("if `out.dist' is given `m' will be ignored")
    m <- NULL
  }
  if (!is.null(out.seq) && length(out.seq) != n) {
    stop("`out.seq' should be of length `n'")
  }
  if (!is.null(out.seq) && min(out.seq)<0) {
    stop("negative elements in `out.seq'");
  }
  if (!is.null(m) && m<0) {
    stop("`m' is negative")
  }
  if (!is.null(time.window) && time.window <= 0) {
    stop("time window size should be positive")
  }
  if (!is.null(m) && m==0) {
    warning("`m' is zero, graph will be empty")
  }
  if (pa.exp < 0) {
    warning("preferential attachment is negative")
  }
  if (aging.exp > 0) {
    warning("aging exponent is positive")
  }
  if (zero.deg.appeal <=0 ) {
    warning("initial attractiveness is not positive")
  }

  if (is.null(m) && is.null(out.dist) && is.null(out.seq)) {
    m <- 1
  }
  
  n <- as.numeric(n)
  if (!is.null(m)) { m <- as.numeric(m) }
  if (!is.null(out.dist)) { out.dist <- as.numeric(out.dist) }
  if (!is.null(out.seq)) { out.seq <- as.numeric(out.seq) }
  out.pref <- as.logical(out.pref)

  if (!is.null(out.dist)) {
    out.seq <- as.numeric(sample(0:(length(out.dist)-1), n,
                                 replace=TRUE, prob=out.dist))
  }

  if (is.null(out.seq)) {
    out.seq <- numeric()
  }

  on.exit( .Call("R_igraph_finalizer", PACKAGE="igraph") )
  res <- if (is.null(time.window)) {
    .Call("R_igraph_barabasi_aging_game", as.numeric(n),
          as.numeric(pa.exp), as.numeric(aging.exp),
          as.numeric(aging.bin), m, out.seq,
          out.pref, as.numeric(zero.deg.appeal), as.numeric(zero.age.appeal),
          as.numeric(deg.coef), as.numeric(age.coef), directed, 
          PACKAGE="igraph")
  } else {
    .Call("R_igraph_recent_degree_aging_game", as.numeric(n),
          as.numeric(pa.exp), as.numeric(aging.exp),
          as.numeric(aging.bin), m, out.seq, out.pref, as.numeric(zero.deg.appeal),
          directed,
          time.window,
          PACKAGE="igraph")
  }
  if (getIgraphOpt("add.params")) {
    res$name <- "Aging Barabasi graph"
    res$pa.exp <- pa.exp
    res$aging.exp <- aging.exp
    res$m <- m
    res$aging.bin <- aging.bin
    res$out.pref <- out.pref
    res$zero.deg.appeal <- zero.deg.appeal
    res$zero.age.appeal <- zero.age.appeal
    res$deg.coef <- deg.coef
    res$age.coef <- age.coef
    res$time.window <- if (is.null(time.window)) Inf else time.window
  }
  res
}

aging.barabasi.game <- aging.ba.game <- aging.prefatt.game

callaway.traits.game <- function(nodes, types, edge.per.step=1,
                                 type.dist=rep(1, types),
                                 pref.matrix=matrix(1, types, types),
                                 directed=FALSE) {

  on.exit( .Call("R_igraph_finalizer", PACKAGE="igraph") )
  res <- .Call("R_igraph_callaway_traits_game", as.double(nodes),
               as.double(types), as.double(edge.per.step),
               as.double(type.dist), matrix(as.double(pref.matrix), types,
                                            types),
               as.logical(directed),
               PACKAGE="igraph")
  if (getIgraphOpt("add.params")) {
    res$name <- "Trait-based Callaway graph"
    res$types <- types
    res$edge.per.step <- edge.per.step
    res$type.dist <- type.dist
    res$pref.matrix <- pref.matrix
  }
  res
}

establishment.game <- function(nodes, types, k=1, type.dist=rep(1, types),
                               pref.matrix=matrix(1, types, types),
                               directed=FALSE) {

  on.exit( .Call("R_igraph_finalizer", PACKAGE="igraph") )
  res <- .Call("R_igraph_establishment_game", as.double(nodes),
               as.double(types), as.double(k), as.double(type.dist),
               matrix(as.double(pref.matrix), types, types),
               as.logical(directed),
               PACKAGE="igraph")
  if (getIgraphOpt("add.params")) {
    res$name <- "Trait-based growing graph"
    res$types <- types
    res$k <- k
    res$type.dist <- type.dist
    res$pref.matrix <- pref.matrix
  }
  res
}

grg.game <- function(nodes, radius, torus=FALSE, coords=FALSE) {
  on.exit( .Call("R_igraph_finalizer", PACKAGE="igraph") )
  res <- .Call("R_igraph_grg_game", as.double(nodes), as.double(radius),
               as.logical(torus), as.logical(coords),
               PACKAGE="igraph")
  if (coords) {
    V(res[[1]])$x <- res[[2]]
    V(res[[1]])$y <- res[[3]]
  }
  if (getIgraphOpt("add.params")) {
    res[[1]]$name <- "Geometric random graph"
    res[[1]]$radius <- radius
    res[[1]]$torus <- torus
  }
  res[[1]]
}

preference.game <- function(nodes, types, type.dist=rep(1, types),
                            fixed.sizes=FALSE,
                            pref.matrix=matrix(1, types, types),
                            directed=FALSE, loops=FALSE) {

  if (nrow(pref.matrix) != types || ncol(pref.matrix) != types) {
    stop("Invalid size for preference matrix")
  }
  
  on.exit( .Call("R_igraph_finalizer", PACKAGE="igraph") )
  res <- .Call("R_igraph_preference_game", as.double(nodes),
               as.double(types),
               as.double(type.dist), as.logical(fixed.sizes),
               matrix(as.double(pref.matrix), types, types),
               as.logical(directed), as.logical(loops),
               PACKAGE="igraph")
  V(res[[1]])$type <- res[[2]]+1
  if (getIgraphOpt("add.params")) {
    res[[1]]$name <- "Preference random graph"
    res[[1]]$types <- types
    res[[1]]$type.dist <- type.dist
    res[[1]]$fixed.sizes <- fixed.sizes
    res[[1]]$pref.matrix <- pref.matrix
    res[[1]]$loops <- loops
  }
  res[[1]]
}

asymmetric.preference.game <- function(nodes, types,
                                  type.dist.matrix=matrix(1, types,types),
                                  pref.matrix=matrix(1, types, types),
                                  loops=FALSE) {
  
  if (nrow(pref.matrix) != types || ncol(pref.matrix) != types) {
    stop("Invalid size for preference matrix")
  }
  if (nrow(type.dist.matrix) != types || ncol(type.dist.matrix) != types) {
    stop("Invalid size for type distribution matrix")
  }
  
  on.exit( .Call("R_igraph_finalizer", PACKAGE="igraph") )
  res <- .Call("R_igraph_asymmetric_preference_game",
               as.double(nodes), as.double(types),
               matrix(as.double(type.dist.matrix), types, types),
               matrix(as.double(pref.matrix), types, types),
               as.logical(loops),
               PACKAGE="igraph")
  if (getIgraphOpt("add.params")) {
    res$name <- "Asymmetric preference random graph"
    res$types <- types
    res$type.dist.matrix <- type.dist.matrix
    res$pref.matrix <- pref.matrix
    res$loops <- loops
  }
}

connect.neighborhood <- function(graph, order, mode=c("all", "out", "in", "total")) {
  if (!is.igraph(graph)) {
    stop("Not a graph object")
  }
  mode <- igraph.match.arg(mode)
  mode <- switch(mode, "out"=1, "in"=2, "all"=3, "total"=3)

  on.exit( .Call("R_igraph_finalizer", PACKAGE="igraph") )
  .Call("R_igraph_connect_neighborhood", graph, as.numeric(order),
        as.numeric(mode),
        PACKAGE="igraph")
}

rewire.edges <- function(graph, prob, loops=FALSE, multiple=FALSE) {
  if (!is.igraph(graph)) {
    stop("Not a graph object")
  }
  on.exit( .Call("R_igraph_finalizer", PACKAGE="igraph") )
  .Call("R_igraph_rewire_edges", graph, as.numeric(prob), as.logical(loops),
        as.logical(multiple),
        PACKAGE="igraph")
}

watts.strogatz.game <- function(dim, size, nei, p, loops=FALSE,
                                multiple=FALSE) {
  
  on.exit( .Call("R_igraph_finalizer", PACKAGE="igraph") )
  res <- .Call("R_igraph_watts_strogatz_game", as.numeric(dim),
               as.numeric(size), as.numeric(nei), as.numeric(p),
               as.logical(loops), as.logical(multiple),
               PACKAGE="igraph")
  if (getIgraphOpt("add.params")) {
    res$name <- "Watts-Strogatz random graph"
    res$dim <- dim
    res$size <- size
    res$nei <- nei
    res$p <- p
    res$loops <- loops
    res$multiple <- multiple
  }
  res
}

lastcit.game <- function(n, edges=1, agebins=n/7100, pref=(1:(agebins+1))^-3,
                         directed=TRUE) {
  on.exit( .Call("R_igraph_finalizer", PACKAGE="igraph") )
  res <- .Call("R_igraph_lastcit_game", as.numeric(n), as.numeric(edges),
               as.numeric(agebins),
               as.numeric(pref), as.logical(directed),
               PACKAGE="igraph")
  if (getIgraphOpt("add.params")) {
    res$name <- "Random citation graph based on last citation"
    res$edges <- edges
    res$agebins <- agebins
  }
  res
}

cited.type.game <- function(n, edges=1, types=rep(0, n),
                            pref=rep(1, length(types)),
                            directed=TRUE, attr=TRUE) {
  on.exit( .Call("R_igraph_finalizer", PACKAGE="igraph") )
  res <- .Call("R_igraph_cited_type_game", as.numeric(n), as.numeric(edges),
               as.numeric(types), as.numeric(pref), as.logical(directed),
               PACKAGE="igraph")
  if (attr) {
    V(res)$type <- types
  }
  if (getIgraphOpt("add.params")) {
    res$name <- "Random citation graph (cited type)"
    res$edges <- edges
  }
  res
}

citing.cited.type.game <- function(n, edges=1, types=rep(0, n),
                                   pref=matrix(1, nrow=length(types),
                                     ncol=length(types)),
                                   directed=TRUE, attr=TRUE) {
  pref <- structure(as.numeric(pref), dim=dim(pref))
  on.exit( .Call("R_igraph_finalizer", PACKAGE="igraph") )
  res <- .Call("R_igraph_citing_cited_type_game", as.numeric(n),
               as.numeric(types), pref, as.numeric(edges),
               as.logical(directed),
               PACKAGE="igraph")
  if (attr) {
    V(res)$type <- types
  }
  if (getIgraphOpt("add.params")) {
    res$name <- "Random citation graph (citing & cited type)"
    res$edges <- edges
  }
  res
}


simple.interconnected.islands.game <- function(islands.n, islands.size, islands.pin, n.inter) {
  

  on.exit( .Call("R_igraph_finalizer", PACKAGE="igraph") )
  .Call(	"R_igraph_simple_interconnected_islands_game", 
		as.numeric(islands.n), 
		as.numeric(islands.size),
        	as.numeric(islands.pin), 
		as.numeric(n.inter),
        	PACKAGE="igraph")
}


bipartite.random.game <- function(n1, n2, type=c("gnp", "gnm"), p, m,
                                  directed=FALSE, mode=c("out", "in",
                                                    "all")) {
  
  n1 <- as.integer(n1)
  n2 <- as.integer(n2)
  type <- igraph.match.arg(type)
  if (!missing(p)) { p <- as.numeric(p) }
  if (!missing(m)) { m <- as.integer(m) }
  directed <- as.logical(directed)
  mode <- switch(igraph.match.arg(mode), "out"=1, "in"=2, "all"=3)

  if (type=="gnp" && missing(p)) {
    stop("Connection probability `p' is not given for Gnp graph")
  }
  if (type=="gnp" && !missing(m)) {
    warning("Number of edges `m' is ignored for Gnp graph")
  }
  if (type=="gnm" && missing(m)) {
    stop("Number of edges `m' is not given for Gnm graph")
  }
  if (type=="gnm" && !missing(p)) {
    warning("Connection probability `p' is ignored for Gnp graph")
  }
  
  on.exit( .Call("R_igraph_finalizer", PACKAGE="igraph") )
  if (type=="gnp") {      
    res <- .Call("R_igraph_bipartite_game_gnp", n1, n2, p, directed, mode,
                 PACKAGE="igraph")
    res <- set.vertex.attribute(res$graph, "type", value=res$types)
    res$name <- "Bipartite Gnp random graph"
    res$p <- p
  } else if (type=="gnm") {
    res <- .Call("R_igraph_bipartite_game_gnm", n1, n2, m, directed, mode,
                 PACKAGE="igraph")
    res <- set.vertex.attribute(res$graph, "type", value=res$types)
    res$name <- "Bipartite Gnm random graph"
    res$m <- m
  }

  res
}

hsbm.game <- function(n, m, rho, C, p) {

  mlen <- length(m)
  rholen <- if (is.list(rho)) length(rho) else 1
  Clen <- if (is.list(C)) length(C) else 1

  commonlen <- unique(c(mlen, rholen, Clen))

  if (length(commonlen) == 1 && commonlen == 1) {
    hsbm.1.game(n, m, rho, C, p)
  } else {
    commonlen <- setdiff(commonlen, 1)
    if (length(commonlen) != 1) {
      stop("Lengths of `m', `rho' and `C' must match")
    }
    m <- rep(m, length.out=commonlen)
    rho <- if (is.list(rho)) {
      rep(rho, length.out=commonlen)
    } else {
      rep(list(rho), length.out=commonlen)
    }
    C <- if (is.list(C)) {
      rep(C, length.out=commonlen)
    } else {
      rep(list(C), length.out=commonlen)
    }
    hsbm.list.game(n, m, rho, C, p)
  }  
}

