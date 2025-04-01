#include "aes.h"
#include "caes.h"
#include <string.h>

extern "C" {

int AesEncrypt(char *pData, int dataLen, char *pKey, int keyLen, char *&pOutData, int &outDataLen, int paddingType /*= AES_Padding_PKCS7*/)
{
    if (pData == NULL || dataLen <= 0)
        return -1;

    CAes aes((unsigned char*)pKey, keyLen);
    if (!aes.IsValid() || !aes.FillPadding(NULL, 0, paddingType))
        return -2;

    outDataLen = ((dataLen >> 4) + 1) << 4;

    pOutData = new char[outDataLen];
    memcpy(pOutData, pData, dataLen);

    aes.FillPadding((unsigned char*)pOutData + dataLen, outDataLen - dataLen, paddingType);
    aes.Encrypt((unsigned char*)pOutData, outDataLen);

    return 0;
}

int AesDecrypt(char *pData, int dataLen, char *pKey, int keyLen, char *&pOutData, int &outDataLen, int paddingType /*= AES_Padding_PKCS7*/)
{
    if (pData == NULL || dataLen <= 0 || (dataLen % 16 != 0))
        return -1;

    CAes aes((unsigned char*)pKey, keyLen);
    if (!aes.IsValid() || !aes.FillPadding(NULL, 0, paddingType))
        return -2;

    pOutData = new char[dataLen];
    memcpy(pOutData, pData, dataLen);

    aes.Decrypt((unsigned char*)pOutData, dataLen);

    int paddingLen = aes.PaddingLength((unsigned char*)pOutData + dataLen - 16, paddingType);
    outDataLen = dataLen - paddingLen;

    return 0;
}

int AesEncryptSimple(char *pData, int dataLen, char *&pOutData, int &outDataLen)
{
    char  chiper []= "92CF7BDD390643569C62C4C37EF4C90F";
    return AesEncrypt(pData, dataLen, chiper, 32, pOutData, outDataLen, AES_Padding_PKCS7);
}

int AesDecryptSimple(char *pData, int dataLen, char *&pOutData, int &outDataLen)
{
    char  chiper []= "92CF7BDD390643569C62C4C37EF4C90F";
    return AesDecrypt(pData, dataLen, chiper, 32, pOutData, outDataLen, AES_Padding_PKCS7);
}

int LoginAesEncryptSimple(char *pData, int dataLen, char *&pOutData, int &outDataLen)
{
    char  chiper []= "F09C4FE73C4C26C965346093DDB7FC29";
    return AesEncrypt(pData, dataLen, chiper, 32, pOutData, outDataLen, AES_Padding_PKCS7);
}

int LoginAesDecryptSimple(char *pData, int dataLen, char *&pOutData, int &outDataLen)
{
    char  chiper []= "F09C4FE73C4C26C965346093DDB7FC29";
    return AesDecrypt(pData, dataLen, chiper, 32, pOutData, outDataLen, AES_Padding_PKCS7);
}

void AesOutDataDelete(char *pOutData)
{
    delete []pOutData;
}


} // extern "C"
