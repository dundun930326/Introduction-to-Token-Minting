// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Simple ERC-721 NFT Contract (without OpenZeppelin)
/// @author ChatGPT
contract SimpleERC721  {
    // 事件定義
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    // 代幣名稱與代號
    string public name;
    string public symbol;

    // 記錄 NFT 擁有者
    mapping(uint256 => address) private _owners;

    // 記錄每個地址擁有的 NFT 數量
    mapping(address => uint256) private _balances;

    // 授權特定地址轉移 NFT
    mapping(uint256 => address) private _tokenApprovals;

    // 批量授權管理
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // NFT ID 計數
    uint256 private _tokenIdCounter;

    // Metadata URI（儲存 NFT 資訊）
    mapping(uint256 => string) private _tokenURIs;

    /// @dev 建構函數
    constructor(string memory _name, string memory _symbol) payable{
        name = _name;
        symbol = _symbol;
    }

    /// @notice 查詢某地址持有 NFT 數量
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "Query for zero address");
        return _balances[owner];
    }

    /// @notice 查詢某個 tokenId 的擁有者
    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "Token does not exist");
        return owner;
    }

    /// @notice 鑄造 NFT
function mint(address to, string memory uri) public {
    require(to != address(0), "Mint to zero address");

    uint256 tokenId = _tokenIdCounter;
    _tokenIdCounter++;

    _owners[tokenId] = to;
    _balances[to]++;

    string memory fullURI = string(abi.encodePacked("ipfs://", uri, "/"));

    _tokenURIs[tokenId] = fullURI;

    emit Transfer(address(0), to, tokenId);
}

    /// @notice 設定 NFT 的 Metadata URI
    function _setTokenURI(uint256 tokenId, string memory uri) internal {
        require(_owners[tokenId] != address(0), "Token does not exist");
        _tokenURIs[tokenId] = uri;
    }

    /// @notice 查詢 NFT Metadata
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_owners[tokenId] != address(0), "Token does not exist");
        return _tokenURIs[tokenId];
    }

    /// @notice 轉移 NFT
    function transferFrom(address from, address to, uint256 tokenId) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
        require(from == _owners[tokenId], "Incorrect owner");
        require(to != address(0), "Cannot transfer to zero address");

        _approve(address(0), tokenId); // 清除授權
        _balances[from]--;
        _balances[to]++;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /// @notice 安全轉移 NFT
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(), "Receiver not ERC721 compliant");
    }

    /// @notice 授權某人可以轉移你的 NFT
    function approve(address to, uint256 tokenId) public {
        address owner = _owners[tokenId];
        require(msg.sender == owner || _operatorApprovals[owner][msg.sender], "Not owner or operator");
        _approve(to, tokenId);
    }

    /// @notice 取得 NFT 的授權地址
    function getApproved(uint256 tokenId) public view returns (address) {
        require(_owners[tokenId] != address(0), "Token does not exist");
        return _tokenApprovals[tokenId];
    }

    /// @notice 批量授權某人管理所有 NFT
    function setApprovalForAll(address operator, bool approved) public {
        require(operator != msg.sender, "Cannot approve self");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /// @notice 檢查某人是否獲得授權管理所有 NFT
    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /// @dev 授權內部函數
    function _approve(address to, uint256 tokenId) internal {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    /// @dev 檢查 msg.sender 是否擁有 NFT 或獲得授權
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_owners[tokenId] != address(0), "Token does not exist");
        address owner = _owners[tokenId];
        return (spender == owner || _tokenApprovals[tokenId] == spender || _operatorApprovals[owner][spender]);
    }

    /// @dev 簡化 ERC721Receiver 檢查（移除未使用變數）
    function _checkOnERC721Received() private pure returns (bool) {
        return true;
    }
}
