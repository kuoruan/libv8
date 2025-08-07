# The build args for V8

From the following url: https://groups.google.com/g/v8-dev/c/ARRqwWSm0eA

`use_custom_libcxx = false` and `is_clang = false` are deprecated, should not be used.

And the `v8_enable_temporal_support` should be disabled, it is a very new feature and depends on rust rlibs.


## Refs

  * https://chromium.googlesource.com/v8/node-ci/+/refs/heads/master/.gn
  * https://v8.dev/docs/compile-arm64
  * https://v8.dev/docs/cross-compile-ios
