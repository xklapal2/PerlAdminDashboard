import { useState } from 'react'
import './App.css'

import Login from './Login';
import Dashboard from './Dashboard';


// Define the User type
interface User {
  id: number;
  name: string;
  email: string;
}

const App: React.FC = () => {
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [users, setUsers] = useState<User[]>([]);

  const handleLogin = async (username: string, password: string) => {
    // Simulated API call for authentication
    if (username === 'user' && password === 'pass') {
      setIsLoggedIn(true);
      // Simulated API call for fetching users
      const fakeUsers = [
        { id: 1, name: 'John Doe', email: 'john@example.com' },
        { id: 2, name: 'Jane Smith', email: 'jane@example.com' },
      ];
      setUsers(fakeUsers);
    } else {
      alert('Invalid credentials');
    }
  };

  return (
    <div>
      {isLoggedIn ? (
        <Dashboard users={users} />
      ) : (
        <Login onLogin={handleLogin} />
      )}
    </div>
  );
};

export default App;
