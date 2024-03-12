// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

//Interfaz
interface IERC20 {
    
    //totalSupply: Devuelve la cantidad de Tokens disponibles en el smart contract
    function totalSupply () external view returns (uint256);
    //balanceOf: devuelve la cantidad de tokens asociada (o que tiene) a cada cuenta.
    function balanceOf (address account) external view returns (uint256);
    //Transfer: ejecuta la transaccion de una de cantidad de tokens a una cuenta
    function transfer (address to, uint256 amount) external returns(bool);
    //Allowance: asigancion de permisos del owner a otra cuenta para gastar una cantidad concreta de Ethers
    function allowance (address owner, address spender) external returns (uint256);
    //Approve: determina la cantidad exacta de ethers que el owner le permite gastar al spender
    function approve (address spender, uint256 amount) external returns(bool);
    //transferFrom: Indica la dirreccion del emisor de la transacción
    function transferFrom(address from, address to, uint256 amount) external returns(bool);

    //Transfer (event): se emite al reaalizarse la transferencia de ethers
    event Transfer (address indexed from, address indexed to, uint256 value);
    //Approval (event): se emite caundo el owner asigna permisos a un spender
    event Approval (address indexed owner, address indexed  spender, uint256 value);

}

//Smart Contract
contract ERC20 is IERC20 {

    //ESTRUCTURAS DE DATOS
    //_balances: relaciona una direccion con su balance
    mapping (address => uint256) private _balances;
    //_allowance: relaciona el owner hacia un valor que será el spender y la cantidad de ethers que se le han asignado
    mapping (address => mapping (address => uint256)) private _allowances;

    //VARIABLES
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    //CONSTRUCTOR
    constructor(string memory name_, string memory symbol_){
        _name = name_;
        _symbol = symbol_;
    }

    //FUNCIONES BÁSICAS

    //FUNCIONES DE AYUDA(similares a los getters y setters de Java)
    function name() public view virtual returns(string  memory){
        return  _name;
    }

    function symbol() public view virtual returns (string memory){
        return _symbol;
    }

   //decimals: determona y contiene los decimales establecidos para nuestro token ERC20
   function decimals () public view virtual returns (uint8){
    return 18;//asi esta establecido en el estándar.
   }

   function totalSupply()public view virtual override returns (uint256){
        return _totalSupply;
   }

   function balanceOf (address account)public view virtual override returns (uint256){
        return _balances[account];
   }



 //FUNCIONES ELEMENTALES
 
 function transfer (address to, uint256 amount) public virtual override returns (bool){
    address owner = msg.sender;
    _transfer(owner, to, amount);
    return true;
 }

 function allowance(address owner, address spender) public view virtual override returns(uint256){
    return _allowances[owner][spender];
 }

 function approve(address spender, uint256 amount) public  virtual override returns (bool){
    address owner = msg.sender;
    _approve(owner, spender, amount);
    return true;

 }

 function transferFrom(address from,
  address to, 
  uint256 amount)public virtual override returns (bool){
    address spender = msg.sender;
    _spendAllowance(from, spender, amount);
    _transfer(from, to, amount);
    return true;

 }

//FUNCIONES PARA MODIFICAR LA ASIGNACION DE TOKENS
 function increaseAllowance(address spender, uint256 addValue) public virtual returns(bool){
    address owner = msg.sender;
    _approve(owner, spender, _allowances[owner][spender] + addValue);
    return true;
 }

  function decreaseAllowance(address spender, uint256 substractedValue) public virtual returns(bool){
    address owner = msg.sender;
    uint256 currentAllowance = _allowances[owner][spender];
    require (currentAllowance>=substractedValue, "ERC20 decreased allowance bellow zero");
    _approve(owner, spender, currentAllowance - substractedValue);
    unchecked { //sentencia para ahorrar gas en terminos de comprobaciones internas de solidity
        _approve(owner, spender, currentAllowance - substractedValue);

    }   
    return true;
 

 }

 //FUNCIONES INTERNAS
function _transfer(
    address from,
    address to,
    uint256 amount
 ) internal virtual{
    require (from != address(0), "ERC20: transfer from the zero addres ");
    require(to  != address(0), "ERC20: Transfer to the zero address");
    _beforeTokenTransfer(from, to, amount);
    uint256 fromBalance = _balances[from];
    require(fromBalance >= amount, "ERC20: transfer mount exceeds balance");
    
    //Actualizamos el balance del usuario
    unchecked{
        _balances[from] = fromBalance - amount;
    }

    _balances[to] += amount;
    emit Transfer(from, to, amount);
    _afterTokenTransfer(from, to,amount);
 }

//mint: funcion que nos permite crear tokens ERC20 y los vamos a asignar
function _mint(address account, uint amount)internal virtual{
    require(account!= address(0), "ERC20: mint to the zero address");
    _beforeTokenTransfer(address(0), account, amount);
    
    //Actualizamos el total de Tokens
    _totalSupply += amount;
    //Actualizamos el balance de la cuenta
    _balances[account] += amount;
    emit Transfer(address(0), account, amount);
    _afterTokenTransfer(address(0), account, amount);
}

//_burn: funcion que nos permite destruir Tokens
function _burn(address account, uint256 amount) internal virtual{
    require (account != address(0), "ERC20: burn from zero address");
    _beforeTokenTransfer(account, address(0), amount);
    uint256 accountBalance = _balances[account];
    require(accountBalance >= amount,"ERC20: burn amount exceeds balance");
    
    //Actualizamos balance de la cuenta
    unchecked {
        _balances[account] = accountBalance - amount;

    }

    //Actualizamos el total detokens disponibles
    _totalSupply -= amount;
    emit Transfer(account, address(0), amount);
    _afterTokenTransfer(account, address(0), amount);
}

    function _approve(
        address owner,
        address spender,
        uint256 amount
    )internal virtual{
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
        
    }

    function _spendAllowance(
    address owner,
     address spender, 
     uint256 amount)internal virtual{
        uint256 currentAllowance = allowance(owner, spender);
        if(currentAllowance != type(uint256).max){
            require(currentAllowance >= amount, "ERC20: insuficient allowance");
            unchecked{
                _approve(owner, spender,amount);
            }
        }
     }

     //HOOKS DEL ERC20

     /*
     _before & _after: se usa encaso de queheredemos este Smart Contract y Nos permite establecer condiciones o acciones 
     a realizar antes/después de efectuarse la transferencia de Tokens
     */
      function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
      )internal virtual{}

       function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
      )internal virtual{}



}