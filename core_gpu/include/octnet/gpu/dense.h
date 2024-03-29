// Copyright (c) 2017, The OctNet authors
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of the <organization> nor the
//       names of its contributors may be used to endorse or promote products
//       derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL OCTNET AUTHORS BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#ifndef OCTREE_DENSE_GPU_H
#define OCTREE_DENSE_GPU_H

#include "octnet/core/core.h"
#include "octnet/core/dense.h"

extern "C" {

// o2d
void octree_to_dhwc_gpu(const octree* grid_d, const int dense_depth, const int dense_height, const int dense_width, ot_data_t* data);
void octree_to_dhwc_avg_gpu(const octree* grid_d, const int dense_depth, const int dense_height, const int dense_width, ot_data_t* data);
void octree_to_dhwc_bwd_gpu(const octree* grid_d, const int dense_depth, const int dense_height, const int dense_width, const ot_data_t* grad_data, octree* grad_grid_d);

void octree_to_cdhw_gpu(const octree* grid_d, const int dense_depth, const int dense_height, const int dense_width, ot_data_t* data);
void octree_to_cdhw_avg_gpu(const octree* grid_d, const int dense_depth, const int dense_height, const int dense_width, ot_data_t* data);
void octree_to_cdhw_bwd_gpu(const octree* grid_d, const int dense_depth, const int dense_height, const int dense_width, const ot_data_t* grad_data, octree* grad_grid_d);


// d2o
void dhwc_to_octree_sum_gpu(const octree* grid_d_in, const int dense_depth, const int dense_height, const int dense_width, const ot_data_t* data, int feature_size, octree* grid_d);
void dhwc_to_octree_avg_gpu(const octree* grid_d_in, const int dense_depth, const int dense_height, const int dense_width, const ot_data_t* data, int feature_size, octree* grid_d);
void dhwc_to_octree_max_gpu(const octree* grid_d_in, const int dense_depth, const int dense_height, const int dense_width, const ot_data_t* data, int feature_size, octree* grid_d);
void dhwc_to_octree_sum_bwd_gpu(const octree* grad_out_grid_d, const int dense_depth, const int dense_height, const int dense_width, ot_data_t* grad_in_data);
void dhwc_to_octree_avg_bwd_gpu(const octree* grad_out_grid_d, const int dense_depth, const int dense_height, const int dense_width, ot_data_t* grad_in_data);

void cdhw_to_octree_sum_gpu(const octree* grid_d_in, const int dense_depth, const int dense_height, const int dense_width, const ot_data_t* data, int feature_size, octree* grid_d);
void cdhw_to_octree_avg_gpu(const octree* grid_d_in, const int dense_depth, const int dense_height, const int dense_width, const ot_data_t* data, int feature_size, octree* grid_d);
void cdhw_to_octree_max_gpu(const octree* grid_d_in, const int dense_depth, const int dense_height, const int dense_width, const ot_data_t* data, int feature_size, octree* grid_d);
void cdhw_to_octree_sum_bwd_gpu(const octree* grad_out_grid_d, const int dense_depth, const int dense_height, const int dense_width, ot_data_t* grad_in_data);
void cdhw_to_octree_avg_bwd_gpu(const octree* grad_out_grid_d, const int dense_depth, const int dense_height, const int dense_width, ot_data_t* grad_in_data);

} // extern "C"


template <int dense_format, bool avg_vol>
__global__ void kernel_octree_to_dense(ot_data_t* out_data, int n_voxels, const int dense_depth, const int dense_height, const int dense_width, const octree grid_d);


#endif
