// https://docs.metamask.io/guide/ethereum-provider.html#using-the-provider

import React, {useState} from 'react'
import {ethers} from 'ethers'
// import './WalletCard.css'
import employerContract from "./Employer.json"

const WalletCard = () => {

	const [errorMessage, setErrorMessage] = useState(null);
	const [defaultAccount, setDefaultAccount] = useState(null);
	const [userBalance, setUserBalance] = useState(null);
	const [connButtonText, setConnButtonText] = useState('Connect Wallet');
	const [employerSignedContract, setEmployerSignedContract] = useState(null);
	const [employeeSalary, setEmployeeSalary] = useState(null);

    // const connectWalletHandler = () => {

    // }

	const employerContractAbi = employerContract.abi;

	const employerContractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";

	const getSignedContract = (address, abi) => {
		const { ethereum } = window;
	
		const provider = new ethers.providers.Web3Provider(ethereum, "any");
	
		const signer = provider.getSigner();
		return new ethers.Contract(address, abi, signer);
	}
 
    
	const connectWalletHandler = () => {
		if (window.ethereum && window.ethereum.isMetaMask) {
			// console.log('MetaMask Here!');

			window.ethereum.request({ method: 'eth_requestAccounts'})
			.then(result => {
				accountChangedHandler(result[0]);
				setConnButtonText('Wallet Connected');
				// console.log(employerContractAbi)
				setEmployerSignedContract(getSignedContract(employerContractAddress, employerContractAbi));
				getAccountBalance(result[0]);
			})
			.catch(error => {
				console.log(error);
				setErrorMessage(error.message);
			
			});

		} else {
			// console.log('Need to install MetaMask');
			setErrorMessage('Please install MetaMask browser extension to interact');
		}
	}

	// update account, will cause component re-render
	const accountChangedHandler = (newAccount) => {
		setDefaultAccount(newAccount);
		getAccountBalance(newAccount.toString());
	}

	const getAccountBalance = (account) => {
		window.ethereum.request({method: 'eth_getBalance', params: [account, 'latest']})
		.then(balance => {
			setUserBalance(ethers.utils.formatEther(balance));
		})
		.catch(error => {
			setErrorMessage(error.message);
		});
	};

	const chainChangedHandler = () => {
		// reload the page to avoid any errors with chain change mid use of application
		window.location.reload();
	}

	const addEmployee = () => {
		employerSignedContract.addEmployee("0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199", 3000);
	}

	const getEmployeeSalary = async (address) => {
		const es = await employerSignedContract.getSalary(address)
		const intEs = parseInt(es._hex, 16)
		console.log(intEs)
		setEmployeeSalary(intEs);
	}

	

	// // listen for account changes
	window.ethereum.on('accountsChanged', accountChangedHandler);

	window.ethereum.on('chainChanged', chainChangedHandler);
	
	return (
		<div className='walletCard'>
		<h4> {"Connection to MetaMask using window.ethereum methods"} </h4>
			<button onClick={connectWalletHandler}>{connButtonText}</button>
			<div className='accountDisplay'>
				<h3>Address: {defaultAccount}</h3>
			</div>
			<div className='balanceDisplay'>
				<h3>Balance: {userBalance}</h3>
			</div>
			<div>
				{employerSignedContract && <button onClick={addEmployee}>Add Employee</button>}
				<button onClick={() => getEmployeeSalary("0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199")}>Check employee's salary</button> 
				{employeeSalary}
			</div>
			
			{errorMessage}
		</div>
	);
}

export default WalletCard;