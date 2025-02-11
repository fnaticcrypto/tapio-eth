// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";

/**
 * @title StableAssetToken
 * @author Nuts Finance Developer
 * @notice ERC20 token used by the StableSwap pool
 * @dev The StableAssetToken contract represents the ERC20 token used by the StableSwap pool
 * This token can be minted by designated minters and burned by its owner. The governance address can
 * be updated to change who has the ability to manage minters and other aspects of the token
 */
contract StableAssetToken is ERC20BurnableUpgradeable {
  /**
   * @dev Emitted when the governance address is updated.
   * @param account Address of the new governance.
   */
  event MinterUpdated(address indexed account, bool allowed);

  /**
   * @dev This event is emitted when the governance is modified.
   * @param governance is the new value of the governance.
   */
  event GovernanceModified(address governance);

  /**
   * @dev This event is emitted when the governance is modified.
   * @param governance is the new value of the governance.
   */
  event GovernanceProposed(address governance);

  /**
   * @dev Governance address for the stable swap token.
   */
  address public governance;
  /**
   * @dev Mapping of minters.
   */
  mapping(address => bool) public minters;

  /**
   * @dev Pending governance address for the token.
   */
  address public pendingGovernance;

  /**
   * @dev Initializes stable swap token contract.
   * @param _name Name of the stable swap token.
   * @param _symbol Symbol of the stable swap token.
   */
  function initialize(
    string memory _name,
    string memory _symbol
  ) public initializer {
    __ERC20_init(_name, _symbol);
    governance = msg.sender;
  }

  /**
   * @dev Propose the govenance address.
   * @param _governance Address of the new governance.
   */
  function proposeGovernance(address _governance) public {
    require(msg.sender == governance, "not governance");
    pendingGovernance = _governance;
    emit GovernanceProposed(_governance);
  }

  /**
   * @dev Accept the govenance address.
   */
  function acceptGovernance() public {
    require(msg.sender == pendingGovernance, "not pending governance");
    governance = pendingGovernance;
    pendingGovernance = address(0);
    emit GovernanceModified(governance);
  }

  /**
   * @dev Sets minter for stable swap token. Only minter can mint stable swap token.
   * @param _user Address of the minter.
   * @param _allowed Whether the user is accepted as a minter or not.
   */
  function setMinter(address _user, bool _allowed) public {
    require(msg.sender == governance, "not governance");
    minters[_user] = _allowed;

    emit MinterUpdated(_user, _allowed);
  }

  /**
   * @dev Mints new stable swap token. Only minters can mint stable swap token.
   * @param _user Recipient of the minted stable swap token.
   * @param _amount Amount of stable swap token to mint.
   */
  function mint(address _user, uint256 _amount) public {
    require(minters[msg.sender], "not minter");
    _mint(_user, _amount);
  }

  /**
   * @dev Burn swap token. Only minters can burn stable swap token.
   * @param _amount Amount of stable swap token to burn.
   */
  function burn(uint256 _amount) public override {
    require(minters[msg.sender], "not minter");
    _burn(_msgSender(), _amount);
  }

  /**
   * @dev Burn from users stable swap token. Only minters can burn stable swap token.
   * @param _account Account of stable swap token to burn.
   * @param _amount Amount of stable swap token to burn.
   */
  function burnFrom(address _account, uint256 _amount) public override {
    require(minters[msg.sender], "not minter");
    _spendAllowance(_account, _msgSender(), _amount);
    _burn(_account, _amount);
  }
}
