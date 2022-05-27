import { getEmployee, getEmployer } from "../lib/deploy.helpers";

export async function deployEmployee() {
    const fakeUSDC = "0x68ec573C119826db2eaEA1Efbfc2970cDaC869c4"

    const employerContract = await getEmployer({
      contractName: "Employer",
      deployParams: ["Test Employer", fakeUSDC],
    });
    console.log(`Employer Contract Address: ${employerContract.address}`);

  const employeeContract = await getEmployee({ contractName: "Employee", deployParams: [
    "Test Employee",
    employerContract.address
]});
  console.log(`Employee Contract Address: ${employeeContract.address}`);

  return employeeContract;
}

deployEmployee()
.then(() => process.exit(0))
.catch((error) => {
    console.error(error);
    process.exit(1);
});