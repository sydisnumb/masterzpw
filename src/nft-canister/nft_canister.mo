import HashMap "mo:base/HashMap";
import Ledger "masterzpw_backend/persistence/ledger";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import List "mo:base/List";
import Array "mo:base/Array";
import Option "mo:base/Option";
import Bool "mo:base/Bool";
import Principal "mo:base/Principal";
import Types "./types";
import Time "mo:base/Time";
import Text "mo:base/Text";
import Result "mo:base/Result";
import HashMap "mo:base/HashMap";

shared actor class Ledger(init : Types.InitArgs) = Self {
  private stable var transactionId: Types.TransactionId = 0;
  private stable var txs = List.nil<Types.TxEvent>();
  private stable var nfts = HashMap<Types.TokenIdentifier.TokenIdentifier, Types.Nft>();
  private stable var unique_holders = HashMap<Principal, Users.>();

  private stable var logo : Text = init.logo;
  private stable var name : Text = init.name;
  private stable var created_at : Nat64 = 1685572614;
  private stable var custodians : [Principal] = init.custodians;
  private stable var symbol : Text = init.symbol;


  // https://forum.dfinity.org/t/is-there-any-address-0-equivalent-at-dfinity-motoko/5445/3
  let null_address: Principal = Principal.fromText("aaaaa-aa");

  public query func metadata() : async Types.Metadata {
    {
        logo = self.logo;
        name = self.name;
        created_at = self.created_at;
        custodians = self.custodians;
        symbol = self.symbol;
    };
  };

  public query func stats() : async Types.Metadata {
    {
        cycles = Cycles.balance();
        total_transactions = HashMap.size(txs);
        total_unique_holders = List.size(unique_holders);
        total_supply = HashMap.size(nfts);

    }
  };


  public query func logo() : async Text {
    return logo;
  };


  public func setLogo(logo: Text) : async () {
    logo := logo;
  };

  public query func name() : async Text {
    return name;
  };

  public func setName(name: Text) : async () {
    name := name;
  };

  public query func symbol() : async Text {
    return symbol;
  };

  public func setSymbol(symbol: Text) : async () {
    symbol := symbol;
  };

  public query func totalSupply() : async Nat {
    return List.size(nfs);
  };

  public query func custodians() : async [Principal] {
    return custodians;
  };

  public func setCustodians(custodians: [Principal]) : async () {
    custodians := custodians;
  };

  public query func cycles() : async Nat {
    return cycles;
  };

  public query func totalUniqueHolders() : async Nat {
    return List.size(unique_holders);
  };

  public query func tokenMetadata(token_identifier: Types.TokenIdentifier) : async Types.Result {
    //TODO sostituire con HashMap
    let item = List.find(nfts, func(token: Types.Nft) : Bool { token.id == token_identifier });
    
    switch (item) {
      case null {
        return #Err(#TokenNotFound);
      };
      case (?token) {
        return #Ok(token.metadata);
      }
    };
  };


  public query func balanceOf(owner: Principal) : async Types.Result {
    //TODO da ripensare introudendo classe Owner e HashMap
    return List.size(List.filter(nfts, func(token: Types.Nft) : Bool { token.owner == owner }));
  };

  public query func ownerOf(token_id: Types.TokenIdentifier) : async Types.Result {
    let item = List.find(nfts, func(token: Types.Nft) : Bool { token.id == token_id });
    
    switch (item) {
      case (null) {
        return #Err(TokenNotFound);
      };
      case (?token) {
        return #Ok(token.owner);
      };
    };
  };


  public query func ownerTokenIdentifiers(owner: Principal) : async Types.Result {
    let owner_nfts = List.filter(nfts, func(token: Types.Nft) : Bool { token.owner == owner })
    return #Ok(owner_nfts)
  }



  public shared({ caller }) func safeTransferFromDip721(from: Principal, to: Principal, token_id: Types.TokenId) : async Types.TxReceipt {  
    if (to == null_address) {
      return #Err(#ZeroAddress);
    } else {
      return transferFrom(from, to, token_id, caller);
    };
  };

  public shared({ caller }) func transferFromDip721(from: Principal, to: Principal, token_id: Types.TokenId) : async Types.TxReceipt {
    return transferFrom(from, to, token_id, caller);
  };

  func transferFrom(from: Principal, to: Principal, token_id: Types.TokenId, caller: Principal) : Types.TxReceipt {
    let item = List.find(nfts, func(token: Types.Nft) : Bool { token.id == token_id });
    switch (item) {
      case null {
        return #Err(#InvalidTokenId);
      };
      case (?token) {
        if (
          caller != token.owner and
          not List.some(custodians, func (custodian : Principal) : Bool { custodian == caller })
        ) {
          return #Err(#Unauthorized);
        } else if (Principal.notEqual(from, token.owner)) {
          return #Err(#Other);
        } else {
          nfts := List.map(nfts, func (item : Types.Nft) : Types.Nft {
            if (item.id == token.id) {
              let update : Types.Nft = {
                owner = to;
                id = item.id;
                metadata = token.metadata;
              };
              return update;
            } else {
              return item;
            };
          });
          transactionId += 1;
          return #Ok(transactionId);   
        };
      };
    };
  };

  public query func supportedInterfacesDip721() : async [Types.InterfaceId] {
    return [#TransferNotification, #Burn, #Mint];
  };





  public func getMetadataForUserDip721(user: Principal) : async Types.ExtendedMetadataResult {
    let item = List.find(nfts, func(token: Types.Nft) : Bool { token.owner == user });
    switch (item) {
      case null {
        return #Err(#Other);
      };
      case (?token) {
        return #Ok({
          metadata_desc = token.metadata;
          token_id = token.id;
        });
      }
    };
  };

  public query func getTokenIdsForUserDip721(user: Principal) : async [Types.TokenId] {
    let items = List.filter(nfts, func(token: Types.Nft) : Bool { token.owner == user });
    let tokenIds = List.map(items, func (item : Types.Nft) : Types.TokenId { item.id });
    return List.toArray(tokenIds);
  };

  public shared({ caller }) func mintDip721(to: Principal, metadata: Types.MetadataDesc) : async Types.MintReceipt {
    if (not List.some(custodians, func (custodian : Principal) : Bool { custodian == caller })) {
      return #Err(#Unauthorized);
    };

    let newId = Nat64.fromNat(List.size(nfts));
    let nft : Types.Nft = {
      owner = to;
      id = newId;
      metadata = metadata;
    };

    nfts := List.push(nft, nfts);

    transactionId += 1;

    return #Ok({
      token_id = newId;
      id = transactionId;
    });
  };
}