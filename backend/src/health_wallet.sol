// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract HealthDataWallet {
    // struct to hold patient info
    struct Patient {
        string name;
        uint age;
        address patientAddress;
        mapping(address => bool) authorizedAddresses;
        string[] medicalRecords;
    }

    // Mapping from patient wallet address to patient data (Patient Struct)
    mapping(address => Patient) private patients;

    // Mapping patient ID to Patient struct
    mapping(uint => Patient) private patientData;

    // checks if patient already exists
    mapping(address => bool) private existingPatients;

    // Event to be emitted when a new patient is registered
    event PatientRegistered(
        address indexed patientAddress,
        string name,
        uint age
    );

    // Event to be emitted when a new patient record is added
    event MedicalRecordAdded(address indexed patientAddress, string ipfsHash);

    // Modifier to check if patient exists
    modifier onlyPatient() {
        require(existingPatients[msg.sender], "Not a Registered Patient");
        _;
    }

    // modifier to check if a caller is an authorized address
    modifier onlyAuthorizedAddress(address patientAddress) {
        require(
            patients[patientAddress].authorizedAddresses[msg.sender],
            "Not an authorized address"
        );
        _;
    }

    // Function to register a new patient
    function registerPatient(string memory _name, uint _age) public {
        require(bytes(_name).length > 0, "Add patient name");
        require(_age > 0, "Age must be greater than zero");
        require(!existingPatients[msg.sender], "Patient already exists");

        // Create new patient record
        Patient storage patient = patients[msg.sender];
        patient.name = _name;
        patient.age = _age;
        patient.patientAddress = msg.sender;
        authorizedAddresses[msg.sender] = true;
        existingPatients[msg.sender] = true;
        emit PatientRegistered(msg.sender, _name, _age);
    }

    // Function authorizes address
    function authorizeAddress(address _providerAddress) public onlyPatient {
        require(
            !patients[msg.sender].authorizedAddresses[_providerAddress],
            "Already authorized"
        );
        patients[msg.sender].authorizedAddresses[_providerAddress] = true;
    }

    // Function to add a new medical record
    function addMedicalRecord(
        string memory _ipfsHash,
        address patientAddress
    ) public onlyAuthorizedAddress(patientAddress) {
        require(bytes(_ipfsHash).length > 0, "IPFS hash cannot be empty");
        require(patients[patientAddress].age != 0, "Patient does not exist");
        Patient storage patient = patients[patientAddress];
        // Add the IPFS hash to the patient medical record
        patient.medicalRecords.push(_ipfsHash);

        emit MedicalRecordAdded(msg.sender, _ipfsHash);
    }

    // Function to get patient details
    function getPatientDetails(
        address _patientAddress
    )
        public
        view
        onlyAuthorizedAddress(_patientAddress)
        returns (string memory, uint, string[] memory)
    {
        Patient storage patient = patients[_patientAddress];
        return (patient.name, patient.age, patient.medicalRecords);
    }

    // Function to rovoke access from a medical provider
    function revokeAccess(address _providerAddress) public onlyPatient {
        patients[msg.sender].authorizedAddresses[_providerAddress] = false;
    }
}
