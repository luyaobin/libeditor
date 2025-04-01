#ifndef CAES_H
#define CAES_H

#include "aes.h"

#ifndef NULL
#define NULL 0
#endif

class CAes
{
public:
    CAes(unsigned char *pKey, int keyLen);
    ~CAes();

    bool IsValid() const { return w != NULL; }

    bool FillPadding(unsigned char *pPadding, int paddingLen, int paddingType);
    int PaddingLength(unsigned char *pPadding, int paddingType);

    bool Encrypt(unsigned char *pData, int dataLen);
    bool Decrypt(unsigned char *pData, int dataLen);

private:
    void KeyExpansion(unsigned char *pKey);
    unsigned char FFmul(unsigned char a, unsigned char b);

    void SubBytes(unsigned char *pState);
    void ShiftRows(unsigned char *pState);
    void MixColumns(unsigned char *pState);
    void AddRoundKey(unsigned char *pState, unsigned char *pBlock);

    void InvSubBytes(unsigned char *pState);
    void InvShiftRows(unsigned char *pState);
    void InvMixColumns(unsigned char *pState);

    void Cipher(unsigned char* pInput);
    void InvCipher(unsigned char* pInput);

private:
    typedef unsigned int uint32;
    const int Nb;
    int Nr;
    int Nk;
    unsigned char *w;
};


#endif // CAES_H
