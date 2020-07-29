
# dmech perf test

this is a simple benchmarking tool for dmech.

## usage

build the application:
+ `dub build`.

then run it (`col` specifies max collisions, `blk` specifies the number of test blocks to create):
```sh
./dmech_perf_test --col 4096 --blk 64
```
