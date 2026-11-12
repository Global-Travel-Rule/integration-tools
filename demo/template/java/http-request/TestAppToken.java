package com.your.package;

import org.apache.http.HttpException;
import org.junit.Test;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;
import java.util.Map;
import java.util.UUID;

public class TestAppToken {

    String secretKey = "[secretKey]";
    String vaspCode = "[vaspCode]";
    String accessKey = "[accessKey]";
    int expires = 120; // 120 second
    int verifyType = 1;


    @Test
    public void testGenerateToken() {
        String appToken = AppTokenGenerator.generateAppToken(secretKey, vaspCode, accessKey, expires, verifyType);
        System.out.println(appToken);
    }


    @Test
    public void testApiWithAppToken() throws HttpException, IOException {
        String appToken = AppTokenGenerator.generateAppToken(secretKey, vaspCode, accessKey, expires, verifyType);

        MTLSHttp http = MTLSHttp.forPEM("certificate.pem", "privateKey.pem");
        String response = http.httpsRequest("https://uat-platform.globaltravelrule.com/api/common/v3/vasp/list?showVaspEntities=true", Map.of(
                "X-Authorization", appToken
        ), "GET", null);
        System.out.println(response);
    }
}


class AppTokenGenerator {

    public static String generateAppToken(String secretKey, String vaspCode, String accessKey, int expires, int verifyType) {
        try {
            // 產生 nonce (UUID 小寫)
            String nonce = UUID.randomUUID().toString().toLowerCase();

            // 產生 timestamp (13位毫秒)
            long timestamp = System.currentTimeMillis();

            // 計算 vaspSecretKeyHash = sha512(secretKey + vaspCode)
            String vaspSecretKeyHash = sha512Hex(secretKey + vaspCode);

            // 組合待簽字串
            String stringToSign = String.join("|",
                    accessKey,
                    vaspSecretKeyHash,
                    nonce,
                    String.valueOf(timestamp),
                    String.valueOf(expires),
                    String.valueOf(verifyType)
            );

            // 計算 SecretToken = sha512(stringToSign)
            String secretToken = sha512Hex(stringToSign);

            // 組成 JSON 字串
            String json = String.format(
                    "{\"secretToken\":\"%s\",\"accessKey\":\"%s\",\"algorithm\":\"hmac-sha512\",\"nonce\":\"%s\",\"timestamp\":\"%d\",\"expires\":%d,\"verifyType\":%d}",
                    secretToken, accessKey, nonce, timestamp, expires, verifyType
            );

            // Base64 編碼 JSON (無換行)
            return Base64.getEncoder().encodeToString(json.getBytes(StandardCharsets.UTF_8));

        } catch (Exception e) {
            throw new RuntimeException("Failed to generate AppToken", e);
        }
    }

    private static String sha512Hex(String input) throws NoSuchAlgorithmException {
        MessageDigest md = MessageDigest.getInstance("SHA-512");
        byte[] digest = md.digest(input.getBytes(StandardCharsets.UTF_8));
        return bytesToHex(digest);
    }

    private static String bytesToHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder(bytes.length * 2);
        for (byte b : bytes) {
            sb.append(String.format("%02x", b & 0xff));
        }
        return sb.toString();
    }
}