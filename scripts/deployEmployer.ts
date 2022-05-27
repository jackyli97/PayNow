import { getEmployer } from "../lib/deploy.helpers";

export async function deployEmployer() {
  const fakeUSDC = "0x68ec573C119826db2eaEA1Efbfc2970cDaC869c4"

  const employerContract = await getEmployer({
    contractName: "Employer",
    deployParams: ["Test Employer", fakeUSDC],
  });
  console.log(`Employer Contract Address: ${employerContract.address}`);

  return employerContract;
}

deployEmployer()
.then(() => process.exit(0))
.catch((error) => {
    console.error(error);
    process.exit(1);
});