#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

/**
 * Opaque `SCNetworkReachabilityRef` (a CoreFoundation type).
 */
typedef const void *SCNetworkReachabilityRef;

extern SCNetworkReachabilityRef SCNetworkReachabilityCreateWithAddress(const void *allocator,
                                                                       const sockaddr *address);

extern uint8_t SCNetworkReachabilityGetFlags(SCNetworkReachabilityRef target, uint32_t *flags);

extern void CFRelease(const void *cf);
