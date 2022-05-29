import React, {useState} from 'react';
import "../Table.css";
import data from "../mock_table_data.json";
import {nanoid} from 'nanoid';
import ReadOnlyRow from './ReadOnlyRow';

export default function EmployeesTable() {

    const [rows, setRows] = useState(data);
    const [addFormData, setAddFormData] = useState({
        fullName:'',
        address:'',
        annualSalary:''
    })

    const handleAddFormChange = (event) => {
        event.preventDefault();

        const fieldName = event.target.getAttribute('name');
        const fieldValue = event.target.value;

        const newFormData = { ...addFormData};
        newFormData[fieldName] = fieldValue;

        setAddFormData(newFormData);
    }

    const handleAddFormSubmit = (event) => {
        event.preventDefault();

        const newRow = {
            id: nanoid(),
            fullName: addFormData.fullName,
            address: addFormData.address,
            annualSalary: addFormData.annualSalary
        };

        const newRows = [...rows, newRow];
        setRows(newRows);
    }

    return(
        <div className="table-container">
        <table>
            <thead>
                <tr>
                    <th>Name</th>
                    <th>Address</th>
                    <th>Annual Salary ($)</th> 
                </tr>
            </thead>
            <tbody>
                {rows.map((row) => (
                <ReadOnlyRow row={row} />
                ))}
                
            </tbody>
        </table>
        <h2>Add Employee</h2>
        
      <form onSubmit={handleAddFormSubmit}>
        <input
          type="text"
          name="fullName"
          required="required"
          placeholder="Enter employee's name"
          onChange={handleAddFormChange}
        />
        <input
          type="text"
          name="address"
          required="required"
          placeholder="Enter employee's address"
          onChange={handleAddFormChange}
        />
        <input
          type="text"
          name="annualSalary"
          required="required"
          placeholder="Enter annual salary"
          onChange={handleAddFormChange}
        />
       
        <button type="submit">Add</button>
      </form>

        </div>

    )
}