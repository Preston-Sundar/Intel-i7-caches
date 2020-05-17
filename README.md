# L1 Data and Instruction caches

## Structure

The L1 cache in the reference diagram in the textbook featured a level-1 instruction and data cache. Both caches are identical in terms of their characteristics, i.e they share the same associativity (8-way) and the same block size. This made implemenation simple and simplified unit testing as well. 

Our L1 instruction and data caches had the following properties:

- write-through (this simplified the actions needed to by the L1 cache upon a write-miss).
- clock based eviction (this was our chosen eviction algorithm, simpler and easier to trace than pseudo LRU).
- 8 64-byte blocks per set, and 64 such sets.

## Implementation

We had two overarching strategies to go about implementing our L1 data and instruction caches. The first, which was initialy implemented and later scrapped, was to have one large central memory bank that the parent 'cache' module owned. It would then perform the tag matching and set index calculations, and pass a subset of the memory bank to the child 'set' module. The set module would then perform any reads or writes that were requested by the upper level component, which in the case of L1 was the CPU.

This approach however was dropped in favour of one that would preserve the true functionality of the set, as we learned in class. Instead of tag matching outside the set module, our parent cache would only calculate the set index and pass that information to the set module. The main memory bank is now placed inside of the set module instead of being in the cache module. This made the code at the cache level very simple and also made unit testing the set module in isolation straighforward.

Here is the structure of the L1 code in isolation: 


```
L1 Caches
│   cachebench.v    
│
└───Cache
│   │   cache.c
│   │   
│   │
│   └───Set
│       │   set.v
│       │   setbench.v
│   
└───Set unit tests
    │   set.v
    │   bench.v
```


## Parameters

Here is our L1 cache declaration which was declared between L2 and the CPU itself.

```verilog
L1 l1_data(clk, CPU_ENABLE, ENABLE, READ_IN, write_enable_in, write_data_in, address_in, write_size_in, data_in, CLF,data_out, write_enable_out, 
write_data_out, address_out, write_size_out, CLF_out, nops);
```


- **clk**: clock from the top-level module used to sychronize with all the other components.
- **CPU_ENABLE**: Used to indicate back to the CPU that its requested data/instruction is ready.
- **ENABLE**: When the enable line is set, a cache at a lower level is ready to forward data to L1.
- **READ_IN**: When the read_in line is set, our cache can perform its actions.
- **write_enable_in**: determines if the instruction is a read or write.
- **write_data_in**: The data we will be writing to the cache.
- **address_in**: specifies the address to read/write to. Its broken up into the tag, set index, and block offset as shown later on.
- **write_size_in**: specifies the size of the cache memory operand (8bits, 16bits, 32bits, 64bits).
- **data_in**: The data forwarded to L1 from the next level cache L2.
- **CLF**: Cache Line Flush is used to empty out a cache line, made debugging easier.
- **data_out**: the data we send to the CPU once its ready.
- **write_enable_out**: the forwarded write enable we send to the next level cache.
- **write_data_out**: the forwarded data we send to the next level cache.
- **address_out**: the forwarded address we send to the next level cache.
- **CLF_out**: the forwarded Cache Line Flush we send to the next level cache.
- **nops**: Used for debugging, it specified the current operation number.



