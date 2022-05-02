pragma solidity >=0.5.0 < 0.6.0;

contract NameService {
    uint256 _reservePrice;
    // TODO
	struct Name {
        bytes32 value;
        address owner;
    }
    
    struct Commit {
        bytes32 data;
        uint256 blockNum;
    }
    
	mapping(bytes32 => Name) names;
    mapping(address => Commit) commits;
    modifier onlyNameOwner(bytes32 name) {
        require(names[name].owner == msg.sender);
        _;
    }
	
    // constructor
    constructor(uint256 reservePrice) public {
        _reservePrice = reservePrice;
    }

    function transferTo(bytes32 name, address newOwner) public onlyNameOwner(name){
        // TODO
		names[name].owner = newOwner;
    }

    function setValue(bytes32 name, bytes32 value) public onlyNameOwner(name){
        // TODO
		names[name].value = value;
    }

    function getValue(bytes32 name) public view returns (bytes32) {
        // TODO
		return names[name].value;
    }

    function commitToName(bytes32 commitment) public payable {
        // TODO
		require(msg.value == _reservePrice);
        commits[msg.sender] = Commit(commitment, block.number);
    }

    function registerName(bytes32 nonce, bytes32 name, bytes32 value) public {
        // TODO
		require(commits[msg.sender].data != 0);
        require(block.number > commits[msg.sender].blockNum + 20);
		
        bytes32 commit = makeCommitment(nonce, name, msg.sender);
        
        if (commit == commits[msg.sender].data) {
            if (names[name].owner == address(0)) {
                names[name].owner = msg.sender;
                names[name].value = value;
            }
            else {
                msg.sender.transfer(_reservePrice);
            }
            
            delete commits[msg.sender];
        }
    }

    function getOwner(bytes32 name) public view returns(address) {
        // TODO
		return names[name].owner;
    }

    // Commit utility
    function makeCommitment(bytes32 nonce, bytes32 name, address sender) public view returns(bytes32) {
	    require(names[name].owner == address(0));
        return keccak256(abi.encodePacked(nonce, name, sender));
    }
}
