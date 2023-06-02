#include <stdint.h>
#include "count/hll.h"


extern "C" __declspec(dllexport) void dlsUpdateHll(int precision, uint8_t* pBytesRegisters, uint64_t hash) {
	auto hll = libcount::HLL::Create(precision, pBytesRegisters);
	hll->Update(hash);
}
extern "C" __declspec(dllexport) uint64_t dlsEstimateHll(int precision, uint8_t * pBytesRegisters) {
	auto hll = libcount::HLL::Create(precision, pBytesRegisters);
	return hll->Estimate();
}

