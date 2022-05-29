import React from "react";


export default function ReadOnlyRow({row}) {
    return(
        <tr>
            <td>{row.fullName}</td>
            <td>{row.address}</td>
            <td>{row.annualSalary}</td>
        </tr>
    )
}