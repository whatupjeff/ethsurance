pragma solidity 0.4.24;

import "@aragon/os/contracts/apps/AragonApp.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract InsuranceFund is AragonApp, ERC721Holder {
    IERC721 public poap;

    bytes32 public constant JOIN_ROLE = keccak256("JOIN_ROLE");

    mapping(address => bool) public members;

    event MemberJoined(address indexed member);
    event ClaimPaid(address indexed member, uint256 amount);

    function initialize(address _poap) public onlyInit {
        initialized();
        poap = IERC721(_poap);
    }

    /**
     * @notice Join the insurance fund
     */
    function join() external auth(JOIN_ROLE) {
        require(poap.balanceOf(msg.sender) > 0, "Must hold a POAP to join");
        require(!members[msg.sender], "Already a member");

        members[msg.sender] = true;

        emit MemberJoined(msg.sender);
    }

    /**
     * @notice Pay an insurance claim to `member` for `amount`
     * @param member The member to pay the claim to
     * @param amount The amount to pay
     */
    function payClaim(address member, uint256 amount) external auth(JOIN_ROLE) {
        require(members[member], "Not a member");

        require(address(this).balance >= amount, "Insufficient funds");

        (bool success, ) = member.call.value(amount)("");
        require(success, "Transfer failed");

        emit ClaimPaid(member, amount);
    }
}
