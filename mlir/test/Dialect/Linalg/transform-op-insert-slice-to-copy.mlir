// RUN: mlir-opt -test-transform-dialect-interpreter %s --split-input-file | FileCheck %s

// CHECK-LABEL: func @insert_slice_to_copy
    // CHECK-SAME: %[[I:.*]]: tensor<2x3xf32>
    // CHECK-SAME: %[[O:.*]]: tensor<?x?xf32>, 
    // CHECK-SAME: %[[OFF0:[0-9a-zA-Z]+]]: index,
    // CHECK-SAME: %[[OFF1:[0-9a-zA-Z]+]]: index,
    // CHECK-SAME: %[[SZ0:[0-9a-zA-Z]+]]: index,
    // CHECK-SAME: %[[SZ1:[0-9a-zA-Z]+]]: index,
    // CHECK-SAME: %[[ST0:[0-9a-zA-Z]+]]: index,
    // CHECK-SAME: %[[ST1:[0-9a-zA-Z]+]]: index)
func.func @insert_slice_to_copy(
    %I : tensor<2x3xf32>, %O : tensor<?x?xf32>, 
    %off0 : index, %off1 : index,
    %sz0 : index, %sz1 : index,
    %st0 : index, %st1 : index) -> tensor<?x?xf32> {

  //      CHECK: %[[EXTRACTED_SLICE:.*]] = tensor.extract_slice %[[O]][%[[OFF0]], %[[OFF1]]] [2, 3] [%[[ST0]], %[[ST1]]] 
  // CHECK-SAME:   : tensor<?x?xf32> to tensor<2x3xf32>
  //      CHECK: linalg.copy ins(%[[I]] : tensor<2x3xf32>) outs(%[[EXTRACTED_SLICE]] : tensor<2x3xf32>) -> tensor<2x3xf32>
  //      CHECK: tensor.insert_slice %{{.*}} into %[[O]][%[[OFF0]], %[[OFF1]]] [2, 3] [%[[ST0]], %[[ST1]]]
  // CHECK-SAME:   : tensor<2x3xf32> into tensor<?x?xf32>

  %0 = tensor.insert_slice %I into %O[%off0, %off1] [2, 3] [%st0, %st1] 
    : tensor<2x3xf32> into tensor<?x?xf32>
  return %0 : tensor<?x?xf32>
}

transform.sequence failures(propagate) {
^bb1(%arg1: !transform.any_op):
  %0 = transform.structured.match ops{["tensor.insert_slice"]} in %arg1 : (!transform.any_op) -> !transform.any_op
  %1 = transform.structured.insert_slice_to_copy %0 : (!transform.any_op) -> !transform.any_op
  transform.cast %1 : !transform.any_op to !transform.op<"linalg.copy">
}

// -----

// CHECK-LABEL: func @insert_slice_to_copy
    // CHECK-SAME: %[[I:[0-9a-zA-Z]+]]: tensor<?x?xf32>
    // CHECK-SAME: %[[O:[0-9a-zA-Z]+]]: tensor<?x?xf32>, 
    // CHECK-SAME: %[[OFF0:[0-9a-zA-Z]+]]: index,
    // CHECK-SAME: %[[OFF1:[0-9a-zA-Z]+]]: index,
    // CHECK-SAME: %[[SZ0:[0-9a-zA-Z]+]]: index,
    // CHECK-SAME: %[[SZ1:[0-9a-zA-Z]+]]: index,
    // CHECK-SAME: %[[ST0:[0-9a-zA-Z]+]]: index,
    // CHECK-SAME: %[[ST1:[0-9a-zA-Z]+]]: index)
func.func @insert_slice_to_copy(
    %I : tensor<?x?xf32>, %O : tensor<?x?xf32>, 
    %off0 : index, %off1 : index,
    %sz0 : index, %sz1 : index,
    %st0 : index, %st1 : index) -> tensor<?x?xf32> {

  //      CHECK: %[[EXTRACTED_SLICE:.*]] = tensor.extract_slice %[[O]][%[[OFF0]], %[[OFF1]]] [%[[SZ0]], %[[SZ1]]] [1, 1] 
  // CHECK-SAME:   : tensor<?x?xf32> to tensor<?x?xf32>
  //      CHECK: linalg.copy ins(%[[I]] : tensor<?x?xf32>) outs(%[[EXTRACTED_SLICE]] : tensor<?x?xf32>) -> tensor<?x?xf32>
  //      CHECK: tensor.insert_slice %{{.*}} into %[[O]][%[[OFF0]], %[[OFF1]]] [%[[SZ0]], %[[SZ1]]] [1, 1]
  // CHECK-SAME:   : tensor<?x?xf32> into tensor<?x?xf32>

  %0 = tensor.insert_slice %I into %O[%off0, %off1] [%sz0, %sz1] [1, 1] 
    : tensor<?x?xf32> into tensor<?x?xf32>
  return %0 : tensor<?x?xf32>
}

transform.sequence failures(propagate) {
^bb1(%arg1: !transform.any_op):
  %0 = transform.structured.match ops{["tensor.insert_slice"]} in %arg1 : (!transform.any_op) -> !transform.any_op
  %1 = transform.structured.insert_slice_to_copy %0 : (!transform.any_op) -> !transform.any_op
  transform.cast %1 : !transform.any_op to !transform.op<"linalg.copy">
}

// -----
// CHECK-LABEL: func @insert_slice_to_copy
    // CHECK-SAME: %[[I:.*]]: tensor<2x3xf32>
    // CHECK-SAME: %[[O:.*]]: tensor<?x?xf32>, 
    // CHECK-SAME: %[[OFF0:[0-9a-zA-Z]+]]: index,
    // CHECK-SAME: %[[OFF1:[0-9a-zA-Z]+]]: index,
    // CHECK-SAME: %[[SZ0:[0-9a-zA-Z]+]]: index,
    // CHECK-SAME: %[[SZ1:[0-9a-zA-Z]+]]: index,
    // CHECK-SAME: %[[ST0:[0-9a-zA-Z]+]]: index,
    // CHECK-SAME: %[[ST1:[0-9a-zA-Z]+]]: index)
func.func @insert_slice_to_copy(
    %I : tensor<2x3xf32>, %O : tensor<?x?xf32>, 
    %off0 : index, %off1 : index,
    %sz0 : index, %sz1 : index,
    %st0 : index, %st1 : index) -> tensor<?x?xf32> {

  //      CHECK: %[[EXTRACTED_SLICE:.*]] = tensor.extract_slice %[[O]][%[[OFF0]], %[[OFF1]]] [2, 3] [%[[ST0]], %[[ST1]]] 
  // CHECK-SAME:   : tensor<?x?xf32> to tensor<2x3xf32>
  //      CHECK: linalg.copy ins(%[[I]] : tensor<2x3xf32>) outs(%[[EXTRACTED_SLICE]] : tensor<2x3xf32>) -> tensor<2x3xf32>
  //  CHECK-NOT: linalg.copy
  //      CHECK: tensor.insert_slice %{{.*}} into %[[O]][%[[OFF0]], %[[OFF1]]] [2, 3] [%[[ST0]], %[[ST1]]]
  // CHECK-SAME:   : tensor<2x3xf32> into tensor<?x?xf32>

  %extracted_slice = tensor.extract_slice %O[%off0, %off1] [2, 3] [%st0, %st1] 
    : tensor<?x?xf32> to tensor<2x3xf32>
  %0 = linalg.copy ins(%I : tensor<2x3xf32>) outs(%extracted_slice 
    : tensor<2x3xf32>) -> tensor<2x3xf32>
  %inserted_slice = tensor.insert_slice %0 into %O[%off0, %off1] [2, 3] [%st0, %st1] 
    : tensor<2x3xf32> into tensor<?x?xf32>

  return %inserted_slice : tensor<?x?xf32>
}

transform.sequence failures(propagate) {
^bb1(%arg1: !transform.any_op):
  %0 = transform.structured.match ops{["tensor.insert_slice"]} in %arg1 : (!transform.any_op) -> !transform.any_op
  %1 = transform.structured.insert_slice_to_copy %0 : (!transform.any_op) -> !transform.any_op
  transform.cast %1 : !transform.any_op to !transform.op<"linalg.copy">
}

