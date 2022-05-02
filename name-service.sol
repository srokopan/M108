pragma solidity >=0.5.0 < 0.6.0;

contract NameService {
    struct Name {
        bytes32 value;
        address owner;
    }
    
    struct Commitment {
        bytes32 data;
        uint256 blockNumber;
    }
    
    uint256 _reservePrice;
    
    mapping(bytes32 => Name) names;
    mapping(address => Commitment) commitments;
    
    modifier onlyNameOwner(bytes32 name) {
        require(names[name].owner == msg.sender);
        _;
    }

    // constructor
    constructor(uint256 reservePrice) public {
        _reservePrice = reservePrice;
    }

    function transferTo(bytes32 name, address newOwner) public onlyNameOwner(name) {
        names[name].owner = newOwner;
    }

    function setValue(bytes32 name, bytes32 value) public onlyNameOwner(name) {
        names[name].value = value;
    }

    function getValue(bytes32 name) public view returns (bytes32) {
        return names[name].value;
    }

    function commitToName(bytes32 commitment) public payable {
        require(msg.value == _reservePrice);
        
        commitments[msg.sender] = Commitment(commitment, block.number);
    }

    function registerName(bytes32 nonce, bytes32 name, bytes32 value) public {
        require(commitments[msg.sender].data != 0);
        require(block.number > commitments[msg.sender].blockNumber + 20);
        
        bytes32 commitment = makeCommitment(nonce, name, msg.sender);
        
        if (commitment == commitments[msg.sender].data) {
            if (names[name].owner == address(0)) {
                names[name].owner = msg.sender;
                names[name].value = value;
            }
            else {
                msg.sender.transfer(_reservePrice);
            }
            
            delete commitments[msg.sender];
        }
    }

    function getOwner(bytes32 name) public view returns(address) {
        return names[name].owner;
    }

    // Commitment utility
    function makeCommitment(bytes32 nonce, bytes32 name, address sender) public view returns(bytes32) {
        require(names[name].owner == address(0));

        return keccak256(abi.encodePacked(nonce, name, sender));
    }
}
