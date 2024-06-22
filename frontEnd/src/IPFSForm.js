import React, { useState } from "react";
import Web3 from "web3";
import axios from "axios";

const web3 = new Web3(web3.givenProvider || "http://localhost:8545");
const contractABI = [];
const contractAddess = "contractAddress";
const contract = new web3.eth.Contract(contractABI, contractAddress);

const pinataApiKey = "pinataKey";
const pinataSecretApiKey = "secretKey";

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
