pragma solidity ^0.4.24;

import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "./TokenRecipient.sol";
import "./TokenStorage.sol";

library ERC20Lib {
    using SafeMath for uint;

    // EVENTS
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    // EXTERNAL
    function transfer(TokenStorage db, address _caller, address _to, uint _value) 
        external
        returns (bool success) 
    {
        db.subBalance(_caller, _value);
        db.addBalance(_to, _value);
        emit Transfer(_caller, _to, _value);
        return true;
    }

    function transferFrom(
        TokenStorage db, 
        address _caller, 
        address _from, 
        address _to, 
        uint _value
    ) 
        external
        returns (bool success) 
    {
        uint allowance = db.getAllowed(_from, _caller);
        db.subBalance(_from, _value);
        db.addBalance(_to, _value);
        db.setAllowed(_from, _caller, allowance.sub(_value));
        emit Transfer(_from, _to, _value);
        return true;
    }

    // TODO: race condition
    function approve(TokenStorage db, address _caller, address _spender, uint _value) 
        public
        returns (bool success) 
    {
        db.setAllowed(_caller, _spender, _value);
        emit Approval(_caller, _spender, _value);
        return true;
    }

    // TODO: race condition
    function approveAndCall(
        TokenStorage db, 
        address _caller, 
        address _spender, 
        uint256 _value, 
        bytes _extraData
    ) 
        external
        returns (bool success) 
    {
        TokenRecipient spender = TokenRecipient(_spender);
        if (approve(db, _caller, _spender, _value)) {
            spender.receiveApproval(_caller, _value, this, _extraData);
            return true;
        }
    }        

    // EXTERNAL CONSTANT
    function balanceOf(TokenStorage db, address _owner) 
        external
        view 
        returns (uint balance) 
    {
        return db.getBalance(_owner);
    }

    function allowance(TokenStorage db, address _owner, address _spender) 
        external
        view 
        returns (uint remaining) 
    {
        return db.getAllowed(_owner, _spender);
    }
}
