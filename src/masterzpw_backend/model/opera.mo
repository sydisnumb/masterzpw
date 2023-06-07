import HashMap "mo:base/HashMap";

import Types "./types";
import Nft "./nft";


module {
    type Opera = {
        name : Text;
        pictureUri : Text;
        nfts : HashMap.HashMap<Nft.TokenIdentifier.TokenIdentifier, Nft.Nft.Nft>;
    };

    public func getNftById(opera: Opera, tokenId : Nft.TokenIdentifier.TokenIdentifier) : ?Nft.Nft.Nft{
        opera.nfts.get(tokenId)
    }
};

