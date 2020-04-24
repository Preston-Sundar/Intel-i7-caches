/**
 * cache.v
 * The main implementation for our cache. We use a large memory bank that has all
 * the memory of the cache. Once we know which set needs to perform the reads and writes,
 * we pass a subset of our memory bank to the set module. The set then performs the specified
 * operation and the cache module manages forwarding and eviction (we think).
 */