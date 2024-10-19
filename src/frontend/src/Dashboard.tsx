import React from 'react';

interface User {
    id: number;
    name: string;
    email: string;
}

interface DashboardProps {
    users: User[];
}

const Dashboard: React.FC<DashboardProps> = ({ users }) => {
    return (
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Email</th>
                </tr>
            </thead>
            <tbody>
                {users.map((user) => (
                    <tr key={user.id}>
                        <td>{user.id}</td>
                        <td>{user.name}</td>
                        <td>{user.email}</td>
                    </tr>
                ))}
            </tbody>
        </table>
    );
};

export default Dashboard;
