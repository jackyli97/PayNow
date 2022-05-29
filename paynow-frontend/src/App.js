// import logo from './logo.svg';
import './App.css';
import WalletCard from './WalletCard';
import AddEmployee from './Components/AddEmployee';
import EmployeesTable from './Components/EmployeesTable';

function App() {
  return (
    <div className="App">
      <WalletCard />
      {/* <AddEmployee /> */}
      <EmployeesTable />
    </div>
  );
}

export default App;
