#include <stdint.h>
#include "count/hll.h"

#ifdef _WINDLL
#define DLSHLL_EXPORT extern "C" __declspec(dllexport)
#else
#define DLSHLL_EXPORT extern "C" __attribute((visibility("default")))
#endif


DLSHLL_EXPORT void dlsUpdateHll(int precision, uint8_t* pBytesRegisters,
                                uint64_t hash) {
  auto hll = libcount::HLL::Create(precision, pBytesRegisters);
  hll->Update(hash);
  delete hll;
}
DLSHLL_EXPORT uint64_t dlsEstimateHll(int precision, uint8_t* pBytesRegisters) {
  auto hll = libcount::HLL::Create(precision, pBytesRegisters);
  auto ret = hll->Estimate();
  delete hll;
  return ret;
}

