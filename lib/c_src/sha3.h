#ifndef _SHA3_H_
#define _SHA3_H_
  extern void sha3_Init256(void *priv); 
  extern void sha3_Init384(void *priv);
  extern void sha3_Init512(void *priv); 
  extern void sha3_Update(void *priv, void const *bufIn, size_t len);
  extern void sha3_Finalize(void *priv); 
#endif