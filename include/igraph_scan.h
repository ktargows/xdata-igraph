/* -*- mode: C -*-  */
/* 
   IGraph library.
   Copyright (C) 2013  Gabor Csardi <csardi.gabor@gmail.com>
   334 Harvard street, Cambridge, MA 02139 USA
   
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc.,  51 Franklin Street, Fifth Floor, Boston, MA 
   02110-1301 USA

*/

#ifndef IGRAPH_SCAN_H
#define IGRAPH_SCAN_H

#undef __BEGIN_DECLS
#undef __END_DECLS
#ifdef __cplusplus
# define __BEGIN_DECLS extern "C" {
# define __END_DECLS }
#else
# define __BEGIN_DECLS /* empty */
# define __END_DECLS /* empty */
#endif

#include "igraph_datatype.h"
#include "igraph_arpack.h"

__BEGIN_DECLS

int igraph_scan1(const igraph_t *graph, igraph_vector_t *res);
int igraph_scan1_approximate(const igraph_t *graph, igraph_vector_t *res,
                             int noevals, igraph_arpack_options_t *options);
int igraph_scan1_approximate_eigen(const igraph_t *graph,
                                   igraph_vector_t *res,
                                   const igraph_vector_t *values,
                                   const igraph_matrix_t *vectors);
__END_DECLS

#endif