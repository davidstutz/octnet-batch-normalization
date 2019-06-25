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

#include <iostream>
#include <cstring>
#include <chrono>
#include <limits>

#include <smmintrin.h>

#include "octnet/gpu/gpu.h"
#include "octnet/gpu/common.h"
#include "octnet/cpu/cpu.h"
#include "octnet/test/objects.h"




OCTREE_FUNCTION
inline int tree_n_leafs2(const ot_tree_t* tree) {
  int n = tree_cnt1(tree, 0, 73);
  return n * 8 - n + 1;
}




void correctness_cpu(ot_tree_t* tree) {
  std::cout << "---------------------- test correctness cpu --------------------" << std::endl;
  std::cout << tree_bit_str_cpu(tree) << std::endl;
  int nl_gt = tree_n_leafs(tree);
  int nl2 = tree_n_leafs2(tree);

  if(nl2 != nl_gt) {
    std::cout << "[ERROR_CPU]: " << nl_gt << " != " << nl2 << std::endl;
  }
}

void speed_cpu(ot_tree_t* tree) {
  int reps = 100000;

  int di = 0;
  auto t1 = std::chrono::high_resolution_clock::now();
  for(int rep = 0; rep < reps; ++rep) {
    int tmp = tree_n_leafs(tree);
    di += tmp;
  }
  auto t2 = std::chrono::high_resolution_clock::now();
  auto time_span = std::chrono::duration_cast<std::chrono::duration<double> >(t2 - t1);
  std::cout << "cpu old took " << time_span.count() << "[s]" << std::endl;
  std::cout << di << std::endl;

  di = 0;
  t1 = std::chrono::high_resolution_clock::now();
  for(int rep = 0; rep < reps; ++rep) {
    int tmp = tree_n_leafs2(tree);
    di += tmp;
  }
  t2 = std::chrono::high_resolution_clock::now();
  time_span = std::chrono::duration_cast<std::chrono::duration<double> >(t2 - t1);
  std::cout << "cpu new took " << time_span.count() << "[s]" << std::endl;
  std::cout << di << std::endl;
}





__global__ void kernel_correctness(const ot_tree_t* tree, int n_bit_ind) {
  CUDA_KERNEL_LOOP(bit_idx, n_bit_ind) { 
    int di_gt = tree_n_leafs(tree);
    int di2 = tree_n_leafs2(tree);
    if(di2 != di_gt) {
      printf("[ERROR_GPU] bit_idx=%d: %d != %d\n", bit_idx, di_gt, di2);
    }
  }
}

void correctness_gpu(ot_tree_t* tree_h) {
  std::cout << "---------------------- test correctness cpu --------------------" << std::endl;
  std::cout << tree_bit_str_cpu(tree_h) << std::endl;
  
  ot_tree_t* tree_d = host_to_device_malloc(tree_h, N_TREE_INTS);

  int n_bit_ind = 1+8+64+64*8;
  kernel_correctness<<<GET_BLOCKS(n_bit_ind), CUDA_NUM_THREADS>>>(
      tree_d, n_bit_ind 
  );
  CUDA_POST_KERNEL_CHECK;

  device_free(tree_d);
}

__global__ void kernel_speed1(const ot_tree_t* tree, int n_bit_ind) {
  CUDA_KERNEL_LOOP(bit_idx, n_bit_ind) { 
    int di = tree_n_leafs(tree);
    if(di > 1000000 ) {
      printf("[ERROR_GPU] you summoned an evil demon\n");
    }
  }
}
__global__ void kernel_speed2(const ot_tree_t* tree, int n_bit_ind) {
  CUDA_KERNEL_LOOP(bit_idx, n_bit_ind) { 
    int di = tree_n_leafs2(tree);
    if(di > 1000000 ) {
      printf("[ERROR_GPU] you summoned an evil demon\n");
    }
  }
}

void speed_gpu(ot_tree_t* tree_h) {
  int reps = 100000;
  int n_bit_ind = 1+8+64+64*8;
  
  ot_tree_t* tree_d = host_to_device_malloc(tree_h, N_TREE_INTS);

  kernel_speed1<<<GET_BLOCKS(n_bit_ind), CUDA_NUM_THREADS>>>(tree_d, n_bit_ind);
  auto t1 = std::chrono::high_resolution_clock::now();
  for(int rep = 0; rep < reps; ++rep) {
    kernel_speed1<<<GET_BLOCKS(n_bit_ind), CUDA_NUM_THREADS>>>(tree_d, n_bit_ind);
    CUDA_POST_KERNEL_CHECK;
  }
  auto t2 = std::chrono::high_resolution_clock::now();
  auto time_span = std::chrono::duration_cast<std::chrono::duration<double> >(t2 - t1);
  std::cout << "gpu old took " << time_span.count() << "[s]" << std::endl;

  kernel_speed2<<<GET_BLOCKS(n_bit_ind), CUDA_NUM_THREADS>>>(tree_d, n_bit_ind);
  t1 = std::chrono::high_resolution_clock::now();
  for(int rep = 0; rep < reps; ++rep) {
    kernel_speed2<<<GET_BLOCKS(n_bit_ind), CUDA_NUM_THREADS>>>(tree_d, n_bit_ind);
    CUDA_POST_KERNEL_CHECK;
  }
  t2 = std::chrono::high_resolution_clock::now();
  time_span = std::chrono::duration_cast<std::chrono::duration<double> >(t2 - t1);
  std::cout << "gpu new took " << time_span.count() << "[s]" << std::endl;
  
  device_free(tree_d);
}



int main(int argc, char** argv) {
  std::cout << "[IMPROVE] tree_n_leafs" << std::endl;
  ot_tree_t* tree = new ot_tree_t[N_TREE_INTS];

  //test set 1
  memset(tree, 0, N_TREE_INTS * sizeof(ot_tree_t));
  correctness_cpu(tree);
  correctness_gpu(tree);
  speed_cpu(tree);
  speed_gpu(tree);

  //test set 1
  memset(tree, 0, N_TREE_INTS * sizeof(ot_tree_t));
  tree_set_bit(tree, 0);
  tree_set_bit(tree, 1);
  tree_set_bit(tree, 2);
  tree_set_bit(tree, 9);
  tree_set_bit(tree, 10);
  tree_set_bit(tree, 18);
  correctness_cpu(tree);
  correctness_gpu(tree);
  speed_cpu(tree);
  speed_gpu(tree);

  //test set 2
  memset(tree, 0, N_TREE_INTS * sizeof(ot_tree_t));
  tree_set_bit(tree, 0);
  tree_set_bit(tree, 1);
  tree_set_bit(tree, 9);
  tree_set_bit(tree, 10);
  tree_set_bit(tree, 11);
  tree_set_bit(tree, 4);
  tree_set_bit(tree, 5);
  tree_set_bit(tree, 8);
  tree_set_bit(tree, 65);
  tree_set_bit(tree, 66);
  tree_set_bit(tree, 72);
  correctness_cpu(tree);
  correctness_gpu(tree);
  speed_cpu(tree);
  speed_gpu(tree);

  //test set 3
  memset(tree, 0, N_TREE_INTS * sizeof(ot_tree_t));
  for(int idx = 0; idx < 73; ++idx) { tree_set_bit(tree, idx); }
  correctness_cpu(tree);
  correctness_gpu(tree);
  speed_cpu(tree);
  speed_gpu(tree);

  delete[] tree;
  std::cout << "[DONE]" << std::endl;
  
  return 0;
}
