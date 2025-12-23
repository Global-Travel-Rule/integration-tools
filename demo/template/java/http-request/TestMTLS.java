package com.your.package;

import org.apache.http.client.config.CookieSpecs;
import org.apache.http.client.config.RequestConfig;
import org.apache.http.client.methods.*;
import org.apache.http.conn.ssl.SSLConnectionSocketFactory;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.DefaultHttpRequestRetryHandler;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.bouncycastle.asn1.pkcs.PrivateKeyInfo;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.bouncycastle.openssl.PEMKeyPair;
import org.bouncycastle.openssl.PEMParser;
import org.bouncycastle.openssl.jcajce.JcaPEMKeyConverter;
import org.junit.Test;
import org.springframework.core.io.ClassPathResource;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.SSLContext;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.security.KeyStore;


import org.apache.http.conn.ssl.TrustStrategy;
import org.apache.http.HttpException;

import java.security.PrivateKey;
import java.security.Security;
import java.security.cert.Certificate;
import java.security.cert.CertificateFactory;
import java.util.Map;
import java.util.concurrent.TimeUnit;


public class TestMTLS {

    @Test
    public void testSendPing() throws HttpException, IOException {
        MTLSHttp http = MTLSHttp.forPEM("certificate.pem", "privateKey.pem");
        String response = http.httpsRequest("https://uat-platform.globaltravelrule.com", Map.of(), "GET", null);
        System.out.println(response);
    }
}



class MTLSHttp {

    private static final int CONNECT_TIMEOUT_MS = 10_000;
    private static final int SOCKET_TIMEOUT_MS = 10_000;

    private final SSLConnectionSocketFactory sslSocketFactory;

    public static MTLSHttp forPKCS12(String requestCertificateFilePath, String requestCertificatePassword) {
        return new MTLSHttp(createSocketFactoryFromPKCS12(requestCertificateFilePath, requestCertificatePassword));
    }


    public static MTLSHttp forPEM(String publicKeyPemPath, String privateKeyPemPath) {
        return new MTLSHttp(createSocketFactoryFromPEM(publicKeyPemPath, privateKeyPemPath));
    }

    public MTLSHttp(SSLConnectionSocketFactory f) {
        this.sslSocketFactory = f;
    }

    public MTLSHttp() {
        this.sslSocketFactory = SSLConnectionSocketFactory.getSocketFactory();
    }

    private static SSLConnectionSocketFactory createSocketFactoryFromPKCS12(String certPath, String certPassword) {
        Security.addProvider(new BouncyCastleProvider());
        try (InputStream keyStoreInputStream = new ClassPathResource(certPath).getInputStream()) {
            KeyStore keyStore = KeyStore.getInstance("PKCS12");
            keyStore.load(keyStoreInputStream, certPassword.toCharArray());

            TrustStrategy trustAllStrategy = (chain, authType) -> true;
            HostnameVerifier allHostsValid = (hostname, session) -> true;

            SSLContext sslContext = org.apache.http.ssl.SSLContexts.custom()
                    .setProtocol("TLSv1.2")
                    .loadKeyMaterial(keyStore, certPassword.toCharArray())
                    .loadTrustMaterial(trustAllStrategy)
                    .build();

            return new SSLConnectionSocketFactory(
                    sslContext,
                    new String[]{"TLSv1.2"},
                    null,
                    allHostsValid);

        } catch (Exception e) {
            throw new RuntimeException("Failed to initialize SSL socket factory from PKCS12", e);
        }
    }

    private static SSLConnectionSocketFactory createSocketFactoryFromPEM(String publicKeyPemPath, String privateKeyPemPath) {
        Security.addProvider(new BouncyCastleProvider());
        try {
            CertificateFactory certFactory = CertificateFactory.getInstance("X.509");
            Certificate cert;
            try (InputStream certInputStream = new ClassPathResource(publicKeyPemPath).getInputStream()) {
                cert = certFactory.generateCertificate(certInputStream);
            }

            PrivateKey privateKey;
            try (InputStream keyInputStream = new ClassPathResource(privateKeyPemPath).getInputStream();
                 InputStreamReader keyReader = new InputStreamReader(keyInputStream);
                 PEMParser pemParser = new PEMParser(keyReader)) {

                Object object = pemParser.readObject();
                JcaPEMKeyConverter converter = new JcaPEMKeyConverter().setProvider("BC");

                if (object instanceof PEMKeyPair) {
                    privateKey = converter.getKeyPair((PEMKeyPair) object).getPrivate();
                } else if (object instanceof PrivateKeyInfo) {
                    privateKey = converter.getPrivateKey((PrivateKeyInfo) object);
                } else {
                    throw new IllegalArgumentException("Unsupported private key format");
                }
            }

            KeyStore keyStore = KeyStore.getInstance("PKCS12");
            keyStore.load(null, null);
            keyStore.setKeyEntry("client", privateKey, "".toCharArray(), new Certificate[]{cert});

            TrustStrategy trustAllStrategy = (chain, authType) -> true;
            HostnameVerifier allHostsValid = (hostname, session) -> true;

            SSLContext sslContext = org.apache.http.ssl.SSLContexts.custom()
                    .setProtocol("TLSv1.2")
                    .loadKeyMaterial(keyStore, "".toCharArray())
                    .loadTrustMaterial(trustAllStrategy)
                    .build();

            return new SSLConnectionSocketFactory(
                    sslContext,
                    new String[]{"TLSv1.2"},
                    null,
                    allHostsValid);

        } catch (Exception e) {
            throw new RuntimeException("Failed to initialize SSL socket factory from PEM files", e);
        }
    }

    private CloseableHttpClient createHttpsClient() {
        return HttpClients.custom()
                .setSSLSocketFactory(this.sslSocketFactory)
                .setConnectionManagerShared(false)
                .evictIdleConnections(1, TimeUnit.MINUTES)
                .evictExpiredConnections()
                .setConnectionTimeToLive(1, TimeUnit.MINUTES)
                .setDefaultRequestConfig(RequestConfig.custom()
                        .setCookieSpec(CookieSpecs.DEFAULT)
                        .setSocketTimeout(SOCKET_TIMEOUT_MS)
                        .setConnectTimeout(CONNECT_TIMEOUT_MS)
                        .setConnectionRequestTimeout(CONNECT_TIMEOUT_MS)
                        .build())
                .setRetryHandler(new DefaultHttpRequestRetryHandler(4, true))
                .build();
    }

    public String httpsRequest(String fullUrl, Map<String, String> headers, String method, String body) throws IOException, HttpException {
        HttpRequestBase request;

        switch (method.toUpperCase()) {
            case "GET":
                request = new HttpGet(fullUrl);
                break;
            case "POST":
                HttpPost post = new HttpPost(fullUrl);
                if (body != null) {
                    post.setEntity(new StringEntity(body, StandardCharsets.UTF_8));
                    post.setHeader("Content-Type", "application/json");
                }
                request = post;
                break;
            case "PUT":
                HttpPut put = new HttpPut(fullUrl);
                if (body != null) {
                    put.setEntity(new StringEntity(body, StandardCharsets.UTF_8));
                    put.setHeader("Content-Type", "application/json");
                }
                request = put;
                break;
            default:
                throw new IOException("Unsupported HTTP method: " + method);
        }

        request.setHeader("Accept", "application/json");

        if (headers != null) {
            headers.forEach(request::setHeader);
        }

        try (CloseableHttpClient client = createHttpsClient();
             CloseableHttpResponse response = client.execute(request)) {

            int statusCode = response.getStatusLine().getStatusCode();
            String responseBody = response.getEntity() != null ? EntityUtils.toString(response.getEntity()) : "";

            if (statusCode >= 200 && statusCode < 300) {
                return responseBody;
            } else {
                throw new HttpException("HTTP request failed with code " + statusCode + ", response: " + responseBody);
            }
        }
    }
}