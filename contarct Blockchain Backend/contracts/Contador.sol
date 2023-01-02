//SPDX-License-Identifier: UNLICENSED

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.

// ESTE CONTRATO NOS ENSENA COMO UTILIZAR LOS DIFERENTES MODIFICADORES DE LAS FUNCIONES COMO PURE, VIEW Y TAMBIEN COMO AUMENTAR UN
// Y DISMINUIR UN NUMERO POR MEDIO DE FUNCIONES DEL CONTRATO

pragma solidity ^0.8.9;
contract Contador{
    uint count;

    constructor(uint _count){//ESTE ES EL CONSTRUCTOR
        count = _count;
    }
    function setCount(uint _count) public{// si la funcion no contiene view/pure/payable significa
    // que puede leer y cambiar el estado
        count = _count;
    }
    function incrementCount() public{// si la funcion no contiene view/pure/payable significa
    // que puede leer y cambiar el estado
        count += 1;
    } 
    function decrementCount() public{
        count-= 1;  
    }
    function getCount() public view returns(uint){//la funcion solo puede ver el estado pero no cambiarlo
    //porque tiene el keyword view.  ESTA INSTRUCCION NO CONSUME GAS
        return count;
    }
    function getNumber() public pure returns(uint){//la funcion no permite cambiar ni leer el estado, solo 
    //puede hacer calculos regresando sus propias variables de la funcion al entorno (). ESTA INSTRUCCION NO CONSUME GAS
        uint nuevo = 3 ;
        uint cla = nuevo;
        return cla;
    }
}