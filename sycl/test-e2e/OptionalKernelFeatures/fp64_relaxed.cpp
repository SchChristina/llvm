// RUN: %clangxx -fsycl -fsycl-targets=%sycl_triple -DOPTIMIZATIONS_DISABLED=0 %s -o %t_opt.out
// RUN: %CPU_RUN_PLACEHOLDER %t_opt.out
// RUN: %GPU_RUN_PLACEHOLDER %t_opt.out
// RUN: %ACC_RUN_PLACEHOLDER %t_opt.out
// RUN: %clangxx -fsycl -fsycl-targets=%sycl_triple -fno-sycl-early-optimizations -DOPTIMIZATIONS_DISABLED=1 %s -o %t_noopt.out
// RUN: %CPU_RUN_PLACEHOLDER %t_noopt.out
// RUN: %GPU_RUN_PLACEHOLDER %t_noopt.out
// RUN: %ACC_RUN_PLACEHOLDER %t_noopt.out

// Tests that aspect::fp64 requirements are affected by optimizations.

#include <sycl/sycl.hpp>

int main() {
  sycl::queue Q;
  try {
    Q.single_task([=]() {
      // Double will be optimized out as LoweredFloat can be set directly to a
      // lowered value.
      double Double = 3.14;
      volatile float LoweredFloat = Double;
    });
#if (OPTIMIZATIONS_DISABLED == 1)
    assert(Q.get_device().has(sycl::aspect::fp64) &&
           "Exception should have been thrown.");
#endif // OPTIMIZATIONS_DISABLED
  } catch (sycl::exception &E) {
    std::cout << "Caught exception: " << E.what() << std::endl;
    assert(OPTIMIZATIONS_DISABLED &&
           "Optimizations should have removed the fp64 requirement.");
    assert(!Q.get_device().has(sycl::aspect::fp64) &&
           "Exception thrown despite fp64 support.");
    assert(E.code() == sycl::errc::kernel_not_supported &&
           "Exception did not have the expected error code.");
  } catch (...) {
    std::cout << "Unexpected exception thrown!" << std::endl;
    throw;
  }

  return 0;
}
