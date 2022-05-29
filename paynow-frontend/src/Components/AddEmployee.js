import React, {useState} from 'react';

export default function AddEmployee() {
const [name, setName] = useState("");
const [address, setAddress] = useState("");

  const handleSubmit = (event) => {
    event.preventDefault();
    alert(`The name you entered was: ${name}`)
    alert(`The address you entered was: ${address}`)
  }

  return (
    <div>
    <form onSubmit={handleSubmit}>
      <label>Enter employee name:
        <input 
          type="text" 
          value={name}
          onChange={(e) => setName(e.target.value)}
        />
      </label>
      <label>Enter employee address:
        <input 
          type="text" 
          value={address}
          onChange={(e) => setAddress(e.target.value)}
        />
      </label>
      <input type="submit" />
    </form>
    </div>
  )
}