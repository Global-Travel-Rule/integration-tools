package main

import (
	"crypto/tls"
	"crypto/x509"
	"encoding/pem"
	"errors"
	"fmt"
	"io/ioutil"
	"log"
)

var sharedTLSConfig *tls.Config
var sharedLoginAuth string

func init() {
	certPool := x509.NewCertPool()

	sharedClientCertificate, err := loadCertAndKey("./certificate.pem", "./privateKey.pem")
	if err != nil {
		panic(err)
	}

	sharedTLSConfig = &tls.Config{
		InsecureSkipVerify: true,
		ClientAuth:         tls.RequireAndVerifyClientCert,
		ClientCAs:          certPool,
		VerifyPeerCertificate: func(rawCerts [][]byte, verifiedChains [][]*x509.Certificate) error {
			opts := x509.VerifyOptions{
				Roots:         certPool,
				Intermediates: certPool,
			}
			for _, chain := range verifiedChains {
				for _, cert := range chain {
					if _, err := cert.Verify(opts); err != nil {
						// certificate is not in the whitelist
						log.Println(err)
					}
				}
			}
			// verify has pass
			return nil
		},
		VerifyConnection: func(cs tls.ConnectionState) error {
			return nil
		},
		Certificates: []tls.Certificate{sharedClientCertificate},
		MinVersion:   tls.VersionTLS12,
		MaxVersion:   tls.VersionTLS12,
	}
}

func loadPrivateKey(filename string) (interface{}, error) {
	keyPEM, err := ioutil.ReadFile(filename)
	if err != nil {
		return nil, err
	}

	block, _ := pem.Decode(keyPEM)
	if block == nil {
		return nil, errors.New("failed to decode PEM block containing private key")
	}

	switch block.Type {
	case "RSA PRIVATE KEY":
		return x509.ParsePKCS1PrivateKey(block.Bytes)
	case "PRIVATE KEY":
		return x509.ParsePKCS8PrivateKey(block.Bytes)
	default:
		return nil, fmt.Errorf("unsupported private key type: %s", block.Type)
	}
}

func loadCertsRaw(filename string) ([][]byte, error) {
	certPEM, err := ioutil.ReadFile(filename)
	if err != nil {
		return nil, err
	}

	var certs [][]byte
	rest := certPEM
	for {
		var block *pem.Block
		block, rest = pem.Decode(rest)
		if block == nil {
			break
		}
		if block.Type == "CERTIFICATE" {
			certs = append(certs, block.Bytes)
		}
	}

	if len(certs) == 0 {
		return nil, errors.New("no certificates found")
	}
	return certs, nil
}

func loadCertAndKey(certFile, keyFile string) (tls.Certificate, error) {
	privKey, err := loadPrivateKey(keyFile)
	if err != nil {
		return tls.Certificate{}, err
	}

	certs, err := loadCertsRaw(certFile)
	if err != nil {
		return tls.Certificate{}, err
	}

	return tls.Certificate{
		Certificate: certs,
		PrivateKey:  privKey,
	}, nil
}
