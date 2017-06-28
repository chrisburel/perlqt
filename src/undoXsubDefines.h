// XSUB.h creates a lot of #defines for very common function names, that
// interfere with Qt functions.  Including this file undoes the silliness.

#ifdef free
#undef free
#endif

#ifdef connect
#undef connect
#endif

#ifdef accept
#undef accept
#endif
