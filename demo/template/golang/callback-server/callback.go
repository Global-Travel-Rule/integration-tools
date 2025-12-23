package main

import (
	"encoding/json"
	"net/http"
	"sync"

	"github.com/gin-gonic/gin"
)

// GtrCallbackResponse generic response struct
type GtrCallbackResponse[T any] struct {
	Data          *T     `json:"data,omitempty"`
	VerifyMessage string `json:"verifyMessage"`
	VerifyStatus  int    `json:"verifyStatus"`
}

func Success[T any]() GtrCallbackResponse[T] {
	return GtrCallbackResponse[T]{
		Data:          nil,
		VerifyMessage: "success",
		VerifyStatus:  100000,
	}
}

func SuccessWithData[T any](data T) GtrCallbackResponse[T] {
	return GtrCallbackResponse[T]{
		Data:          &data,
		VerifyMessage: "success",
		VerifyStatus:  100000,
	}
}

func SuccessWithMessage[T any](message string) GtrCallbackResponse[T] {
	return GtrCallbackResponse[T]{
		Data:          nil,
		VerifyMessage: message,
		VerifyStatus:  100000,
	}
}

func SuccessWithMessageAndData[T any](message string, data T) GtrCallbackResponse[T] {
	return GtrCallbackResponse[T]{
		Data:          &data,
		VerifyMessage: message,
		VerifyStatus:  100000,
	}
}

func Fail[T any](statusCode int, message string) GtrCallbackResponse[T] {
	return GtrCallbackResponse[T]{
		Data:          nil,
		VerifyMessage: message,
		VerifyStatus:  statusCode,
	}
}

func FailWithData[T any](statusCode int, message string, data T) GtrCallbackResponse[T] {
	return GtrCallbackResponse[T]{
		Data:          &data,
		VerifyMessage: message,
		VerifyStatus:  statusCode,
	}
}

// EntityConfig holds VASP entity configuration
type EntityConfig struct {
	VaspCode    string `json:"vaspCode"`
	CompanyName string `json:"companyName"`
	CountryCode string `json:"countryCode"`
}

// GtrCheckAddressExistsRequest address verification request struct
type GtrCheckAddressExistsRequest struct {
	RequestId          string `json:"requestId"`
	OriginatorVasp     string `json:"originatorVasp"`
	OriginatorVaspName string `json:"originatorVaspName"`
	Address            string `json:"address"`
	Tag                string `json:"tag"`
	Network            string `json:"network"`
	InitiatorVasp      string `json:"initiatorVasp"`
}

func main() {
	r := gin.Default()

	// Simulate entity config storage
	entities := sync.Map{}
	entities.Store("[vaspCode]", EntityConfig{
		VaspCode:    "[vaspCode]",
		CompanyName: "Axchagne Global",
		CountryCode: "GLOBAL",
	})
	entities.Store("[vaspCode2]", EntityConfig{
		VaspCode:    "[vaspCode2]",
		CompanyName: "Axchagne India",
		CountryCode: "JP",
	})

	r.POST("/callback", func(c *gin.Context) {
		var rawRequest map[string]interface{}
		if err := c.ShouldBindJSON(&rawRequest); err != nil {
			c.JSON(http.StatusBadRequest, Fail[any](100001, "empty or invalid request body"))
			return
		}

		// Validate callbackType
		callbackTypeVal, ok := rawRequest["callbackType"]
		if !ok {
			c.JSON(http.StatusBadRequest, Fail[any](100001, "callbackType cannot be null"))
			return
		}
		callbackTypeFloat, ok := callbackTypeVal.(float64)
		if !ok {
			c.JSON(http.StatusBadRequest, Fail[any](100001, "callbackType invalid"))
			return
		}
		callbackType := int(callbackTypeFloat)

		// Validate invokeVaspCode
		invokeVaspCodeVal, ok := rawRequest["invokeVaspCode"]
		if !ok {
			c.JSON(http.StatusBadRequest, Fail[any](100030, "invoke vasp code does not exists in this system (vaspCode: <nil>)"))
			return
		}
		invokeVaspCode, ok := invokeVaspCodeVal.(string)
		if !ok {
			c.JSON(http.StatusBadRequest, Fail[any](100030, "invoke vasp code invalid"))
			return
		}

		vaspConfigRaw, exists := entities.Load(invokeVaspCode)
		if !exists {
			c.JSON(http.StatusBadRequest, Fail[any](100030, "invoke vasp code does not exists in this system (vaspCode: "+invokeVaspCode+")"))
			return
		}
		invokeVasp := vaspConfigRaw.(EntityConfig)

		// Dispatch to handler functions by callbackType
		switch callbackType {
		case 0:
			handleNetworkCheck(c)
		case 6:
			handleAddressVerification(c, rawRequest, invokeVasp)
		case 1:
			handleEmptyCase(c, "callbackType 1 not implemented yet")
		case 2:
			handleEmptyCase(c, "callbackType 2 not implemented yet")
		case 3:
			handleEmptyCase(c, "callbackType 3 not implemented yet")
		case 4:
			handleEmptyCase(c, "callbackType 4 not implemented yet")
		case 5:
			handleEmptyCase(c, "callbackType 5 not implemented yet")
		default:
			c.JSON(http.StatusOK, Fail[any](100030, "feature not support"))
		}
	})

	r.Run(":8080")
}

// handleNetworkCheck handles callbackType 0 network check
func handleNetworkCheck(c *gin.Context) {
	// Return success message for network check
	c.JSON(http.StatusOK, SuccessWithMessage[any]("network ok"))
}

// handleAddressVerification handles callbackType 6 address verification
func handleAddressVerification(c *gin.Context, rawRequest map[string]interface{}, invokeVasp EntityConfig) {
	callbackDataRaw, ok := rawRequest["callbackData"]
	if !ok {
		c.JSON(http.StatusBadRequest, Fail[any](100001, "callbackData missing"))
		return
	}

	// Convert callbackDataRaw to JSON bytes
	jsonBytes, err := json.Marshal(callbackDataRaw)
	if err != nil {
		c.JSON(http.StatusBadRequest, Fail[any](100001, "callbackData invalid"))
		return
	}

	var addrReq GtrCheckAddressExistsRequest
	if err := json.Unmarshal(jsonBytes, &addrReq); err != nil {
		c.JSON(http.StatusBadRequest, Fail[any](100001, "callbackData invalid"))
		return
	}

	// Simulate database query to count matching wallet addresses
	count := queryWalletAddressCount(addrReq.Address, addrReq.Tag, addrReq.Network, invokeVasp.CountryCode)

	if count == 1 {
		c.JSON(http.StatusOK, SuccessWithMessage[any]("address found / success"))
	} else if count > 1 {
		c.JSON(http.StatusOK, Fail[any](200001, "multiple address found failed"))
	} else {
		c.JSON(http.StatusOK, Fail[any](200001, "address not found in "+invokeVasp.CompanyName))
	}
}

// handleEmptyCase handles empty or unimplemented callbackType cases
func handleEmptyCase(c *gin.Context, message string) {
	// Return fail response with message indicating not implemented
	c.JSON(http.StatusOK, Fail[any](100030, message))
}

// queryWalletAddressCount simulates a database query for wallet address count
func queryWalletAddressCount(address, tag, network, countryCode string) int {
	// TODO: Implement actual DB query logic here
	// For demonstration, always return 0 (not found)
	return 0
}
