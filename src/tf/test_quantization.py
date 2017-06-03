import numpy as np

def to_8(M_real, scale, offset):
  result = (M_real / scale - offset).round()
  result[result < 0] = 0
  result[result > 255] = 255
  return result.astype(np.uint8)

def gemm8_32(l, r):
  assert l.dtype == np.uint8
  assert r.dtype == np.uint8
  return np.dot(l.astype(np.uint32), r.astype(np.uint32))

def example():
  lhs_real = np.array([
    [-0.1, 0.4],
    [0.1, 0.2],
  ])
  lhs_scale = 1. / 128
  lhs_offset = -128

  rhs_real = np.array([
    [30.],
    [5.],
  ])
  rhs_scale = 1.
  rhs_offset = 5

  result_scale = 1.
  result_offset = 0.

  lhs8 = to_8(lhs_real, lhs_scale, lhs_offset)
  rhs8 = to_8(rhs_real, rhs_scale, rhs_offset)
  print("As 8bit: {}, {}".format(lhs8, rhs8))

  P = np.ones(lhs8.shape, dtype=np.uint32)
  Q = np.ones(rhs8.shape, dtype=np.uint32)

  lhs_offset_16 = np.int8(lhs_offset)
  rhs_offset_16 = np.int8(rhs_offset)

  terms = (
      gemm8_32(lhs8, rhs8),
      lhs_offset_16 * np.dot(P, rhs8),
      np.dot(lhs8, Q * rhs_offset_16),
      lhs_offset_16 * (rhs_offset_16 * np.dot(P, Q)))
  print("Terms: {}".format(" + ".join(map(str, terms))))

  sum_terms = sum(terms)
  print("Sum of terms: {}".format(sum_terms))

  result_real = (lhs_scale * rhs_scale) * sum_terms
  print("(Q result, FP result): {}\n{}".format(result_real, np.dot(lhs_real, rhs_real)))

  result = result_offset + (lhs_scale * rhs_scale / result_scale) * sum_terms
  print("Final result: {}".format(result))

example()
