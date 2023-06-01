import Nat "mo:base/Nat";
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

module {


  public type InitArgs = {
    name: Text;
    logo: Text;
    symbol: Text;
    custodians: [Principal];
    cap: Principal;
  };

  // NFT canister metadata
  public type Metadata = {
    logo: Text;
    name: Text;
    created_at: Nat64; 
    upgraded_at: Nat64;
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

  // NFT identifier
  public type TokenIdentifier = Nat;

  // Token Metadat (to complete)
  public type TokenMetadata = {
    transferred_at: Nat64;
    transferred_by: Principal;
    owner: Principal;
    operator: Principal;
    properties: Vec;
    is_burned: Bool;
    token_identifier: Nat;
    burned_at: Nat64;
    burned_by: Principal;
    approved_at: Nat64;
    approved_by: Principal;
    minted_at: Nat64;
    minted_by: Principal;
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
    #Burn;
    #Mint;
    #Approval;
    #TransactionHistory;
  };

  // Transaction struct
  public type TxEvent = {
    time: Nat64;
    operation: Text;
    details: Vec;
    caller: Principal;
  };

  public type TxIdentifier = Nat64;

  // Array of pairs key-value
  public type Vec = [{
    key: Text;
    value: GenericValue;
  }];


  public type Nft = {
    owner_chain: [Principal];
    owner: Principal;
    id: TokenIdentifier;
    metadata: TokenMetadata;
  };

  public type Result<S, NftError> = {
    #Ok : S;
    #Err : NftError;
  };
};
