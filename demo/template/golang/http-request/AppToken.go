package main

import (
	"crypto/sha512"
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/parnurzeal/gorequest"
)

type AppToken struct {
	SecretToken string `json:"secretToken"`
	AccessKey   string `json:"accessKey"`
	Algorithm   string `json:"algorithm"`
	Nonce       string `json:"nonce"`
	Timestamp   int64  `json:"timestamp"`
	Expires     int    `json:"expires"`
	VerifyType  int    `json:"verifyType"`
}

func generateAppToken(secretKey, vaspCode, accessKey string, expires, verifyType int) (string, error) {
	// Generate nonce (UUID lowercase)
	nonce := strings.ToLower(uuid.New().String())

	// Generate timestamp (milliseconds)
	timestamp := time.Now().UnixNano() / int64(time.Millisecond)

	// Calculate vaspSecretKeyHash = sha512(secretKey + vaspCode)
	vaspSecretKeyHash := sha512Hex(secretKey + vaspCode)

	// Compose stringToSign
	stringToSign := strings.Join([]string{
		accessKey,
		vaspSecretKeyHash,
		nonce,
		fmt.Sprintf("%d", timestamp),
		fmt.Sprintf("%d", expires),
		fmt.Sprintf("%d", verifyType),
	}, "|")

	// Calculate secretToken = sha512(stringToSign)
	secretToken := sha512Hex(stringToSign)

	// Create JSON struct
	token := AppToken{
		SecretToken: secretToken,
		AccessKey:   accessKey,
		Algorithm:   "hmac-sha512",
		Nonce:       nonce,
		Timestamp:   timestamp,
		Expires:     expires,
		VerifyType:  verifyType,
	}

	// Marshal JSON
	jsonBytes, err := json.Marshal(token)
	if err != nil {
		return "", err
	}

	// Base64 encode JSON (no line breaks)
	return base64.StdEncoding.EncodeToString(jsonBytes), nil
}

func sha512Hex(input string) string {
	hash := sha512.Sum512([]byte(input))
	return hex.EncodeToString(hash[:])
}

func main3() {
	secretKey := "[secretKey]"
	vaspCode := "[vaspCode]"
	accessKey := "[accessKey]"
	expires := 120 // 120 second
	verifyType := 1

	appToken, err := generateAppToken(secretKey, vaspCode, accessKey, expires, verifyType)
	if err != nil {
		panic(err)
	}

	fmt.Println(appToken)

	request := gorequest.New()
	// Perform GET request with X-Authorization header
	resp, body, errs := request.Get("https://uat-platform.globaltravelrule.com/api/common/v3/vasp/list?showVaspEntities=true").
		TLSClientConfig(sharedTLSConfig).
		Set("X-Authorization", appToken).
		End()

	if len(errs) > 0 {
		panic(fmt.Errorf("request errors: %v", errs))
	}

	fmt.Printf("Response status: %s\n", resp.Status)
	fmt.Printf("Response body:\n%s\n", body)
}
