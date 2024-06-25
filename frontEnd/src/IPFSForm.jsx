import React, { useState } from "react";
import Web3 from "web3";
import axios from "axios";

await window.ethereum.request({ method: "eth_requestAccounts" });
const web3 = await new Web3(window.ethereum || "http://localhost:8545");
const contractABI = [
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "patientAddress",
        type: "address",
      },
      {
        indexed: false,
        internalType: "string",
        name: "ipfsHash",
        type: "string",
      },
    ],
    name: "MedicalRecordAdded",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "patientAddress",
        type: "address",
      },
      { indexed: false, internalType: "string", name: "name", type: "string" },
      { indexed: false, internalType: "uint256", name: "age", type: "uint256" },
    ],
    name: "PatientRegistered",
    type: "event",
  },
  {
    inputs: [
      { internalType: "string", name: "_ipfsHash", type: "string" },
      { internalType: "address", name: "patientAddress", type: "address" },
    ],
    name: "addMedicalRecord",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      { internalType: "address", name: "_providerAddress", type: "address" },
    ],
    name: "authorizeAddress",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      { internalType: "address", name: "_patientAddress", type: "address" },
    ],
    name: "getPatientDetails",
    outputs: [
      { internalType: "string", name: "", type: "string" },
      { internalType: "uint256", name: "", type: "uint256" },
      { internalType: "string[]", name: "", type: "string[]" },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      { internalType: "string", name: "_name", type: "string" },
      { internalType: "uint256", name: "_age", type: "uint256" },
    ],
    name: "registerPatient",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      { internalType: "address", name: "_providerAddress", type: "address" },
    ],
    name: "revokeAccess",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
];

const contractAddress = "0xf0D91126cb4A7D09Ee9ca54e8f35b00C72B2d388";
const contract = new web3.eth.Contract(contractABI, contractAddress);

const pinataApiKey = "a8737583a19153819825";
const pinataSecretApiKey =
  "177138a58d1fa635f0429976570a387a5187c73a1bd4bf64467b85e295bb38f4";

const UploadForm = () => {
  const [account, setAccount] = useState("");
  const [form, setForm] = useState({
    name: "",
    age: "",
    description: "",
  });

  const connectWallet = async () => {
    const accounts = await web3.eth.requestAccounts();
    setAccount(accounts[0]);
  };

  const handleInputChange = (event) => {
    const { name, value } = event.target;
    setForm({ ...form, [name]: value });
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    const formData = JSON.stringify(form);

    try {
      const response = await axios.post(
        "https://api.pinata.cloud/pinning/pinJSONToIPFS",
        { pinataContent: formData },
        {
          headers: {
            pinata_api_key: pinataApiKey,
            pinata_secret_api_key: pinataSecretApiKey,
          },
        }
      );

      const ipfsHash = response.data.IpfsHash;
      await contract.methods.addForm(ipfsHash).send({ from: account });
      alert("Form uploaded to IPFS and hash stored on blockchain!");
    } catch (error) {
      console.error("Error uploading form:", error);
    }
  };

  return (
    <div>
      <button onClick={connectWallet}>Connect Wallet</button>
      <form onSubmit={handleSubmit}>
        <div>
          <label>
            Name:
            <input
              type="text"
              name="name"
              value={form.name}
              onChange={handleInputChange}
              require
            />
          </label>
        </div>
        <div>
          <label>
            Age:
            <input
              type="number"
              name="age"
              value={form.age}
              onChange={handleInputChange}
              require
            />
          </label>
        </div>
        <div>
          <label>
            Description:
            <input
              type="text"
              name="description"
              value={form.description}
              onChange={handleInputChange}
              require
            />
          </label>
        </div>
        <button type="submit">Submit</button>
      </form>
    </div>
  );
};

export default UploadForm;
