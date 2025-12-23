
ObjectMapper objectMapper = new ObjectMapper();
{
    objectMapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
    objectMapper.configure(SerializationFeature.FAIL_ON_EMPTY_BEANS, false);
    objectMapper.setSerializationInclusion(JsonInclude.Include.NON_NULL);
}

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
private static class GtrCallbackResponse<T> {
    private T data;
    private String verifyMessage;
    private Integer verifyStatus;

    public static <T> GtrCallbackResponse<T> success() {
        GtrCallbackResponse<T> r = new GtrCallbackResponse<T>();
        r.data = null;
        r.verifyMessage = "success";
        r.verifyStatus = 100000;
        return r;
    }

    public static <T> GtrCallbackResponse<T> success(T data) {
        GtrCallbackResponse<T> r = new GtrCallbackResponse<T>();
        r.data = data;
        r.verifyMessage = "success";
        r.verifyStatus = 100000;
        return r;
    }

    public static <T> GtrCallbackResponse<T> success(String message) {
        GtrCallbackResponse<T> r = new GtrCallbackResponse<T>();
        r.data = null;
        r.verifyMessage = message;
        r.verifyStatus = 100000;
        return r;
    }

    public static <T> GtrCallbackResponse<T> success(String message, T data) {
        GtrCallbackResponse<T> r = new GtrCallbackResponse<T>();
        r.data = data;
        r.verifyMessage = message;
        r.verifyStatus = 100000;
        return r;
    }

    public static <T> GtrCallbackResponse<T> fail(Integer statusCode, String message) {
        GtrCallbackResponse<T> r = new GtrCallbackResponse<T>();
        r.data = null;
        r.verifyMessage = message;
        r.verifyStatus = statusCode;
        return r;
    }

    public static <T> GtrCallbackResponse<T> fail(Integer statusCode, String message, T data) {
        GtrCallbackResponse<T> r = new GtrCallbackResponse<T>();
        r.data = data;
        r.verifyMessage = message;
        r.verifyStatus = statusCode;
        return r;
    }
}

@Data
private static class GtrCallbackRequest<T> {
    private String requestId;
    private String invokeVaspCode;
    private String originatorVasp;
    private String beneficiaryVasp;
    private Integer callbackType;
    private String callbackScenario;
    private T callbackData;
}

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
private static class EntityConfig {
    private String vaspCode;
    private String companyName;
    private String countryCode;
}

@PostMapping(path="/callback")
public ResponseEntity<GtrCallbackResponse<?>> callback(@RequestBody(required = false) GtrCallbackRequest<?> request)  {
    ConcurrentHashMap<String, EntityConfig> entities = new ConcurrentHashMap<>();
    entities.put("[vaspCode]",EntityConfig.builder()
                    .vaspCode("[vaspCode]")
                    .companyName("Axchagne Global")
                    .countryCode("GLOBAL")
            .build());
    entities.put("[vaspCode2]",EntityConfig.builder()
            .vaspCode("[vaspCode2]")
            .companyName("Axchagne India")
            .companyName("JP")
            .build());

    try {
        if(request == null) {
            return ResponseEntity.badRequest().body(GtrCallbackResponse.fail(100001, "empty request body"));
        }
        if(request.getCallbackType() == null) {
            return ResponseEntity.badRequest().body(GtrCallbackResponse.fail(100001, "callbackType cannot be null"));
        }
        if(request.getInvokeVaspCode() == null || !entities.containsKey(request.getInvokeVaspCode())) {
            return ResponseEntity.badRequest().body(GtrCallbackResponse.fail(100030, "invoke vasp code does not exists in this system (vaspCode: " + request.getInvokeVaspCode() + ")"));
        }
        EntityConfig invokeVasp =  entities.get(request.getInvokeVaspCode());

        switch (request.getCallbackType()) {
            // Common: Network Check
            case 0 -> {
                return networkHealthCheckCallback();
            }
            // Common: Address Routing
            case 10 -> {

            }
            // Standard 2: Address Verification
            case 6 -> {
                return (ResponseEntity) checkAddressExistsRequest(request.getCallbackData(), invokeVasp);
            }
            // Standard 2: TX ID Verification
            case 9 -> {

            }
            // Standard 2: PII Verification
            case 4 -> {

            }
            // Standard 2: Receive TX ID Callback
            case 7 -> {

            }
            // Standard 2: End Travel Rule
            case 17 -> {

            }

            // Out of network inquery
            case 12 -> {

            }
        }

        return ResponseEntity.ok(GtrCallbackResponse.fail(100030, "feature not support"));
    } catch (Exception e) {
        return ResponseEntity.internalServerError().body(GtrCallbackResponse.fail(100008, "internal server error: "  + e.getMessage()));
    }
}

private ResponseEntity<GtrCallbackResponse<?>> networkHealthCheckCallback() {
    return ResponseEntity.ok(GtrCallbackResponse.success("network ok"));
}

@Data
private static class GtrCheckAddressExistsRequest {
    // FdXI1VL3CepU
    private String requestId;
    // [Originator VASP Code]
    private String originatorVasp;
    // [Originator VASP Name]
    private String originatorVaspName;
    // 0x41ebF291D8BFb6481B4Ab1E26c412A96484b1454
    private String address;
    //
    private String tag;
    // ETH
    private String network;
    // [Initiator VASP Code]
    private String initiatorVasp;
}

private ResponseEntity<GtrCallbackResponse<Void>> checkAddressExistsRequest(Object rawRequest, EntityConfig invokeVasp) {
    GtrCheckAddressExistsRequest request = objectMapper.convertValue(rawRequest, GtrCheckAddressExistsRequest.class);
    String tag = "";
    if (request.getTag() != null && StringUtils.isNotEmpty(request.getTag())) {
        tag =  request.getTag();
    }
    int count = 0;
    // count = SELECT COUNT(*) FROM wallet WHERE wallet_address = request.getAddress() AND wallet_address_tag = request.getTag() AND chain = request.getNetwork() AND kyc_country = invokeVasp.getCountryCode()
    if (count == 1) {
        return ResponseEntity.ok(GtrCallbackResponse.success("address found / success"));
    } else if (count > 1) {
        return ResponseEntity.ok(GtrCallbackResponse.fail(200001, "multiple address found failed"));
    } else {
        return ResponseEntity.ok(GtrCallbackResponse.fail(200001, "address not found in " + invokeVasp.getCompanyName()));
    }
}