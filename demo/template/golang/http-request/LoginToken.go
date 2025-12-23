package main

import (
	"crypto/sha512"
	"encoding/json"
	"fmt"
	"log"

	"github.com/parnurzeal/gorequest"
)

func main() {
	request := gorequest.New()
	resp, body, errs := request.
		Post("https://uat-platform.globaltravelrule.com/api/login").
		TLSClientConfig(sharedTLSConfig).
		Send(map[string]string{
			"vaspCode":        "[vaspCode]",
			"accessKey":       "[accessKey]",
			"signedSecretKey": fmt.Sprintf("%x", sha512.Sum512([]byte("[secretKey]"))),
		}).
		End()
	log.Println(resp)
	if errs != nil {
		log.Fatal(errs)
	}

	var loginResponse map[string]map[string]string
	json.Unmarshal([]byte(body), &loginResponse)
	sharedLoginAuth = loginResponse["data"]["jwt"]

	if sharedLoginAuth == "" {
		panic("CANNOT LOGIN, FAILED")
	}

	// Perform GET request with X-Authorization header
	vaspListResp, vaspListBody, errs := request.Get("https://uat-platform.globaltravelrule.com/api/common/v3/vasp/list?showVaspEntities=true").
		TLSClientConfig(sharedTLSConfig).
		Set("Authorization", fmt.Sprintf("Bearer %s", sharedLoginAuth)).
		End()

	if len(errs) > 0 {
		panic(fmt.Errorf("request errors: %v", errs))
	}

	fmt.Printf("Response status: %s\n", vaspListResp.Status)
	fmt.Printf("Response body:\n%s\n", vaspListBody)

}
