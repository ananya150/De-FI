import React, { useEffect, useState } from "react";
import { ethers } from "ethers";

// in developement , ethers.js is still to add and connect to contracts


function App() {
  const [inputs, setInputs] = useState({
    address: "",
    code: "",
    area: "",
    protection: "",
    id: "",
    proof: "",
    proofInputs: "",
  });

  const [register, setRegister] = useState(false);

  const provider = new ethers.providers.Web3Provider(window.ethereum)
  const signer = provider.getSigner()

  useEffect(() => {
    
    const connectWallet = async () => {
      await provider.send("eth_requestAccounts", []);
    }

    connectWallet()
      .catch(console.error)

  })


  const handleAddressInputChange = (e) => {
    setInputs({ ...inputs, address: e.target.value });
  };

  const handleCodeInputChange = (e) => {
    setInputs({ ...inputs, code: e.target.value });
  };

  const handleAreaInputChange = (e) => {
    setInputs({ ...inputs, area: e.target.value });
  };

  const handleFloodInputChange = () => {
    setInputs({ ...inputs, protection: true });
  };

  const handleDroughtInputChange = () => {
    setInputs({ ...inputs, protection: false });
  };

  const handleIdInputChange = (e) => {
    setInputs({ ...inputs, id: e.target.value });
  };

  const handleProofInputChange = (e) => {
    setInputs({ ...inputs, proof: e.target.value });
  };

  const handleProofInputsInputChange = (e) => {
    setInputs({ ...inputs, proofInputs: e.target.value });
  };

  const handleRegister = (e) => {
    e.preventDefault();
    setRegister(true);
    console.log("checked");
    console.log(inputs.address);
    console.log(inputs.id);
    console.log(inputs.area);
    console.log(inputs.protection);
    console.log(inputs.proof);
    console.log(inputs.proofInputs);
  };

  return (
    <div className="container">
      <div className="container text-center">
        <div className="row">
          <div className="col">
            <h3>Register</h3>

            <p>Register for crop insurance</p>
            <br></br>
            <br></br>

            <form className="check-form" onSubmit={handleRegister}>
              {register ? (
                <div className="success-message">Verification Done</div>
              ) : null}
              <div className="mb-3">
                <label htmlFor="InputAddress" className="form-label">
                  Address
                </label>
                <input
                  type="text"
                  className="form-control"
                  id="InputAddress"
                  aria-describedby="address"
                  onChange={handleAddressInputChange}
                  value={inputs.address}
                />
                <div id="addressHelp" className="form-text">
                  Land Address as mentioned in official Document.
                  <br></br>
                  <br></br>
                </div>
              </div>

              <div className="mb-3">
                <label htmlFor="InputDistrictCode" className="form-label">
                  District Code
                </label>
                <input
                  type="nymber"
                  className="form-control"
                  id="InputDistrictCode"
                  aria-describedby="districtCode"
                  onChange={handleCodeInputChange}
                  value={inputs.code}
                />
                <div className="form-text">
                  District code as mentioned in official Document.
                  <br></br>
                  <br></br>
                </div>
              </div>

              <div className="mb-3">
                <label htmlFor="InputLandArea" className="form-label">
                  Land Area
                </label>
                <input
                  type="number"
                  className="form-control"
                  id="InputLandArea"
                  aria-describedby="landArea"
                  value={inputs.area}
                  onChange={handleAreaInputChange}
                />
                <div className="form-text">
                  Land Area as mentioned in official Document in hectares.
                  <br></br>
                  <br></br>
                </div>
              </div>

              <div className="mb-3">
                <label htmlFor="InputProtectionAgainst" className="form-label">
                  Protection Against
                </label>
                <br></br>
                <input
                  type="radio"
                  id="flood"
                  name="protection"
                  value={inputs.protection}
                  onChange={handleFloodInputChange}
                />
                  <label htmlFor="flood">_Flood__</label>
                <br></br>
                <input
                  type="radio"
                  id="drought"
                  name="protection"
                  value={inputs.protection}
                  onChange={handleDroughtInputChange}
                />
                  <label htmlFor="drought">Drought</label>
                <br></br>
              </div>
              <br></br>
              <div className="mb-3">
                <label htmlFor="InputDocument" className="form-label">
                  Document Id
                </label>
                <input
                  type="text"
                  className="form-control"
                  id="InputDocument"
                  aria-describedby="Document"
                  value={inputs.id}
                  onChange={handleIdInputChange}
                />
              </div>

              <br></br>

              <div className="mb-3">
                <label htmlFor="Proof" className="form-label">
                  ZK Identity Proof
                </label>
                <input
                  type="text"
                  className="form-control"
                  id="InputDocument"
                  aria-describedby="Document"
                  onChange={handleProofInputChange}
                  value={inputs.proof}
                />
              </div>

              <div className="mb-3">
                <label htmlFor="proofInputs" className="form-label">
                  Proof Inputs
                </label>
                <input
                  type="text"
                  className="form-control"
                  id="InputDocument"
                  aria-describedby="Document"
                  onChange={handleProofInputsInputChange}
                  value={inputs.proofInputs}
                />

                <br></br>
                <button type="check" className="btn btn-secondary">
                  Register
                </button>
              </div>
            </form>
          </div>

          <div className="col">
            <h3>Pay Premium</h3>
            <br></br>
            <br></br>
            <form>
              <button type="premium" className="btn btn-primary">
                Pay Premium
              </button>
            </form>
          </div>

          <div className="col">
            <h3>Request Claim</h3>
            <br></br>
            <br></br>
            <form>
              <button type="claim" className="btn btn-primary">
                Claim
              </button>
            </form>
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;
