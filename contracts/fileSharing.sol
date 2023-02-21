// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

contract FileSharing {
    // Define a struct to represent a file

    uint public id;

    struct File {
        uint file_id;
        string fileName;
        string ipfsHash;
        address owner;
        address[] beneficiaries;
        uint price;
    }
    struct User {
        uint user_id;
        string user_name;
    }
    event FileCreated (
        uint file_id,
        string name,
        string fileHash,
        address author,
        uint40 time
    );
    
    event FileShared (
        uint file_id,
        address author,
        uint40 time
    );

    // Define a mapping to store files
    mapping(uint => File) public files;

    function addBeneficiaries(uint fileId, address userId) public {
        files[fileId].beneficiaries.push(userId);
    }

    // Define a function to upload a file
    function uploadFile(string memory name, string memory ipfsHash, uint price, address[] memory authorizedViewers) public {
        id++;
        files[id] = File(id, name, ipfsHash, msg.sender, authorizedViewers, price);
        emit FileCreated(id, name, ipfsHash, msg.sender, uint40(block.timestamp));
    }


    function shareFile(uint fileId, address user) public payable {
        files[fileId].beneficiaries.push(user);
        emit FileShared(fileId, user, uint40(block.timestamp));
    }

    // Define a function to download a file
    function downloadFile(uint fileId, string memory _ipfsHash, address user) public payable returns (string memory) {
    bool authorized = false;
    
    // Loop through the array of authorized addresses and check if the user is present
    for (uint i = 0; i < files[fileId].beneficiaries.length; i++) {
        if (files[fileId].beneficiaries[i] == user) {
            authorized = true;
            break;
        }
    }
    
    // Check if the user is authorized to access the file
    require(authorized, "You are not authorized to access this file");
    
    // Check if the user has paid the required amount of Ether to access the file
    require(msg.value >= files[fileId].price, "You need to pay more to access this file");

    // Return the IPFS hash of the file
    return files[fileId].ipfsHash;
}

}