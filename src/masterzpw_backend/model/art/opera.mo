import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";

import Types "../types";
import Nft "../art/nft";


module Opera {
    public type StableOpera = {
        id: Nat64;
        name : Text;
        pictureUri : Text;
        nfts : [Nft.TokenIdentifier.TokenIdentifier];
    };

    public class Opera(identifier : Nat64, operaName : Text, picUri : Text, mintedNfts : [Nft.TokenIdentifier.TokenIdentifier]) {
        private var id = identifier;
        private var name = operaName;
        private var pictureUri = picUri;
        private var nfts = mintedNfts;

        public func getId() : Nat64 = id;
        public func getName() : Text = name;
        public func getPictureUri() : Text = pictureUri;
        public func getNftsIds() : [Nft.TokenIdentifier.TokenIdentifier] = mintedNfts;

        public func setId(newId : Nat64) : () {
            id := newId;
        };
        public func setName(newName : Text) : () {
            name := newName;
        };

        public func setPictureUri(newPictureUri : Text) : () {
            pictureUri := newPictureUri;
        };
        
        public func setNftsIds(newNfts : [Nft.TokenIdentifier.TokenIdentifier]) : () {
            nfts := newNfts;
        };

        public func checkNftById(tokenId : Nft.TokenIdentifier.TokenIdentifier) : Bool {
            for (id in nfts.vals()) {
                if (id == tokenId) {
                    return true;
                };
            };

            return false;
        };

        public func serialize() : StableOpera {
            let op : StableOpera = {
                id = id;
                name = name;
                pictureUri = pictureUri;
                nfts = nfts;
            };
        };
    };

    public func serializeOperas(operas : Iter.Iter<Opera>) : [StableOpera] {
        let buf = Buffer.Buffer<StableOpera>(0);

        for (opera in operas) {
            buf.add(opera.serialize());
        };

        Buffer.toArray(buf);
    };

    public func deserialize(stableOpera: StableOpera) : Opera {
        Opera(stableOpera.id, stableOpera.name, stableOpera.pictureUri, stableOpera.nfts);
    };

    public func deserializeOperas(stableOperas: Iter.Iter<StableOpera>) : [Opera] {
        let buf = Buffer.Buffer<Opera>(0);

        for (opera in stableOperas) {
            buf.add(deserialize(opera));
        };

        Buffer.toArray(buf);
    };

    public func deserializeOperasToMap(stableOperas: [StableOpera]) : HashMap.HashMap<Nat64, Opera> {
        let operaTmp : [(Nat64, Opera)] = Array.tabulate<(Nat64, Opera)>(stableOperas.size(), func (i) { (stableOperas[i].id, deserialize(stableOperas[i])); });
        let operas = HashMap.fromIter<Nat64, Opera>(operaTmp.vals(), operaTmp.size(), Types.equal, Types.hash);
    };

};

