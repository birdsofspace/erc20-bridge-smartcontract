/*
* Check if browser supports DApps
*/
if (typeof window.ethereum === 'undefined') {
    alert('Please use browser supporting DApps!');
}


/*
* Creates a web3 provider that can be used to retrieve contracts and abi. This is the first step in the contract process
*/
let provider = new ethers.providers.Web3Provider(window.ethereum);
let contractAddress;
let abi;

/**
* Fetch data from a URL. This is a wrapper around fetch that handles errors
* 
* @param url - The URL to fetch data from
* 
* @return { Promise } The data as an object with keys : results : Array of
*/
async function fetchData(url) {
    try {
        const response = await fetch(url);
        const data = await response.json();
        return data.results;
    } catch (error) {
        console.error('Error fetching data:', error);
    }
}

/**
* Creates select options for contract selection. This function is called from contract availability
* 
* @param data - List of data to
*/
function createSelectOptions(data) {
    const select = document.getElementById('selectContract');
    select.innerHTML = '<option value="">Select</option>';

    data.forEach(item => {
        const option = document.createElement('option');
        option.value = JSON.stringify(item.json_abi) + "-" + item.contract_address;
        const contractCheck = new ethers.Contract(item.contract_address, item.json_abi);

        option.textContent = item?.contract_name + ' (' + item.contract_address + ')';
        select.appendChild(option);
    });
}

/*
* Loads the smart contract from the server and adds event listeners to the select element
*/
window.addEventListener('load', async () => {
    const data = await fetchData('smartcontract.json');
    createSelectOptions(data);
    const select = document.getElementById('selectContract');
    select.addEventListener('change', async (event) => {
        let valuex = event.target.value.split("-");
        contractAddress = valuex[1];
        abi = JSON.parse(valuex[0]);
        changeContract();
    });
});


/**
* Changes the contract to a new one. This is called on clicking the contract button.
* 
* 
* @return { HTMLElement } The form that was updated with the new contract
*/
function changeContract() {
    const abiForm = document.getElementById('abiForm');
    abiForm.innerHTML = '';
    abi.forEach(item => {
        // This is a function that is called when the item is a function.
        if (item.type === 'function') {
            const inputs = item.inputs.map(input => {
                return `<input type="text" name="${input.name}" placeholder="${input.name}" class="block w-full border rounded-md px-2 py-1">`;
            }).join('');

            const stateMutabilityLabel = `<label class="block mb-2">State Mutability: ${item.stateMutability}</label>`;

            const button = `<button type="button" web3fnc="${item.name}" web3sm="${item.stateMutability}" class="inline-flex items-center px-4 py-2 bg-blue-500 hover:bg-blue-700 text-white font-bold rounded-md">Call ${item.name}</button>`;

            const fieldset = document.createElement('fieldset');
            fieldset.innerHTML = `<legend class="font-bold">${item.name}</legend>${stateMutabilityLabel}${inputs}${button}`;

            var form = document.createElement('form');
            form.setAttribute("id", item.name);
            abiForm.appendChild(form).appendChild(fieldset);

        }
    });
    const web3buttons = document.querySelectorAll('button');
    web3buttons.forEach(button => {
        button.addEventListener('click', () => {
            const web3Fnc = button.getAttribute('web3fnc');
            const web3SM = button.getAttribute('web3sm')
            submitForm(web3Fnc, web3SM);
        });
    });
}

/**
* Connects to Ethereum's MetaMask and returns the signer. This is a low - level function and should not be used in production code.
* 
* @return { Promise } A promise that resolves to the signer
*/
async function connectToMetaMask() {
    // If you have a MetaMask installed on the browser
    if (!window.ethereum) {
        throw new Error("Please install MetaMask!");
    }

    const provider = new ethers.providers.Web3Provider(window.ethereum);
    await provider.send("eth_requestAccounts", []);
    const signer = provider.getSigner();
    return signer;
}

/*
* Function to submit form
*/
/**
* Submit form to the contract and display the result to the user. This is a wrapper around the contract method that takes care of creating the transaction and sending it
* 
* @param functionName - Name of the function to call
* @param stateMutability - Whether or not to mutate the state
*/
async function submitForm(functionName, stateMutability) {
    const formData = new FormData(document.getElementById(functionName));
    const data = {};
    for (const [key, value] of formData.entries()) {
        data[key] = value;
    }
    const signer = await connectToMetaMask();
    const contract = new ethers.Contract(contractAddress, abi, signer);
    try {
        console.log(contractAddress);
        const tx = await contract[functionName](...Object.values(data));
        let jsonString = JSON.stringify(tx, null, 2);
        Toastify({
            close: true,
            duration: -1,
            text: jsonString,
            className: "info",
            style: {
                background: "linear-gradient(to right, #00b09b, #96c93d)",
            }
        }).showToast();
        console.log("Transaction sent:", tx);
    } catch (error) {
        Toastify({
            close: true,
            duration: -1,
            text: error.message,
            className: "error",
        }).showToast();
        console.error("Error calling function:", error);
    }
}