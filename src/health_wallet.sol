// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract HealthDataWallet {
    // structure to hold patient info
    struct Patient {
        string name;
        uint age;
        uint patientID;
        address patientAddress;
        address[] authorizedAddresses;
        string[] medicalRecords;
    }

    // Mapping from patient wallet address to patient data (Patient Struct)
    mapping(address => Patient) private patients;

    // Mapping patient ID to Patient struct
    mapping(uint => Patient) private patientData;

    // Mapping of a providerAddress to Patient Struct to a bool: for granting and revoking access to patients
    mapping(address => mapping(Patient => bool)) private grantAccess;

    // Event to be emitted when a new patient is registered
    event PatientRegistered(
        address indexed patientAddress,
        string name,
        uint age
    );

    // Event to be emitted when a new patient record is added
    event MedicalRecordAdded(address indexed patientAddress, string ipfsHash);

    // Modifier to check if the caller is the patient
    modifier onlyPatient(address _patientAddress) {
        require(msg.sender == _patientAddress, "You are not authorized");
        _;
    }

    // Function to register a new patient
    function registerPatient(
        string memory _name,
        uint _age,
        uint _patientID
    ) public {
        require(bytes(_name).length > 0, "Add patient name");
        require(_age > 0, "Age must be greater than zero");

        // Create new patient record
        Patient storage patient = patients[msg.sender];
        patient.name = _name;
        patient.age = _age;
        patient.patientAddress = msg.sender;
        patient.patientID = _patientID;
        grantAccess[msg.sender][_patientID] = true;
        emit PatientRegistered(msg.sender, _name, _age);
    }

    // Function to add authorized addresses
    function authorizeAddress(address _providerAddress, uint patientID) public {
        require(
            msg.sender == patientData[patientID].patientAddress,
            "You cannot access this patient"
        );
        grantAccess[_providerAddress][patient] = true;
    }

    // Function to check if address is authorized
    function isAuthorized(
        address _providerAddress,
        uint patientID
    ) public returns (bool) {
        Patient storage patient = patientData[patientID];

        if (grantAccess[_providerAddress][patient]) {
            return true;
        }

        return false;
    }

    // Function to add a new medical record
    function addMedicalRecord(string memory _ipfsHash, uint patientID) public {
        Patient storage patient = patientData[patientID];
        require(bytes(_ipfsHash).length > 0, "IPFS hash cannot be empty");
        require(
            isAuthorized(msg.sender, patientID),
            "You cannot access this patient"
        );

        // Add the IPFS hash to the patient medical record
        patient.medicalRecords.push(_ipfsHash);

        emit MedicalRecordAdded(msg.sender, _ipfsHash);
    }

    // Function to get patient details
    function getPatientDetails(
        address _patientAddress,
        uint patientID
    )
        public
        view
        returns (string memory name, uint age, string[] memory medicalRecords)
    {
        require(
            isAuthorized(msg.sender, patientID),
            "You cannot access this patient"
        );
        Patient storage patient = patients[_patientAddress];
        return (patient.name, patient.age, patient.medicalRecords);
    }

    // Function to rovoke access from a medical provider
    function revokeAccess(address _providerAddress, uint patientID) public {
        Patient storage patient = patientData[patientID];
        require(
            isAuthorized(_providerAddress, patientID),
            "This provider does not have access"
        );

        grantAccess[_providerAddress][patient] = false;
    }
}
