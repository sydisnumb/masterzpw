import Principal "mo:base/Principal";
import Bool "mo:base/Bool";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Nat64 "mo:base/Nat64";
import Int "mo:base/Int";
import Random "mo:base/Random";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";
import Time "mo:base/Time";
import Blob "mo:base/Blob";
import Char "mo:base/Char";
import Debug "mo:base/Debug";
import Cycles "mo:base/ExperimentalCycles";
import JSON "mo:serde/JSON";



import Company "./model/users/company";
import Buyer "./model/users/buyer";
import Types "./model/types";
import Util "./model/util";

import Ledger "canister:ledger";


actor {
    private let client_id = "AfTpyWtmnwuV5ijd6I0tEAwvVl0_8rsQbBigbyF7MEmNiI54LcWM78CnuPQj_menQSa4NPGQQa_8fsGS";
    private let client_secret = "EPxr1XU5xEyjehPUzZ_zDcMV5XzCVIklSM2i2W9FKt6Dcmk3FVxDL8mpd0uT44ghFdA3xBs_LXpLOG43";

    private let host : Text = "api-m.sandbox.paypal.com";
    private let ep_url = "https://api-m.sandbox.paypal.com";

    private let MAX_RESP_BYTES : Nat64 = 2000;

    public shared ({caller}) func login(): async Types.GenericTypes.Result<Types.GenericTypes.User<Types.UsersTypes.StableBuyer, Types.UsersTypes.StableCompany>, Types.GenericTypes.Error> {
        await Ledger.login(caller);
    };

    public shared ({caller}) func createCompany(username : Text, profilePictureUri : Text, bankAddress: Text) : async Types.GenericTypes.Result<Principal, Types.GenericTypes.Error> {
        if (username != "" and bankAddress != "") {
            return await Ledger.createCompany(caller, username, profilePictureUri, bankAddress);
        };
        
        return #Err(#Other("Be sure to insert all required fields."))
    };

    public shared ({caller}) func createBuyer(username : Text, profilePictureUri : Text) : async Types.GenericTypes.Result<Principal, Types.GenericTypes.Error> {
        await Ledger.createBuyer(caller, username, profilePictureUri);
    };

    public shared ({caller}) func createNewOpera(operaName : Text, operaDescription: Text, operaPicUri : Text, operaPrice: Int) : async Types.GenericTypes.Result<Nat64, Types.GenericTypes.Error> {
        await Ledger.createNewOpera(caller, operaName, operaDescription, operaPicUri, operaPrice, 1);
    };

    public shared ({caller}) func getOpera(operaId : Nat64) : async Types.GenericTypes.Result<Types.Opera.StableOpera, Types.GenericTypes.Error> {
        await Ledger.getOpera(operaId);
    };

    public shared ({caller}) func getOperas(page : Int) : async Types.GenericTypes.Result<[Types.Opera.StableOpera], Types.GenericTypes.Error> {
        await Ledger.getOperasByPage(page);
    };

    public shared ({caller}) func checkOperas(): async Bool {
        let res = await Ledger.getOperasSize();
        return res > 0;
    };


    public shared ({caller}) func getOwnOperas(ownerType: Text, page : Int): async Types.GenericTypes.Result<[Types.Opera.StableOpera], Types.GenericTypes.Error>  {
        if(ownerType=="company") {
            await Ledger.getOwnOperasByCompany(caller, page);
        } else {
            await Ledger.getOwnOperasByBuyer(caller, page);
        }
    };

    public shared ({caller}) func getSoldOperas(ownerType: Text, page : Int): async Types.GenericTypes.Result<[Types.Opera.StableOpera], Types.GenericTypes.Error>  {
        await Ledger.getSoldOperasByCompany(caller, page);
    };


    public shared ({caller}) func getBuyer() : async Types.GenericTypes.Result<Types.UsersTypes.StableBuyer, Types.GenericTypes.Error> {
        await Ledger.getBuyer(caller);
    };

    // public shared ({caller}) func getBuyers(page : Int) : async Types.GenericTypes.Result<Nat64, Types.GenericTypes.Error> {
    //     await Ledger.createNewOpera(caller, page);
    // };


    public shared ({caller}) func getCompany() : async Types.GenericTypes.Result<Types.UsersTypes.StableCompany, Types.GenericTypes.Error> {
        let res = await Ledger.getCompany(caller);

        switch res {
            case (#Ok(stableComp)) { return #Ok(stableComp); };
            case (#Err(_)) { return #Err(#SomethingWentWrong(true)); };
        }
    };


    public shared ({caller}) func getCompanyByOperaId(operaId : Nat64 ): async Types.GenericTypes.Result<Types.UsersTypes.StableCompany, Types.GenericTypes.Error> {
        await Ledger.getCompanyByOperaId(operaId);
    };


    // Paypal handlers
    public shared ({caller}) func createOrder(intent : Text, price : Int) : async Text {
        let access_token = await getPaypalToken();
        await createRemoteOrder(access_token, price);
    };

    public shared ({caller}) func simulateCompleteOrder(intent: Text, orderId : Text, from: Principal, to: Principal, nft: Types.TokenIdentifier.TokenIdentifier) : async Text{
        ignore await Ledger.transferFrom(from, to, nft);
        let res = "Ok";
    };

    public shared ({caller}) func completeOrder(intent: Text, orderId : Text, from: Principal, to: Principal, nft: Types.TokenIdentifier.TokenIdentifier) : async Text{
        let access_token = await getPaypalToken();
        ignore await Ledger.transferFrom(from, to, nft);
        await completeRemoteOrder(access_token, orderId);
        // gestire scenari alternativi
    };


    func getPaypalToken() : async Text {
        let ic : Types.HttpsTypes.IC = actor ("aaaaa-aa");

        let host : Text = "api-m.sandbox.paypal.com";
        let ep_url = "https://api-m.sandbox.paypal.com";

        let auth : Text = client_id # ":" # client_secret;
        let auth_blob : Blob = Text.encodeUtf8(auth);
        let auth_nat8 : [Nat8] = Blob.toArray(auth_blob);
        let auth_base64_nat8 = Util.Base64.StdEncoding.encode(auth_nat8);
        let auth_base64 = Text.decodeUtf8(Blob.fromArray(auth_base64_nat8));

        let auth_base64_str =
            switch (auth_base64){
                case (?auth_base64) { "Basic " # auth_base64 };
                case (null) { "Basic xxx" }
            };


        let idempotency_key: Text = generateUUID();
        let request_headers = [
            { name = "Host"; value = host # ":443" },
            { name = "User-Agent"; value = "http_post_sample" },
            { name= "Content-Type"; value = "application/x-www-form-urlencoded" },
            { name= "Idempotency-Key"; value = idempotency_key },
            { name = "Authorization"; value = auth_base64_str }
        ];

  
        let data : Text = "grant_type=client_credentials";
        let request_body_as_Blob: Blob = Text.encodeUtf8(data); 
        let request_body_as_nat8: [Nat8] = Blob.toArray(request_body_as_Blob);


        let http_request : Types.HttpsTypes.HttpRequestArgs = {
            url = ep_url # "/v1/oauth2/token";
            max_response_bytes = ?MAX_RESP_BYTES; 
            headers = request_headers;
            body = ?request_body_as_nat8; 
            method = #post;
            transform = null; 
        };


        Cycles.add(200_444_800_000);   
        let http_response : Types.HttpsTypes.HttpResponsePayload = await ic.http_request(http_request);
        

        let response_body: Blob = Blob.fromArray(http_response.body);
        let decoded_text: Text = switch (Text.decodeUtf8(response_body)) {
            case (null) { "No value returned" };
            case (?y) { y };
        };

        Util.JsonParser.parseValue(decoded_text, "access_token");
    };


    func generateUUID() : Text {
        Int.toText(Time.now());
    };


    func createRemoteOrder(accessToken : Text, value :  Int) : async Text {
        let ic : Types.HttpsTypes.IC = actor ("aaaaa-aa");

        let idempotency_key: Text = generateUUID();
        let request_headers = [
            { name = "Host"; value = host # ":443" },
            { name = "User-Agent"; value = "http_post_sample" },
            { name= "Content-Type"; value = "application/json" },
            { name= "Idempotency-Key"; value = idempotency_key },
            { name = "Authorization"; value = "Bearer " # accessToken }
        ];

  
        let data : Text = "{\"intent\": \"CAPTURE\", \"purchase_units\": [{ \"amount\": { \"currency_code\": \"EUR\", \"value\": \"" # Int.toText(value) # "\"}}]}";
        Debug.print(data);
        let request_body_as_Blob: Blob = Text.encodeUtf8(data); 
        let request_body_as_nat8: [Nat8] = Blob.toArray(request_body_as_Blob);

        
        let http_request : Types.HttpsTypes.HttpRequestArgs = {
            url = ep_url # "/v2/checkout/orders";
            max_response_bytes = ?MAX_RESP_BYTES;
            headers = request_headers;
            body = ?request_body_as_nat8; 
            method = #post;
            transform = null; 
        };


        Cycles.add(200_444_800_000);   
        let http_response : Types.HttpsTypes.HttpResponsePayload = await ic.http_request(http_request);
        

        let response_body: Blob = Blob.fromArray(http_response.body);
        let decoded_text: Text = switch (Text.decodeUtf8(response_body)) {
            case (null) { "No value returned" };
            case (?y) { y };
        };

     
    };

    func completeRemoteOrder(accessToken : Text, orderId: Text) : async Text {
        let ic : Types.HttpsTypes.IC = actor ("aaaaa-aa");

        let idempotency_key: Text = generateUUID();
        let request_headers = [
            { name = "Host"; value = host # ":443" },
            { name = "User-Agent"; value = "http_post_sample" },
            { name= "Content-Type"; value = "application/json" },
            { name= "Idempotency-Key"; value = idempotency_key },
            { name = "Authorization"; value = "Bearer " # accessToken }
        ];

        let data : Text = "{\"id\": \"" # orderId # "\"}";
        Debug.print(data);
        let request_body_as_Blob: Blob = Text.encodeUtf8(data); 
        let request_body_as_nat8: [Nat8] = Blob.toArray(request_body_as_Blob);

        let http_request : Types.HttpsTypes.HttpRequestArgs = {
            url = ep_url # "/v2/checkout/orders/" # orderId # "/CAPTURE";
            max_response_bytes = ?MAX_RESP_BYTES;
            headers = request_headers;
            body= ?request_body_as_nat8;
            method = #post;
            transform = null; 
        };


        Cycles.add(200_444_800_000);   
        let http_response : Types.HttpsTypes.HttpResponsePayload = await ic.http_request(http_request);
        

        let response_body: Blob = Blob.fromArray(http_response.body);
        let decoded_text: Text = switch (Text.decodeUtf8(response_body)) {
            case (null) { "No value returned" };
            case (?y) { y };
        };
    }
 }