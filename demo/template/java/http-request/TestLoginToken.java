package com.your.package;

import org.apache.http.HttpException;
import org.json.JSONObject;
import org.junit.Test;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Map;

public class TestLoginToken {

    @Test
    public void testLogin() throws HttpException, IOException, NoSuchAlgorithmException {
        String secretKey = "[secretKey]";
        String vaspCode = "[vaspCode]";
        String accessKey = "[accessKey]";

        String signedSecretKey = sha512Hex(secretKey);

        MTLSHttp http = MTLSHttp.forPEM("certificate.pem", "privateKey.pem");
        String response = http.httpsRequest("https://uat-platform.globaltravelrule.com/api/login", Map.of(), "POST", String.format("{\n" +
                "        \"vaspCode\": \"%s\",\n" +
                "        \"accessKey\": \"%s\",\n" +
                "        \"signedSecretKey\": \"%s\"\n" +
                "    }",
                vaspCode, accessKey, signedSecretKey));
        System.out.println(response);


        // get jwt token
        JSONObject obj = new JSONObject(response);
        JSONObject data = obj.getJSONObject("data");
        String jwt = data.getString("jwt");

        // test get vasp list
        String listResponse = http.httpsRequest("https://uat-platform.globaltravelrule.com/api/common/v3/vasp/list?showVaspEntities=true", Map.of(
                "Authorization", String.format("Bearer %s", jwt)
        ), "GET", null);
        System.out.println(listResponse);
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
