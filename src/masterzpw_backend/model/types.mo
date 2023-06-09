import Nat8 "mo:base/Nat8";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Blob "mo:base/Blob";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Bool "mo:base/Bool";
import Int16 "mo:base/Int16";
import Float "mo:base/Float";
import Int8 "mo:base/Int8";
import Int32 "mo:base/Int32";
import Int "mo:base/Int";
import Int64 "mo:base/Int64";
import Time "mo:base/Time";


module {

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
  public type NftError = {
    #SelfTransfer;
    #TokenNotFound;
    #TxNotFound;
    #SelfApprove;
    #OperatorNotFound;
    #UnauthorizedOwner;
    #UnauthorizedOperator;
    #ExistedNFT;
    #OwnerNotFound;
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



  public type Result<S, NftError> = {
    #Ok : S;
    #Err : NftError;
  };

  public func hash(nat64Id : Nat64) : Nat32 {
    let text = Nat64.toText(nat64Id);
    Text.hash(text);
  };

  public func equal(nat64Id1 : Nat64, nat64Id2 : Nat64) : Bool {
    nat64Id1 == nat64Id2;
  };
};
