// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract MyToken is ERC20, ERC20Permit {

    error ERC20InvalidLocked(address sender);

    constructor() ERC20("BFB Sport", "BFB") ERC20Permit("BFB Sport") Ownable(_msgSender()) {
        _typeOfs[0] = typeOf({_all: uint64(12075000000000000), _mint:uint64(0), _lock:uint8(0),_rate:uint8(0)});  // 24.15 + 24.15 + 72.45
        _typeOfs[1] = typeOf({_all: uint64(1050000000000000), _mint:uint64(0), _lock:uint8(0),_rate:uint8(0)});   //10.5
        _typeOfs[2] = typeOf({_all: uint64(1050000000000000), _mint:uint64(0), _lock:uint8(1),_rate:uint8(20)});  //10.5
        _typeOfs[3] = typeOf({_all: uint64(525000000000000), _mint:uint64(0), _lock:uint8(0),_rate:uint8(0)});    //5.25
        _typeOfs[4] = typeOf({_all: uint64(1050000000000000), _mint:uint64(0), _lock:uint8(0),_rate:uint8(0)});   //10.5
        _typeOfs[5] = typeOf({_all: uint64(4200000000000000), _mint:uint64(0), _lock:uint8(12),_rate:uint8(25)}); //42
        _typeOfs[6] = typeOf({_all: uint64(1050000000000000), _mint:uint64(0), _lock:uint8(12),_rate:uint8(25)}); //10.5
    }

    function mint(address to, uint256 amount, uint8 key_) public onlyOwner {
        typeOf memory _has = _typeOfs[key_];
        if(_has._all <= 0) {
            revert ERC20InsufficientBalance(address(0), (uint256(_has._all) - uint256(_has._mint)), amount);
        }
        if(uint256(_has._mint) + amount > uint256(_has._all)) {
            revert ERC20InsufficientBalance(address(0), (uint256(_has._all) - uint256(_has._mint)), amount);
        }
        if(_has._lock > 0) {
            lockOf memory _old = _lockOfs[to];
            if (_old._locked > 0) {
                revert ERC20InvalidLocked(to);
            } else {
                lockOf memory _newLock = lockOf({_time: uint32(block.timestamp) , _lock: _has._lock, _rate: _has._rate, _locked: uint64(amount)});
                _lockOfs[to] = _newLock; 
            }
        }
        _mint(to, amount);
        _typeOfs[key_]._mint += uint64(amount);
    }

    function burn(uint256 amount) public onlyOwner {
        _burn(_msgSender(), amount);
    }

    function site(string memory url_) public onlyOwner{
        website = url_;
    }

}
