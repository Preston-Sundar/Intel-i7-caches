# L1 Data and Instruction caches

## Structure

The L1 cache in the reference diagram in the textbook featured a level-1 instruction and data cache. Both caches are identical in terms of their characteristics, i.e they share the same associativity (8-way) and the same block size. This made implemenation simple and simplified unit testing as well. 

Our L1 instruction and data caches had the following properties:

- write-through (this simplified the actions needed to by the L1 cache upon a write-miss).
- clock based eviction (this was our chosen eviction algorithm, simpler and easier to trace than pseudo LRU).
- 8 64-byte blocks per set, and 64 such sets.

## Implementation

We had two overarching strategies to go abotu implementing our L1 data and instruction caches. The first, which was initialy implemented and later scrapped, was to have one large central memory bank that the parent 'cache' module owned. It would then perform the tag matching and set index calculations, and pass a subset of the memory bank to the child 'set' module. The set module would then perform any reads or writes that were requested by the upper level component, which in the case of L1 was the CPU.

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


