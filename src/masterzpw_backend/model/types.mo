import Nat8 "mo:base/Nat8";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Blob "mo:base/Blob";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Bool "mo:base/Bool";
import Int16 "mo:base/Int16";
import Int8 "mo:base/Int8";
import Int32 "mo:base/Int32";
import Int "mo:base/Int";
import Int64 "mo:base/Int64";
import Time "mo:base/Time";
import HashMap "mo:base/HashMap";
import Array "mo:base/Array";


module GenericTypes {

  public type InitArgs = {
    logo: Text;
    name: Text;
    custodians: [Principal];
    symbol: Text;
  };

  // NFT canister metadata
  public type Metadata = {
    logo: Text;
    name: Text;
    created_at: Time.Time; 
    upgraded_at: Time.Time;
    custodians: [Principal];
    symbol: Text;
  };


  // NFT canister stats
  public type Stats = {
    cycles: Nat;
    total_transactions: Nat;
    total_unique_holders: Nat;
    total_supply: Nat;
  };

  // Generic value enum to assign to generic parameters
  public type GenericValue = {
    #Nat64Content: Nat64;
    #Nat32Content: Nat32;
    #BoolContent: Bool;
    #Nat8Content: Nat8;
    #Int64Content: Int64;
    #IntContent: Int;
    #NatContent: Nat;
    #Nat16Content: Nat16;
    #Int32Content: Int32;
    #Int8Content: Int8;
    #FloatContent: Float;
    #Int16Content: Int16;
    #BlobContent: Blob;
    #NestedContent: Vec;
    #Principal: Principal;
    #TextContent: Text;
  };




  // Error enum list
  public type Error = {
    #SelfTransfer: Bool;
    #TokenNotFound: Bool;
    #TxNotFound: Bool;
    #SelfApprove: Bool;
    #OperatorNotFound: Bool;
    #UnauthorizedOwner: Bool;
    #UnauthorizedOperator: Bool;
    #ExistedNFT: Bool;
    #OwnerNotFound: Bool;
    #FirstAccess: Bool;

    #CompanyNotFound: Bool;
    #BuyerNotFound: Bool;
    #SomethingWentWrong: Bool;
    #NotFoud: Bool;

    #Other: Text;
  };

  // API enum list
  public type SupportedInterface = {
    #Mint;
    #TransactionHistory;
    #Transfer;
  };

  public type TxIdentifier = Nat64;

  // Transaction struct
  public type TxEvent = {
    txId : TxIdentifier;
    time: Nat64;
    operation: Text;
    details: Vec;
    caller: Principal;
  };

  // Array of pairs key-value
  public type Vec = [{
    key: Text;
    value: GenericValue;
  }];



  public type Result<S, Error> = {
    #Ok : S;
    #Err : Error;
  };

  public type User<S, T> = {
    #Buyer: UsersTypes.StableBuyer;
    #Company: UsersTypes.StableCompany;
  };

  public func hash(nat64Id : Nat64) : Nat32 {
    let text = Nat64.toText(nat64Id);
    Text.hash(text);
  };

  public func equal(nat64Id1 : Nat64, nat64Id2 : Nat64) : Bool {
    nat64Id1 == nat64Id2;
  };

};

module UsersTypes = {

  public type StableBuyer = {
      principal : Principal; 
      username : Text;
      profilePictureUri : Text;
      ownerType : Text;
      ownNfts : [(TokenIdentifier.TokenIdentifier, Nft.Nft)];
  };

  public type StableCompany = {
      principal : Principal; 
      username : Text;
      profilePictureUri : Text;
      bankAddress : Text;
      ownerType : Text;
      ownNfts : [(TokenIdentifier.TokenIdentifier, Nft.Nft)];
      soldNfts : [(TokenIdentifier.TokenIdentifier, Nft.Nft)];
  };
};



module Nft {
    public type Nft = {
        tokenId : TokenIdentifier.TokenIdentifier;
        owner : Principal;
        metadata : TokenMetadata;
    };


      // Token Metadat (to complete)
    public type TokenMetadata = {
        transferredAt: ?Int;
        transferredBy: ?Principal;
        owner: Principal;
        operator: ?Principal;
        properties: GenericTypes.Vec;
        isBurned: Bool;
        tokenIdentifier: TokenIdentifier.TokenIdentifier;
        burnedAt: ?Nat64;
        burnedBy: ?Principal;
        approvedAt: ?Nat64;
        approvedBy: ?Principal;
        mintedAt: Int;
        mintedBy: Principal;
    };
};


module TokenIdentifier {
  public type TokenIdentifier = Nat64;

  public func hash(tokenId : TokenIdentifier) : Nat32 {
    let text = Nat64.toText(tokenId);
    Text.hash(text);
  };

  public func equal(tokenId1 : TokenIdentifier, tokenId2 : TokenIdentifier) : Bool {
    tokenId1 == tokenId2;
  };

  
};


module Opera {
   public type StableOpera = {
        id: Nat64;
        name : Text;
        description: Text;
        pictureUri : Text;
        price: Int;
        nfts : [TokenIdentifier.TokenIdentifier];
    };
};

module HttpsTypes {

    public type Timestamp = Nat64;

    //1. Type that describes the Request arguments for an HTTPS Outcall
    //See: https://internetcomputer.org/docs/current/references/ic-interface-spec/#ic-http_request
    public type HttpRequestArgs = {
        url : Text;
        max_response_bytes : ?Nat64;
        headers : [HttpHeader];
        body : ?[Nat8];
        method : HttpMethod;
        transform : ?TransformRawResponseFunction;
    };

    public type HttpHeader = {
        name : Text;
        value : Text;
    };

    public type HttpMethod = {
        #get;
        #post;
        #head;
    };

    public type HttpResponsePayload = {
        status : Nat;
        headers : [HttpHeader];
        body : [Nat8];
    };

   
    public type TransformRawResponseFunction = {
        function : shared query TransformArgs -> async HttpResponsePayload;
        context : Blob;
    };


    public type TransformArgs = {
        response : HttpResponsePayload;
        context : Blob;
    };

    public type IC = actor {
        http_request : HttpRequestArgs -> async HttpResponsePayload;
    };
}