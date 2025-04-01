#ifndef AES_H
#define AES_H

#include <QtCore/QtGlobal>

#if defined(AES_LIBRARY)
#  define AESSHARED_EXPORT Q_DECL_EXPORT
#else
#  define AESSHARED_EXPORT Q_DECL_IMPORT
#endif

#ifdef Q_OS_UNIX
# define __STDCALL
#else
# define __STDCALL __stdcall
#endif

#ifdef __cplusplus
extern "C" {
#endif

enum AES_Padding {
    AES_Padding_Zeros = 1,  // 待填充区域的每个字节填入0
    AES_Padding_PKCS5,      // 待填充区域的每个字节填入该区域的长度
    AES_Padding_PKCS7,      // 待填充区域的每个字节填入该区域的长度
    AES_Padding_ANSIX923 ,  // 待填充区域的最后一个字节填入该区域的长度，其余字节填入0
    AES_Padding_ISO10126    // 待填充区域的最后一个字节填入该区域的长度，其余字节填入随机数

/*
      例： 数据内容 FF FF FF FF FF FF FF FF FF
           数据长度 9

           Zeros    填充： FF FF FF FF FF FF FF FF FF 00 00 00 00 00 00 00
           PKCS5    填充： FF FF FF FF FF FF FF FF FF 07 07 07 07 07 07 07
           PKCS7    填充： FF FF FF FF FF FF FF FF FF 07 07 07 07 07 07 07
           ANSIX923 填充： FF FF FF FF FF FF FF FF FF 00 00 00 00 00 00 07
           ISO10126 填充： FF FF FF FF FF FF FF FF FF 7D 2A 75 EF F8 EF 07

      注意：
        如果待加密文本长度刚好是16的倍数则要增加16个字节
*/

};

enum AES_Key {
    AES_Key_128 = 16,
    AES_Key_192 = 24,
    AES_Key_256 = 32
};

/*
    功能：AesEncrypt（加密） AesDecrypt（解密）
    pData：        入参 待加解密数据 != NULL
    dataLen：      入参 待加解密数据长度 > 0
    pKey：         入参 秘钥数据 != NULL
    keyLen：       入参 秘钥数据长度 AES_Key
    pOutData：     出参 加解密后数据，若失败则返回 NULL
    outDataLen：   出参 加解密后数据长度，若失败则返回 0
    szOutFileName：出参 加解密后文件名
    modeType：     入参 加解密模式 AES_Mode
    paddingType：  入参 数据补齐类型 AES_Padding
    返回值：            返回函数执行结果（=0则成功，否则失败）
*/

int AesEncrypt(char *pData, int dataLen, char *pKey, int keyLen, char *&pOutData, int &outDataLen, int paddingType = AES_Padding_PKCS7);

int AesDecrypt(char *pData, int dataLen, char *pKey, int keyLen, char *&pOutData, int &outDataLen, int paddingType = AES_Padding_PKCS7);

int AesEncryptSimple(char *pData, int dataLen, char *&pOutData, int &outDataLen);

int AesDecryptSimple(char *pData, int dataLen, char *&pOutData, int &outDataLen);

int LoginAesEncryptSimple(char *pData, int dataLen, char *&pOutData, int &outDataLen);

int LoginAesDecryptSimple(char *pData, int dataLen, char *&pOutData, int &outDataLen);


void AesOutDataDelete(char *pOutData);


#ifdef __cplusplus
} // extern "C"
#endif

#endif // AES_H

