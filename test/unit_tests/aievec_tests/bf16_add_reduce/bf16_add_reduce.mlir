// RUN: aie-opt %s -affine-super-vectorize="virtual-vector-size=16 test-fastest-varying=0 vectorize-reductions=true" --convert-vector-to-aievec="aie-target=aieml" -lower-affine | aie-translate -aieml=true --aievec-to-cpp -o dut.cc
// RUN: xchesscc_wrapper aie2 -f -g +s +w work +o work -I%S -I. %S/testbench.cc dut.cc
// RUN: mkdir -p data
// RUN: xme_ca_udm_dbg -qf -T -P %aietools/data/aie_ml/lib/ -t "%S/../profiling.tcl ./work/a.out" >& xme_ca_udm_dbg.stdout
// RUN: FileCheck --input-file=./xme_ca_udm_dbg.stdout %s
// CHECK: TEST PASSED

module {
func.func @dut(%arg0: memref<1024xbf16>, %arg1: memref<bf16>) {
    %cst = arith.constant 0.000000e+00 : bf16
    %0 = affine.for %arg2 = 0 to 1024 iter_args(%arg3 = %cst) -> (bf16) {
      %1 = affine.load %arg0[%arg2] : memref<1024xbf16>
      %2 = arith.addf %arg3, %1 : bf16
      affine.yield %2 : bf16
    }
    affine.store %0, %arg1[] : memref<bf16>
    return
  }
}
