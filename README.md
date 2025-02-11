Keillion has modified this branch for some specific projects, which may cause this library to be unsuitable for other projects. Please choose carefully. It is recommended to use the original repository https://github.com/dialtr/libcount.

```shell
gcc -c -fPIC ./dlshll.cpp ./count/empirical_data.cc ./count/hll.cc ./count/hll_data.cc ./count/utility.cc -I ./ -I ./include/
gcc -shared *.o -o libdlshll.so
```

If gcc not support `auto`, add `-std=c++11`.

(TODO: check gcc or g++)

For working on multiple platforms and libraries compability, use `-static-libstdc++ -fvisibility=hidden -Wl,-Bsymbolic` in linking.

----

# libcount

The goal of libcount is to provide a complete C/C++ implementation of the
HyperLogLog++ cardinality estimation algorithm, as described in the paper:
"HyperLogLog in Practice: Algorithmic Engineering of a State of the Art
Cardinality Estimation Algorithm" by Heule, Nunkesser, and Hall.

The current (alpha) implementation does not implement sparse register
storage as described in the paper referenced above; it employs a flat
array of 8 bit registers, and thus the storage required to calculate
cardinality is approximately (precision ^ 2) bytes.

The author of the library is investigating whether there is substantial
benefit to sparse storage for normal use cases. Since the worst case
usage is approximately 256Kb, in light of today's typical memory
configurations, it is not a priority at this time.

This library has not been thoroughly reviewed or tested at this time.

Both C and C++ interfaces are available. The examples below demonstrate use.

## Current Status

This library is currently in ALPHA.

## Building

    git clone https://github.com/dialtr/libcount
    cd libcount
    make
    sudo make install

## Testing

At the present time, **libcount** doesn't have a significant number of unit
tests. This will be rectified in a forthcoming version. At present, there
is one unit test that validates the empirical data table used internally.
To run this test, simply type:

    make check

You can also run a suite that runs several simulations at every precision
value to certify that libcount is doing a reasonable job estimating the
cardinality of sets. Just type:

    make certify

## Minimal Examples

Below are two minimal examples that demonstrate using the C++ and C APIs,
respectively. More realistic examples that employ a high quality hash
algorithm can be found in the examples/ directory at the root of the repo.

To build the examples, simply:

    make examples

They are not built by default because they depend on the OpenSSL libraries
being available on the system, and since those libraries are not installed
by default on many systems, building them is "opt-in." On Ubuntu, the SSL
package required is: 'libssl-dev'.

### C++
```C++
#include <count/hll.h>

using libcount::HLL;

uint64_t Hash(int x) {
  // Users of this library should provide a good hash function
  // for hashing objects that are being counted. One suggestion
  // is to use a cryptographic hash function (SHA1, MD5, etc)
  // and return a subset of those bits.
  return x;
}

int main(int argc, char* argv[]) {
  const int kPrecision = 8;

  // Create an HLL object to track set cardinality.
  HLL* hll = HLL::Create(kPrecision);

  // Update object with hash of each element in your set.
  const kNumItems = 10000;
  for (int i = 0; i < kNumItems; ++i) {
    hll->Update(Hash(i));
  }

  // Obtain the cardinality estimate.
  uint64_t estimate = hll->Estimate();

  // Delete object.
  delete hll;
  
  return 0;
}
```

### C
```C
#include <count/c.h>

uint64_t Hash(int x) {
  // Users of this library should provide a good hash function
  // for hashing objects that are being counted. One suggestion
  // is to use a cryptographic hash function (SHA1, MD5, etc)
  // and return a subset of those bits.
  return x;
}

int main(int argc, char* argv[]) {
  const int kPrecision = 8;
  int error = 0;

  // Create an HLL object to track set cardinality.
  hll_t* hll = HLL_create(kPrecision, &error);

  // Update object with hash of each element in your set.
  const kNumItems = 10000;
  for (int i = 0; i < kNumItems; ++i) {
    HLL_update(hll, Hash(i));
  }

  // Obtain the cardinality estimate.
  uint64_t estimate = HLL_estimate(hll);

  // Free object
  HLL_free(hll);

  return 0;
}
```

## Contact
Please see AUTHORS in the root of the repository for contact information.

## Contributing
I would enjoy working with people who may be interested in contributing. I am
also interested in learning how the library is being used and whether any
other features may be desirable.

## Dependencies
The libcount.a library has no dependencies outside of the standard C/C++
libraries. Maintaining this property is a design goal.

The examples currently require OpenSSL/crypto due to their use of the SHA1
hash functions. Future unit tests will also likely require this library.

## Future Planned Development
* Additional tests
* Rethink the interface(s) for Version 2
* Examine whether changes are needed or desirable for modern C++.
* Sparse "register" storage
